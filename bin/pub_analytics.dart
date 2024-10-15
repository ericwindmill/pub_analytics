import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:pub_analytics/generate_analytics.dart';
import 'package:pub_analytics/pub_analytics.dart';

import 'util.dart';

final count = 'count';
final printFlag = 'print';
final exportFlag = 'export';
final defaultPackageCount = 3000;
final Log logger = Log();

void main(List<String> arguments) async {
  logger.p('starting script');
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

  try {
    // Get new data
    final newPubData = await getOrderedPackageNames(client).then((packages) {
      return packages.take(pkgCount).toList();
    });

    List<Package>? currentPeriodPackageData = didProvideFileName
        ? await generateAnalytics(
            fileName: FileNames.currentPeriodData(argResults.rest.first),
            newPubData: newPubData)
        : null;
    List<Package> allTimePackageData = await generateAnalytics(
        fileName: FileNames.allTimeData, newPubData: newPubData);

    // Save new analytics to the JSON 'database'
    writePackageDataToJsonFile(FileNames.allTimeData, allTimePackageData);
    if (didProvideFileName) {
      writePackageDataToJsonFile(
        FileNames.currentPeriodData(argResults.rest.first),
        currentPeriodPackageData!,
      );
    }

    // optionally, do more stuff with the data

    // print mover scores to console
    // useful for testing the way mover score is calculated
    if (printMode) {
      printMoversScores(allTimePackageData, currentPeriodPackageData);
    }

    // export 'all time' data to CSV
    if (export) {
      writePackageOverviewToCSV(
        FileNames.allTimeOverview,
        Sheet(allTimePackageData),
      );
      writeMoverScoreHistoryCsv(
        FileNames.allTimeMoverScoreHistory,
        Sheet(allTimePackageData),
      );
      writeRankHistoryCsv(
        FileNames.allTimeRankHistory,
        Sheet(allTimePackageData),
      );
    }

    // export 'current period' data to CSV
    if (didProvideFileName && export) {
      writePackageOverviewToCSV(
        FileNames.currentPeriodOverview(argResults.rest.first),
        Sheet(currentPeriodPackageData!),
      );
      writeMoverScoreHistoryCsv(
        FileNames.currentPeriodMoverScoreHistory(argResults.rest.first),
        Sheet(currentPeriodPackageData),
      );
      writeRankHistoryCsv(
        FileNames.currentPeriodRankHistory(argResults.rest.first),
        Sheet(currentPeriodPackageData),
      );
    }
    logger.p('finished script successfully');
  } catch (e) {
    logger.p('error in script! -- $e');
    rethrow;
  } finally {
    client.close();
  }
}
