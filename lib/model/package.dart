import 'package:pub_analytics/model/ranking.dart';

import '../util/util.dart';

class Package {
  /// This name comes from pub
  final String name;

  /// Rank history is descending by date
  final List<Ranking> rankHistory;

  /// Mover score history is descending by date
  final List<Ranking> moverScoreHistory;

  int allTimeHighRanking;
  int allTimeLowRanking;

  Package({
    required this.name,
    required this.rankHistory,
    required this.moverScoreHistory,
    required this.allTimeHighRanking,
    required this.allTimeLowRanking,
  });

  void addRankToRankHistory(DateTime date, int rank) {
    if (rank < allTimeHighRanking) allTimeHighRanking = rank;
    if (rank > allTimeLowRanking) allTimeLowRanking = rank;

    rankHistory.insert(0, Ranking(date, rank));
  }

  void addMoverScoreToHistory(
      DateTime date, int totalHistoryCount, int totalPackageCount) {
    final score = _calculateMoverScore(totalHistoryCount, totalPackageCount);
    moverScoreHistory.insert(0, Ranking(date, score));
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

  int get currentMoverScore => moverScoreHistory.first.rank;

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
  int get overallChange {
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
      moverScoreHistory: [],
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
          'moverScoreHistory': _,
        }) {
      return Package(
        name: name,
        allTimeHighRanking: high,
        allTimeLowRanking: low,
        rankHistory: (map['rankHistory'] as List)
            .map((r) => Ranking.fromMap(r))
            .toList(),
        moverScoreHistory: (map['moverScoreHistory'] as List)
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
      'moverScoreHistory': moverScoreHistory.map((r) => r.toMap()).toList(),
    };
  }

  /// This attempts to take all the relevant stats, and combine them into one score.
  /// This score uses heuristics to determine how much weight should be given to
  /// each different metric.
  ///
  /// Heuristics:
  /// * packages that move up quickly are more likely to have
  ///    juiced stats than packages that move up slowly.
  /// * packages that have been in the top N packages consistently are more
  ///   likely to valuable than packages that suddenly pop-up at a high ranking
  /// * if two packages have increased at the same rate, the package that has a higher
  ///   current and/or all-time rank is more valuable than the other
  ///
  /// Getting a score for each metric:
  /// * Determine the range of possible numbers (i.e. currentRank range = total number of packages to 1)
  /// * Convert that range into a common range (1 to 100)
  /// * Convert the metric score to that range
  /// * multiple the new metric score by its weight
  ///
  int _calculateMoverScore(
    int totalHistoryCount,
    int totalPackageCount,
  ) {
    /// Current Rank - Range: totalPackageCount (low) to 1 (high)
    var convertedCurrentRank = convertRange(
      oldMax: 1,
      oldMin: totalPackageCount,
      oldValue: currentRank,
    );
    var currentRankScore = convertedCurrentRank * _Weights.currentRank;

    /// All time high rank - Range: totalPackageCount (low) to 1 (high)
    var convertedAllTimeHigh = convertRange(
      oldMax: 1,
      oldMin: totalPackageCount,
      oldValue: allTimeHighRanking,
    );
    var allTimeHighScore = convertedAllTimeHigh * _Weights.allTimeHighRanking;

    /// Overall Gain - Range: 0 (low) to totalPackageCount (high)
    var convertedOverallGain = convertRange(
      oldMax: totalPackageCount,
      oldMin: 0,
      oldValue: overallChange,
    );
    var overAllGainScore = convertedOverallGain * _Weights.overallGain;

    /// All time change - Range:-totalPackageCount to totalPackageCount
    var convertedAllTimeChange = convertRange(
      oldMax: totalPackageCount,
      oldMin: -totalPackageCount,
      oldValue: allTimeChange,
    );
    var allTimeChangeScore = convertedAllTimeChange * _Weights.allTimeChange;

    /// Num different ranks - Range: 0 to totalHistoryCount
    var convertedNumDifferentRanks = convertRange(
      oldMax: totalHistoryCount,
      oldMin: 0,
      oldValue: rankDispersion.length,
    );
    var numDifferentRanksScore =
        convertedNumDifferentRanks * _Weights.numDifferentRanks;

    /// Total times ranked - Range: 0 to totalHistoryCount
    var convertedPackageHistoryCount = convertRange(
      oldMax: totalHistoryCount,
      oldMin: 0,
      oldValue: rankHistory.length,
    );
    var packageHistoryCountScore =
        convertedPackageHistoryCount * _Weights.packageRankHistoryCount;

    var totalPoints = overAllGainScore +
        allTimeHighScore +
        allTimeChangeScore +
        currentRankScore +
        numDifferentRanksScore +
        packageHistoryCountScore;

    /// There are 6 metrics total
    return (totalPoints / 6).toInt();
  }
}

class _Weights {
  // The remainders should add up to 2
  static double currentRank = 1.15;
  // Diff between all time low and current rank.
  static double overallGain = 1.20;
  // Diff between first recorded rank and last recorded rank
  static double allTimeChange = 1.40;
  static double numDifferentRanks = 1.05;
  static double packageRankHistoryCount = 1.1;
  static double allTimeHighRanking = 1.05;
}
