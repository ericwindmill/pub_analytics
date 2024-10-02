import 'package:args/args.dart';
import 'package:pub_analytics/generate_analytics.dart';
import 'package:pub_analytics/model/package.dart';
import 'package:pub_analytics/model/sheet.dart';
import 'package:pub_analytics/util/package_util.dart';

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

void printMoversScores(
  AllPackageAnalytics packageData, {
  bool printCurrent = false,
  int printCount = 10,
}) {
  _printOneDataSet(packageData.allTimePackageData, printCount);

  if (printCurrent) {
    _printOneDataSet(packageData.currentPackageData!, printCount);
  }
}

void _printOneDataSet(
  List<Package> packageData,
  int take,
) {
  final copy = packageData;
  copy.sort((b, a) => a.currentMoverScore.compareTo(b.currentMoverScore));
  final toPrint = copy.take(take);
  print('--- Top $take by movers score (all time) ---');
  for (var p in toPrint) {
    print('${p.name}  --  ${p.currentMoverScore}');
  }
}
