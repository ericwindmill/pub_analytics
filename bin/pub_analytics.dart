import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:pub_analytics/pub_analytics.dart';

import 'util.dart';

final sortBy = 'sort-by';
final sortDir = 'sort-dir';
final count = 'count';
final printFlag = 'print';

final defaultPackageCount = 3000;

void main(List<String> arguments) async {
  io.exitCode = 0;
  final argParser = ArgParser()
    ..addFlag('csv',
        defaultsTo: false,
        help:
            'When true, the script will also generate a CSV file with the data called <filename>_history.txt')
    ..addFlag('assessment',
        abbr: 'a',
        defaultsTo: false,
        help:
            'When true, the script will also generate a CSV file with computed metrics called <filename>_assessment.txt')
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
    ..addFlag(
      printFlag,
      abbr: 'p',
      help: 'Prints the packages with the all-time top 10 movers score.',
      defaultsTo: false,
    )
    ..addFlag('help', negatable: false, help: 'Print help text and exit');

  ArgResults argResults = argParser.parse(arguments);

  if (argResults['help'] as bool) {
    printUsage(argParser);
    return;
  }

  final withCsv = argResults['csv'] as bool;
  final withAssessment = argResults['assessment'] as bool;
  final printMoversScore = argResults['print'] as bool;

  // There should be at most 1 argument (not including flags),
  // which is the base filename to write data to.
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
  final allTimeRankHistoryDataFileName = './assets/all_time_rank_history_data';
  final client = http.Client();

  // Start analytics logic
  try {
    final newPubData = await getOrderedPackageNames(client).then((packages) {
      return packages.take(pkgCount).toList();
    });

    // If a file name is passed in create that data in addition to "all time" data
    if (argResults.rest.length == 1) {
      /// Generate for passed in file
      final fileName = getFileNameWithoutExtension(argResults.rest.first);
      await _generateAnalyticsForFile(
          fileName: fileName,
          newPubData: newPubData,
          sortType: sortType,
          sortDirection: sortDirection,
          withCsv: withCsv,
          withAssessment: withAssessment,
          printMoversScore: printMoversScore);
    }

    await _generateAnalyticsForFile(
        fileName: allTimeRankHistoryDataFileName,
        newPubData: newPubData,
        sortType: sortType,
        sortDirection: sortDirection,
        withCsv: withCsv,
        withAssessment: withAssessment,
        printMoversScore: printMoversScore);
  } catch (e) {
    print(e);
    rethrow;
  } finally {
    client.close();
  }
}

Future<void> _generateAnalyticsForFile({
  required String fileName,
  required List<String> newPubData,
  required SortPackagesBy sortType,
  required SortDirection sortDirection,
  required bool withCsv,
  required bool withAssessment,
  required bool printMoversScore,
}) async {
  final fileExists = await io.File('$fileName.json').exists();
  List<Package> packages;
  if (fileExists) {
    packages = await loadPackageDataFromFile(fileName);
    packages = _updatePackageHistory(packages, newPubData);
  } else {
    packages = createPackageListFromPub(newPubData);
  }
  packages.sortPackages(by: sortType, direction: sortDirection);

  if (printMoversScore) {
    printMoversScores(packages);

    if (!withCsv && !withAssessment) {
      return;
    }
  }

  _writeToFiles(
    fileName,
    packages,
    withCsv,
    withAssessment,
  );
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
  bool withAssessment,
) async {
  final sheet = Sheet(packageData);

  // Always write to JSON, because it's the database
  writePackageDataToJsonFile(fileName, packageData);

  if (withCsv) {
    generateHistoryCsv(fileName, sheet);
  }

  if (withAssessment) {
    generatePackageAssessmentCsv(fileName, sheet);
  }
}

void printMoversScores(List<Package> packageData) {
  final sheet = Sheet(packageData);
  final packageHistoryCount = getPackageWithMostHistoryData(packageData);

  Map<String, int> scores = {};

  for (var p in sheet.packages) {
    final score = getPackageMoverScore(p, packageHistoryCount.rankHistory.length, packageData.length);
    scores[p.name] = score;
  }

  final sortedScores = Map.fromEntries(scores.entries.toList()..sort((b, a) => a.value.compareTo(b.value)));
  final top10 = sortedScores.entries.take(100);

  for (var p in top10) {
    print('${p.key}  --  ${p.value}');
  }
}
