import '../model/package.dart';

Package getPackageWithMostHistoryData(List<Package> packages) {
  final copy = packages;
  copy.sort((a, b) => b.rankHistory.length.compareTo(a.rankHistory.length));
  return copy.first;
}
