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
        'Current rank',
        'Change since previous',
        'Overall gain',
        'All time change',
        'All time high',
        'All time low',
        'Most common rank',
        'Most common rank occurrence',
        'Second most common rank',
        'Second most common rank occurrence',
        'Continued...',
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
      package.allTimeHighRanking.toString(),
      package.allTimeLowRanking.toString(),
      ...rankDispersionToCsv,
    ];
  }

  // Todo: no longer used. remove?
  List<List<String>> rankHistoriesToCSV() {
    final csvRankHistory = <List<String>>[
      [
        'Name',
        'Current rank',
        'Current data date',
        'Current data rank',
        'Previous date',
        'Previous rank',
        "Continued..."
      ],
    ];

    for (final package in packages) {
      final historyAsCsvRow = packageRankHistoryToCsvRow(package);
      csvRankHistory.add(historyAsCsvRow);
    }

    return csvRankHistory;
  }

  // Todo: no longer used. remove?
  List<String> packageRankHistoryToCsvRow(Package package) {
    final historyToCsv = <String>[];
    for (var ranking in package.rankHistory) {
      historyToCsv.addAll(
        [
          '${ranking.date.month}/${ranking.date.day}/${ranking.date.year}',
          ranking.rank.toString(),
        ],
      );
    }

    return [
      package.name,
      package.currentRank.toString(),
      ...historyToCsv,
    ];
  }
}
