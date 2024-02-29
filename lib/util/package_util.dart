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
