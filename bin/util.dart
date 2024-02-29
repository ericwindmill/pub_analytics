import 'package:args/args.dart';
import 'package:pub_analytics/model/package.dart';

enum SortDirection {
  asc,
  desc,
}

enum SortPackagesBy {
  currentRank,
  recentChange,
  allTimeChange,
}

extension SortPackage on List<Package> {
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
