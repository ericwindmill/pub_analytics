import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:pub_analytics/pub_analytics.dart';

import 'util.dart';

final sortBy = 'sort-by';
final sortDir = 'sort-dir';
final count = 'count';

/// Determines how many packages will be in the resulting data set.
/// Can be set with the 'count' arg
final defaultPackageCount = 3000;

void main(List<String> arguments) async {
  io.exitCode = 0;
  final argParser = ArgParser()
    ..addFlag('csv',
        defaultsTo: true,
        help: 'When true, the script will also generate the new CSV file')
    ..addFlag('history',
        defaultsTo: true,
        help:
            'When true, the script will also generate the a CSV file with package ranking history data.')
    ..addOption(
      sortBy,
      abbr: 's',
      allowed: ['currentRank', 'allTimeChange', 'recentChange'],
      defaultsTo: 'currentRank',
    )
    ..addOption(
      sortDir,
      abbr: 'd',
      allowed: ['asc', 'desc'],
      defaultsTo: 'asc',
    )
    ..addOption(
      count,
      abbr: 'c',
      help: 'The number of the top N packages to be included in the dataset.',
      defaultsTo: defaultPackageCount.toString(),
    )
    ..addFlag('help', negatable: false, help: 'Print help text and exit');

  ArgResults argResults = argParser.parse(arguments);

  if (argResults['help'] as bool) {
    printUsage(argParser);
    return;
  }

  final withCsv = argResults['csv'] as bool;
  final withHistory = argResults['history'] as bool;

  // There should be at most 1 argument, which is the filename to write data
  // to that isn't the `alltime_rank_history_data.json`
  if (argResults.rest.length > 1) {
    printUsage(argParser);
    io.exitCode = 1;
    return;
  }

  late SortPackagesBy sortType =
      SortPackagesBy.values.firstWhere((t) => t.name == argResults[sortBy]);
  late SortDirection sortDirection =
      SortDirection.values.firstWhere((d) => d.name == argResults[sortDir]);
  final pkgCount = int.parse(argResults[count]);
  final allTimeRankHistoryDataFileName = 'alltime_rank_history_data';
  final client = http.Client();

  // Start analytics logic
  try {
    final newPubData = await getOrderedPackageNames(client).then((packages) {
      return packages.take(pkgCount).toList();
    });

    // If a file name is passed in create that data in addition to "alltime" data
    if (argResults.rest.length == 1) {
      final fileName = getFileNameWithoutExtension(argResults.rest.first);
      _generateAnalyticsForFile(
        fileName: fileName,
        newPubData: newPubData,
        sortType: sortType,
        sortDirection: sortDirection,
        withCsv: withCsv,
        withHistory: withHistory,
      );
    }

    _generateAnalyticsForFile(
      fileName: allTimeRankHistoryDataFileName,
      newPubData: newPubData,
      sortType: sortType,
      sortDirection: sortDirection,
      withCsv: withCsv,
      withHistory: withHistory,
    );
  } catch (e) {
    rethrow;
  } finally {
    client.close();
  }
}

void _generateAnalyticsForFile({
  required String fileName,
  required List<String> newPubData,
  required SortPackagesBy sortType,
  required SortDirection sortDirection,
  required bool withCsv,
  required bool withHistory,
}) async {
  final fileExists = io.File('$fileName.json').existsSync();
  List<Package> packages;
  if (fileExists) {
    packages = await loadPackagesFromFile(fileName);
    packages = _updatePackageHistory(packages, newPubData);
  } else {
    packages = createPackageListFromPub(newPubData);
  }
  packages.sortPackages(by: sortType, direction: sortDirection);
  _writeToFiles(fileName, packages, withCsv, withHistory);
}

List<Package> _updatePackageHistory(
  List<Package> existingPackageData,
  List<String> newPackageData,
) {
  // If the file does exist, add the new package rankings to existing
  // package 'rank history'
  final updatedPackageList = <Package>[];
  final now = DateTime.now();

  for (var i = 0; i < newPackageData.length; i++) {
    final package = existingPackageData
        .firstWhere((element) => element.name == newPackageData[i], orElse: () {
      // If there isn't data for this package, create a new package object
      final package = Package.fromPub(
        packageName: newPackageData[i],
        rank: i + 1,
      );
      return package;
    });
    package.addRankToRankHistory(now, i + 1);
    updatedPackageList.add(package);
  }

  return updatedPackageList;
}

Future<void> _writeToFiles(
  String fileName,
  List<Package> packageData,
  bool withCsv,
  bool withHistory,
) async {
  // Always write to JSON, because it's the database
  writePackagesToJsonFile(fileName, packageData);

  if (withCsv) {
    writePackagesToCsvFile(
      fileName,
      packageData,
      withHistory: withHistory,
    );
  }
}
