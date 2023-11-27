import 'dart:io' as io;

import 'package:http/http.dart' as http;
import 'package:pub_analytics/package.dart';
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
    // If the file doesn't exist, this is the first time running the script
    if (!file.existsSync()) {
      final packages = createPackageListFromPub(rankedPackageNamesFromPub);
      final packagesAsJson = packages.map((p) => p.toMap()).toList();
      writeJsonToFile(fileName, packagesAsJson);
    } else {}
  } finally {
    client.close();
  }
}
