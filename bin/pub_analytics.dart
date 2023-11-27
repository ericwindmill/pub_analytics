import 'dart:io' as io;

import 'package:http/http.dart' as http;
import 'package:pub_analytics/pub_analytics.dart';

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    throw ArgumentError('A filename must be provided');
  }

  final fileName = arguments[0];
  final client = http.Client();

  try {
    final rankedPackageNamesFromPub =
        await getOrderedPackageNames(client).then((packages) {
      return packages.take(300).toList();
    });

    final file = io.File(fileName);
    // If the file doesn't exist, this is the first time collecting this data
    if (!file.existsSync()) {
      final packages = createPackageListFromPub(rankedPackageNamesFromPub);
      final packagesAsJson = packages.map((p) => p.toMap()).toList();
      writeJsonToFile(fileName, packagesAsJson);
    } else {
      // If the file does exist, load the rank history data and add the new
      // ranking data
      final packages = await loadPackagesFromFile(fileName);
      final now = DateTime.now();
      for (var i = 0; i < rankedPackageNamesFromPub.length; i++) {
        final package = packages.firstWhere(
            (element) => element.name == rankedPackageNamesFromPub[i],
            orElse: () {
          // If there isn't data for this package, create a new package object
          // and add it to the packages list
          final package = Package.withCurrentRanking(
            packageName: rankedPackageNamesFromPub[i],
            rank: i + 1,
            now: now,
          );
          packages.add(package);
          return package;
        });
        package.addRankToRankHistory(now, i + 1);
      }
      packages.sort((a, b) => a.currentRank.compareTo(b.currentRank));
      final packagesAsJson = packages.map((p) => p.toMap()).toList();
      writeJsonToFile(fileName, packagesAsJson);
    }
  } finally {
    client.close();
  }
}
