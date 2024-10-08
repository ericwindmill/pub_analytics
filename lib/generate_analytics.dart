import 'dart:io' as io;

import 'package:pub_analytics/util/package_util.dart';

import 'file_io.dart';
import 'model/package.dart';

/// Combines the newest data from pub.dev API with the
/// existing data in the JSON file 'database'
Future<List<Package>> generateAnalytics({
  required String fileName,
  required List<String> newPubData,
}) async {
  return _addNewPubDataToPackages(fileName, newPubData);
}

Future<List<Package>> _addNewPubDataToPackages(
    String fileName, List<String> newPubData) async {
  final fileExists = await io.File('$fileName.json').exists();
  if (fileExists) {
    var localPackages = await loadPackageDataFromFile(fileName);
    return _updateAllPackagesWithPubData(localPackages, newPubData);
  } else {
    return createPackageListFromPub(newPubData);
  }
}

/// For each package, add current rank from Pb API to package history
List<Package> _updateAllPackagesWithPubData(
  List<Package> existingLocalData,
  List<String> newPubData,
) {
  final updatedPackageList = <Package>[];
  final now = DateTime.now();
  for (var i = 0; i < newPubData.length; i++) {
    //
    final Package package = existingLocalData.firstWhere(
      (element) => element.name == newPubData[i],
      orElse: () {
        // If there isn't data for this package, create a new package object
        final package = Package.fromPub(
          packageName: newPubData[i],
          rank: i + 1,
        );
        return package;
      },
    );

    package.addRankToRankHistory(now, i + 1);
    updatedPackageList.add(package);
  }

  // Add mover score to package history
  final totalPackageCount = updatedPackageList.length;
  final totalHistoryCount =
      getPackageWithMostHistoryData(updatedPackageList).rankHistory.length;
  for (var package in updatedPackageList) {
    package.addMoverScoreToHistory(now, totalHistoryCount, totalPackageCount);
  }

  return updatedPackageList;
}
