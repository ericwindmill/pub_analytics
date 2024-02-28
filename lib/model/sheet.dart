import 'package:pub_analytics/model/ranking.dart';

import '../util/rank_history_util.dart';
import 'package.dart';

/// Utility class that converts a List of Package objects into formatted data
class Sheet {
  List<DateTime> dates = [];
  List<Package> allPackages;

  Sheet(this.allPackages) {
    final p = getPackageWithMostHistoryData(allPackages);
    for (var r in p.rankHistory.reversed) {
      dates.add(r.date);
    }
  }

  /// [
  ///   'Name', 'Rank history', 'cont'd...'
  ///   ' '   ,  '1/1/24',     '1/2/24',
  ///   'http', '1',           '1',
  ///   'lottie', '2',         '3',
  ///   etc.
  /// ]
  List<List<String>> get csvChartData {
    final chartData = <List<String>>[
      ['', ...allPackages.map((p) => p.name)],
    ];

    for (var i = 0; i < dates.length; i++) {
      final dateToString = '${dates[i].month}/${dates[i].day}/${dates[i].year}';
      final dateData = [dateToString];
      for (var package in allPackages) {
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
}
