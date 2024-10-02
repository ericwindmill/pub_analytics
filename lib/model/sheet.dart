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

  List<List<String>> packagesToCsv() {
    final csvAssessmentData = <List<String>>[
      [
        'Name',
        'Mover Score',
        'Pub Rank',
        'All time high pub rank',
        'All time low pub rank',
      ],
      [
        'package name',
        'Calculated score based on all the other metrics',
        'current rank',
        'highest ever package rank',
        'lowest ever package rank',
      ],
    ];

    for (final package in packages) {
      csvAssessmentData.add([
        package.name,
        package.currentMoverScore.toString(),
        package.currentRank.toString(),
        package.allTimeHighRanking.toString(),
        package.allTimeLowRanking.toString(),
      ]);
    }

    return csvAssessmentData;
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

  List<List<String>> get moverScoreHistoriesToCsv {
    final formattedDates =
        dates.map((date) => '${date.month}/${date.day}/${date.year}');

    final csvData = <List<String>>[
      [
        'Name',
        ...formattedDates,
      ],
    ];

    for (var p in packages) {
      final packageData = [p.name];
      for (var d in dates) {
        final dataForDate = p.moverScoreHistory.where((rank) => rank.date == d);
        if (dataForDate.length == 1) {
          packageData.add(dataForDate.first.rank.toString());
        } else if (dataForDate.isEmpty) {
          packageData.add('');
        } else {
          packageData.add('');
          print("Multiple mover score entries for package ${p.name} on $d}");
        }
      }
      csvData.add(packageData);
    }

    return csvData;
  }
}
