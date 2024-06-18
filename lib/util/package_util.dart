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
  static double overAllGain = 1.2;
  static double allTimeChange = 1.3;
  static double mostCommonRankDiff = 1.1;
  static double currentRank = 1.1;
}

int getPackageMoverScore(Package package, int totalHistoryCount) {
  var packageHistoryCount = package.rankHistory.length;
  final packageDispersion = package.rankDispersion.entries.toList();
  packageDispersion.sort((a, b) => b.value.compareTo(a.value));
  final numDifferentRanks = packageDispersion.length;

  // // compare numDifferentRanks, package num rankings, and totalNumRankings
  // // In general, more different ranks and more ranks in general means the rise is stable
  // Map<String, double> weights = {
  //   'allTimeChange': 1.3,
  //   'overallGain': 1.2,
  //   'mostCommonRankDiff': 1.1,
  //   'numDifferentRanks': 1.1,
  //   'packageHistoryCount': 1.1,
  //   'currentRank': 1.1,
  //   'allTimeHighRanking': 1,
  //   'allTimeLowRanking': 1,
  //   'changeSinceLastRanking': 1,
  // };

  var baseScore = 0;
  var overAllGainScore = (package.overallGain / 1000) * Weights.overAllGain;
  var allTimeChangeScore =
      (package.allTimeChange / 1000) * Weights.allTimeChange;
  // var mostCommonRankDiffScore =
  //     (package.mostCommonRankDiff / 1000) * Weights.mostCommonRankDiff;
  var currentRankScore =
      ((5000 - package.currentRank) / 1000) * Weights.currentRank;

  var packageHistoryCountRatio = (packageHistoryCount / totalHistoryCount) + 1;
  var packageHistoryCountScore = 2;

  // all scores need to have the same range
  // range is 0..defaultPackageCount (5000)
  // weights add up to 1.0
  // (scoreX * weight) + (scoreY * weight)

  return (overAllGainScore +
          allTimeChangeScore +
          currentRankScore)
      .toInt();


}


