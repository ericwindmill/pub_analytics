import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:pub_analytics/model/package.dart';

void printUsage(ArgParser parser) {
  print('''Usage: pub_analytics.dart [options] [filename]

Fetch pub packages ranked by overall score and write results as JSON to a 
[filename].json, preserving historical data if this isn't the first time the 
script has been run. 

The package can also generate metrics based on rank history, 
and will optionally write results as CSV files. 

The script automatically saves all data to a file all_time_data.json, in
addition to the file name that you pass in. In the future, you can pass in a 
new file name, so you can have an 'all time' history and a time boxed history.

See README for more information.

[file] doesn't need an extension. If you add one, it will be stripped off.

${parser.usage}

By default, packages will be sorted by their current ranking, and in ascending order.
''');
}

void printMoversScores(
  List<Package> allTimeData,
  List<Package>? currentPeriodData, {
  int printCount = 10,
}) {
  _printOneDataSet(allTimeData, printCount);

  if (currentPeriodData != null) {
    _printOneDataSet(currentPeriodData, printCount);
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

class Log {
  final Logger _logger = Logger('pub_analytics logger');

  Log() {
    _logger.onRecord.listen((record) {
      print('${_formatDate(record.time)}: ${record.message}');
    });
  }

  void p(String message) => _logger.warning(message);

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month}-${dt.day} at ${dt.hour}:${dt.minute}:${dt.second}.${dt.millisecond}';
  }
}
