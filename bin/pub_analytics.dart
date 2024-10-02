import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:pub_analytics/generate_analytics.dart';
import 'package:pub_analytics/pub_analytics.dart';

import 'util.dart';

final count = 'count';
final printFlag = 'print';
final exportFlag = 'export';
final defaultPackageCount = 3000;

void main(List<String> arguments) async {
  io.exitCode = 0;
  final argParser = ArgParser()
    ..addFlag(
      exportFlag,
      defaultsTo: false,
      help: 'When true, the script will also generate a CSV file with the data',
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
      help: 'Prints the packages with the all-time top 10 movers score. '
          'If true, no data will be written to any files. Useful for testing.',
      defaultsTo: false,
    )
    ..addFlag('help', negatable: false, help: 'Print help text and exit');

  ArgResults argResults = argParser.parse(arguments);
  if (argResults['help'] as bool) {
    printUsage(argParser);
    return;
  }

  // There should be at most 1 argument (not including flags),
  // which is the base filename to write data to.
  if (argResults.rest.length > 1) {
    printUsage(argParser);
    io.exitCode = 1;
    return;
  }

  final client = http.Client();
  final export = argResults['export'] as bool;
  final printMode = argResults['print'] as bool;
  final didProvideFileName = argResults.rest.length == 1;
  final pkgCount = int.parse(argResults[count]);
  String? currentDataFileName = didProvideFileName
      ? getFileNameWithoutExtension(argResults.rest.first)
      : null;

  try {
    // Get new data
    final newPubData = await getOrderedPackageNames(client).then((packages) {
      return packages.take(pkgCount).toList();
    });

    // Generate new analytics using the new data
    AllPackageAnalytics packageAnalytics = await generateAnalytics(
      fileName: currentDataFileName,
      newPubData: newPubData,
    );

    // Save new analytics to the JSON 'database'
    if (didProvideFileName) {
      writePackageDataToJsonFile(
        currentDataFileName!,
        packageAnalytics.currentPackageData!,
      );
    }

    writePackageDataToJsonFile(
      FileNames.allTimeRankHistory,
      packageAnalytics.allTimePackageData,
    );

    // optionally, do more stuff with the data
    if (printMode) {
      printMoversScores(
        packageAnalytics,
        printCurrent: didProvideFileName,
      );
    }

    // export 'all time' data to CSV
    if (export) {
      writeMoverScoreHistoryCsv(
        FileNames.allTimeMoverScoreHistory,
        Sheet(packageAnalytics.allTimePackageData),
      );
      writeRankHistoryCsv(
        FileNames.allTimeRankHistory,
        Sheet(packageAnalytics.allTimePackageData),
      );
    }

    // export 'current' data to CSV
    if (didProvideFileName && export) {
      writeMoverScoreHistoryCsv(
        FileNames.currentMoverScoreHistory(currentDataFileName!),
        Sheet(packageAnalytics.currentPackageData!),
      );
      writeRankHistoryCsv(
        FileNames.currentRankHistory(currentDataFileName),
        Sheet(packageAnalytics.currentPackageData!),
      );
    }
  } catch (e) {
    print(e);
    rethrow;
  } finally {
    client.close();
  }
}
