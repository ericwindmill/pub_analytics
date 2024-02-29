import 'package:pub_analytics/model/ranking.dart';

class Package {
  /// This name comes from pub
  final String name;

  /// Rank history is descending by date
  final List<Ranking> rankHistory;

  int allTimeHighRanking;
  int allTimeLowRanking;

  Package({
    required this.name,
    required this.rankHistory,
    required this.allTimeHighRanking,
    required this.allTimeLowRanking,
  });

  void addRankToRankHistory(DateTime date, int rank) {
    if (rank < allTimeHighRanking) allTimeHighRanking = rank;
    if (rank > allTimeLowRanking) allTimeLowRanking = rank;

    rankHistory.insert(0, Ranking(date, rank));
  }

  /// A map of a given ranking (for example, 12), and the number of times
  /// that rank shows up. This is used to account for random, drastic shifts in
  /// package ranking that last for a brief amount of time
  ///
  /// example - package http:
  ///
  /// {
  ///  "1": 12,
  ///  "2": 3,
  ///  "742": 1,
  /// }
  ///
  /// According to this example, package http has been ranked #1 12 times,
  /// #2 3 times, and #742 once.
  Map<String, int> get rankDispersion {
    final dispersion = <String, int>{};
    for (var r in rankHistory) {
      final key = r.rank.toString();
      if (dispersion.containsKey(key)) {
        dispersion[key] = dispersion[key]! + 1;
      } else {
        dispersion[key] = 1;
      }
    }

    return dispersion;
  }

  int get currentRank => rankHistory.first.rank;

  /// Change from second most recent ranking to most recent ranking
  int get changeSinceLastRanking {
    if (rankHistory.length < 2) return 0;
    return rankHistory[1].rank - rankHistory[0].rank;
  }

  /// Change from least recent ranking to most recent ranking
  int get allTimeChange {
    if (rankHistory.length < 2) return 0;
    return rankHistory.last.rank - rankHistory[0].rank;
  }

  /// distance between lowest ever score and current score
  int get overallGain {
    return allTimeLowRanking - currentRank;
  }

  // DateTime is passed in so all packages that are ranked on any given date
  // have the exact same date time
  factory Package.fromPub({
    required String packageName,
    required int rank,
  }) {
    final package = Package(
      name: packageName,
      rankHistory: [],
      allTimeHighRanking: rank,
      allTimeLowRanking: rank,
    );
    return package;
  }

  factory Package.fromMap(
    Map<String, Object?> map,
  ) {
    if (map
        case {
          'name': String name,
          'allTimeHighRanking': int high,
          'allTimeLowRanking': int low,
          'rankHistory': _,
        }) {
      return Package(
        name: name,
        allTimeHighRanking: high,
        allTimeLowRanking: low,
        rankHistory: (map['rankHistory'] as List)
            .map((r) => Ranking.fromMap(r))
            .toList(),
      );
    } else {
      throw "Data is malformed: ${map.toString()}";
    }
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'allTimeHighRanking': allTimeHighRanking,
      'allTimeLowRanking': allTimeLowRanking,
      'rankHistory': rankHistory.map((r) => r.toMap()).toList(),
    };
  }
}
