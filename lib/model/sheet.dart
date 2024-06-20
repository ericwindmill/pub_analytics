import '../util/package_util.dart';
import 'package.dart';

/// Utility class that converts a List of Package objects into data formatted
/// for Google sheets
class Sheet {
  List<DateTime> dates = [];
  List<Package> packages;
  int packageHistoryCount = 0;

  Sheet(this.packages) {
    final p = getPackageWithMostHistoryData(packages);
    packageHistoryCount = p.rankHistory.length;
    for (var r in p.rankHistory.reversed) {
      dates.add(r.date);
    }
  }

  /// Creates CSV list formatted specifically for each chart creation.
  /// [
  ///   '',      'http',  'lottie', 'shared_preferences', ...
  ///   '1/1/24', '1',     '2',     '5' ,
  ///   '1/1/24', '1',     '2',     '4',
  ///   ...
  /// ]
  List<List<String>> get rankHistoriesToCsv {
    final chartData = <List<String>>[
      ['', ...packages.map((p) => p.name)],
    ];

    for (var i = 0; i < dates.length; i++) {
      final dateToString = '${dates[i].month}/${dates[i].day}/${dates[i].year}';
      final dateData = [dateToString];
      for (var package in packages) {
        final int correspondingRankIdx = package.rankHistory
            .indexWhere((element) => element.date == dates[i]);
        if (correspondingRankIdx == -1) {
          dateData.add(' ');
        } else {
          dateData
              .add(package.rankHistory[correspondingRankIdx].rank.toString());
        }
      }
      chartData.add(dateData);
    }
    return chartData;
  }

  List<List<String>> packagesToCsv() {
    final csvAssessmentData = <List<String>>[
      [
        'Name',
        'Mover Score',
        'Rank',
        'Change since previous',
        'Overall change',
        'All time change',
        'All time high',
        'All time low',
        'Most common rank',
        'Most common rank occurrence',
        'Second most common rank',
        'Second most common rank occurrence',
        'Continued...',
      ],
      [
        'package name',
        'Score based on all the other metrics',
        'current rank',
        'distance between current rank current-1 rank',
        'distance between package all-time low and the current rank',
        'distance between package least current rank and the most current rank',
        'highest package rank',
        'lowest package rank',
        'rank that occurs most often',
        'number of times that rank has occurred',
        'etc',
      ],
    ];

    for (final package in packages) {
      final asCsvRow = packageToCsvRow(package);
      csvAssessmentData.add(asCsvRow);
    }

    return csvAssessmentData;
  }

  List<String> packageToCsvRow(Package package) {
    final rankDispersionToCsv = <String>[];
    final sortedDispersion = Map.fromEntries(
        package.rankDispersion.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)));
    sortedDispersion.forEach((key, value) {
      rankDispersionToCsv.addAll([
        key.toString(),
        value.toString(),
      ]);
    });

    return [
      package.name,
      package
          .getPackageMoverScore(packageHistoryCount, packages.length)
          .toString(),
      package.currentRank.toString(),
      package.changeSinceLastRanking.toString(),
      package.overallChange.toString(),
      package.allTimeChange.toString(),
      package.allTimeHighRanking.toString(),
      package.allTimeLowRanking.toString(),
      ...rankDispersionToCsv,
    ];
  }
}
