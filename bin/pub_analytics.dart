import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:pub_analytics/pub_analytics.dart';

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
  final pkgCount = int.parse(argResults[count]);

  // Start analytics logic
  final client = http.Client();

  try {
    final rankedPackageNamesFromPub =
        await getOrderedPackageNames(client).then((packages) {
      return packages.take(pkgCount).toList();
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
          );
          return package;
        });
        package.addRankToRankHistory(now, i + 1);
        updatedPackageList.add(package);
      }
      updatedPackageList.sortPackages(by: sortType, direction: sortDirection);
    } else {
      // The file doesn't exist, so start with an empty data set
      updatedPackageList.addAll(packages);
    }

    // Always write to JSON, because it's essentially the database
    writePackagesToJsonFile(fileName, updatedPackageList);

    // Whether you write to CSV everytime you run the script, or
    // only when you're ready to export the data doesn't affect the
    // outcome. Writing to CSV will always include the complete data
    // collected in the associated data json file
    if (withCsv) {
      writePackagesToCsvFile(
        fileName,
        updatedPackageList,
        withHistory: withHistory,
      );
    }
  } catch (e) {
    rethrow;
  } finally {
    client.close();
  }
}

enum SortDirection {
  asc,
  desc,
}

enum SortPackagesBy {
  currentRank,
  recentChange,
  allTimeChange,
}

extension on List<Package> {
  sortPackages({
    SortPackagesBy by = SortPackagesBy.currentRank,
    SortDirection direction = SortDirection.desc,
  }) {
    sort((Package a, Package b) {
      var (aField, bField) = switch (by) {
        SortPackagesBy.currentRank => (a.currentRank, b.currentRank),
        SortPackagesBy.recentChange => (
            a.changeSinceLastRanking,
            b.changeSinceLastRanking
          ),
        SortPackagesBy.allTimeChange => (a.allTimeChange, b.allTimeChange),
      };

      if (direction == SortDirection.asc) return aField.compareTo(bField);
      return bField.compareTo(aField);
    });
  }
}

void printUsage(ArgParser parser) {
  print('''Usage: pub_analytics.dart [options] [filename]

Fetch pub packages ranked by overall score and write results as JSON to a 
[filename].json, preserving historical data if this isn't the first time the 
script has been run. 

The package can also create metrics based on rank history, and writes results as
CSV file to [filename]_assessment.txt. Rank history is optionally saved as CSV
 in a file called called [filename]_history.txt.

[file] doesn't need an extension. If you add one, it will be stripped off.

${parser.usage}

By default, packages will be sorted by their current ranking, and in ascending order.
''');
}
