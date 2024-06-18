import '../util/package_util.dart';
import 'package.dart';

/// Utility class that converts a List of Package objects into data formatted
/// for Google sheets
class Sheet {
  List<DateTime> dates = [];
  List<Package> packages;

  Sheet(this.packages) {
    final p = getPackageWithMostHistoryData(packages);
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
        'Rank',
        'Change since previous',
        'Overall gain',
        'All time change',
        'Most common diff',
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
        'current rank',
        'distance between current rank current-1 rank',
        'distance between package all-time low and the current rank',
        'distance between package least current rank and the most current rank',
        'distance between package most common rank and second most common rank',
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
      package.currentRank.toString(),
      package.changeSinceLastRanking.toString(),
      package.overallGain.toString(),
      package.allTimeChange.toString(),
      package.mostCommonRankDiff.toString(),
      package.allTimeHighRanking.toString(),
      package.allTimeLowRanking.toString(),
      ...rankDispersionToCsv,
    ];
  }
}
