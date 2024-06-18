import 'package:pub_analytics/pub_analytics.dart';

import '../model/package.dart';

/// Creates a List of packages from a list of package names, and
/// adds the initial [Ranking] to each [Package.rankHistory].
///
/// This is only used when there is no existing data (the
/// first time this script is run), or if you want to save data to a new file
List<Package> createPackageListFromPub(List<String> orderedPackageNames) {
  final date = DateTime.now();
  final packages = <Package>[];
  for (var i = 0; i < orderedPackageNames.length; i++) {
    packages.add(
      Package.fromPub(
        packageName: orderedPackageNames[i],
        rank: i + 1,
      )..addRankToRankHistory(date, i + 1),
    );
  }

  return packages;
}

Package getPackageWithMostHistoryData(List<Package> packages) {
  final copy = packages;
  copy.sort((a, b) => b.rankHistory.length.compareTo(a.rankHistory.length));
  return copy.first;
}

class Weights {
  static double currentRank = 1.0;
  static double overallGain = 1.0;
  static double allTimeChange = 1.0;
  //
  static double mostCommonRankDiff = 1.1;
  static double numDifferentRanks = 1.0;
  static double packageRankHistoryCount = 1.0;
  static double allTimeHighRanking = 1.0;
  static double allTimeLowRanking = 1.0;
  static double changeSinceLastRanking = 1.0;
}


const int rangeMin = 0;
const int rangeMax = 100;

double convertToNewRange({
  required int oldMax,
  required int oldMin,
   int newMax = rangeMax,
   int newMin = rangeMin,
  required int oldValue,
}) {
  var oldRange = (oldMax - oldMin);
  var newRange = (newMax - newMin);
  var newValue = (((oldValue - oldMin) * newRange) / oldRange) + newMin;
  return newValue;
}

int getPackageMoverScore(
    Package package, int totalHistoryCount, int totalPackageCount) {
  /// For each metric:
  /// * Determine the range of possible numbers (i.e. currentRank range = total package count)
  /// * Convert that range into a common range (0 to totalPackageCount)
  /// * Convert the metric score to that range
  /// * multiple the new metric score by its weight
  ///
  /// Current Rank - Range: totalPackageCount (low) to 0 (high)
  var convertedCurrentRank = convertToNewRange(
    oldMax: 0,
    oldMin: totalPackageCount,
    oldValue: package.currentRank,
  );
  var currentRankScore = convertedCurrentRank * Weights.currentRank;

  /// Overall Gain - Range: 0 (low) to totalPackageCount (high)
  var convertedOverallGain = convertToNewRange(
    oldMax: totalPackageCount,
    oldMin: 0,
    oldValue: package.currentRank,
  );
  var overAllGainScore = convertedOverallGain * Weights.overallGain;

  /// All time change - Range:-totalPackageCount to totalPackageCount
  var convertedAllTimeChange = convertToNewRange(
    oldMax:  totalPackageCount,
    oldMin: -totalPackageCount,
      oldValue: package.allTimeChange);
  var allTimeChangeScore = convertedAllTimeChange * Weights.allTimeChange;

  ///

  var packageHistoryCount = package.rankHistory.length;

  final packageDispersion = package.rankDispersion.entries.toList();
  packageDispersion.sort((a, b) => b.value.compareTo(a.value));
  final numDifferentRanks = packageDispersion.length;

  var baseScore = 0;

  // var mostCommonRankDiffScore =
  //     (package.mostCommonRankDiff / 1000) * Weights.mostCommonRankDiff;
  // var currentRankScore =
  //     ((5000 - package.currentRank) / 1000) * Weights.currentRank;

  var packageHistoryCountRatio = (packageHistoryCount / totalHistoryCount) + 1;
  var packageHistoryCountScore = 2;

  // all scores need to have the same range
  // range is 0..defaultPackageCount (5000)
  // weights add up to 1.0
  // (scoreX * weight) + (scoreY * weight)

  return ((overAllGainScore + allTimeChangeScore + currentRankScore) / 3)
      .toInt();
}
