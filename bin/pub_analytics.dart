import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:pub_analytics/pub_analytics.dart';

final sortBy = 'sort-by';
final sortDir = 'sort-dir';

void main(List<String> arguments) async {
  io.exitCode = 0;
  final argParser = ArgParser()
    ..addFlag('csv',
        defaultsTo: false,
        help: 'When true, the script will also generate the '
            'new CSV file')
    ..addOption(sortBy,
        abbr: 's',
        allowed: ['currentRank', 'overallChange', 'recentChange'],
        defaultsTo: 'currentRank')
    ..addOption(
      sortDir,
      abbr: 'd',
      allowed: ['asc', 'desc'],
      defaultsTo: 'asc',
    )
    ..addFlag('help', negatable: false, help: 'Print help text and exit');

  ArgResults argResults = argParser.parse(arguments);

  if (argResults['help'] as bool) {
    printUsage(argParser);
    return;
  }

  final withCsv = argResults['csv'] as bool;
  if (argResults.rest.isEmpty || argResults.rest.length > 1) {
    printUsage(argParser);
    io.exitCode = 1;
    return;
  }

  // Remove the file extension, if any, so that we can work with .json and
  // .txt files
  final fileName = getFileNameWithoutExtension(argResults.rest.first);

  late SortPackagesBy sortType =
      SortPackagesBy.values.firstWhere((t) => t.name == argResults[sortBy]);
  late SortDirection sortDirection =
      SortDirection.values.firstWhere((d) => d.name == argResults[sortDir]);

  final client = http.Client();

  try {
    final rankedPackageNamesFromPub =
        await getOrderedPackageNames(client).then((packages) {
      return packages.take(3000).toList();
    });

    final fileExists = io.File('$fileName.json').existsSync();
    final packages = fileExists
        ? await loadPackagesFromFile(fileName)
        : createPackageListFromPub(rankedPackageNamesFromPub);

    // If the file does exist, add the new package rankings to existing
    // package 'rank history'
    final updatedPackageList = <Package>[];
    if (fileExists) {
      final now = DateTime.now();

      for (var i = 0; i < rankedPackageNamesFromPub.length; i++) {
        final package = packages.firstWhere(
            (element) => element.name == rankedPackageNamesFromPub[i],
            orElse: () {
          // If there isn't data for this package, create a new package object
          final package = Package.fromPub(
            packageName: rankedPackageNamesFromPub[i],
            rank: i + 1,
            now: now,
          );
          return package;
        });
        package.addRankToRankHistory(now, i + 1);
        updatedPackageList.add(package);
      }
      updatedPackageList.sortPackages(by: sortType, direction: sortDirection);
    } else {
      updatedPackageList.addAll(packages);
    }

    writePackagesToJsonFile(fileName, updatedPackageList);
    if (withCsv) writePackagesToCsvFile(fileName, updatedPackageList);
  } catch (e) {
    rethrow;
  } finally {
    client.close();
  }
}

extension on List<Package> {
  sortPackages({
    SortPackagesBy by = SortPackagesBy.changeSinceLastRanking,
    SortDirection direction = SortDirection.desc,
  }) {
    sort((Package a, Package b) {
      var (aField, bField) = switch (by) {
        SortPackagesBy.currentRank => (a.currentRank, b.currentRank),
        SortPackagesBy.changeSinceLastRanking => (
            a.changeSinceLastRanking,
            b.changeSinceLastRanking
          ),
        SortPackagesBy.overallChangeInRanking => (
            a.overallChangeInRanking,
            b.overallChangeInRanking
          ),
      };

      if (direction == SortDirection.asc) return aField.compareTo(bField);
      return bField.compareTo(aField);
    });
  }
}

void printUsage(ArgParser parser) {
  print('''Usage: pub_analytics.dart [options] [filename]

Fetch pub packages ranked by overall score and write results as JSON to a 
[filename].json, and writes results as CSV to [filename].txt.

[file] doesn't need an extension. If you add one, it will be stripped off.

${parser.usage}

By default, packages will be sorted by their current ranking, and in ascending order.
''');
}
