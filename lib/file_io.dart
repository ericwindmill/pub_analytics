import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';

import 'csv.dart';
import 'package.dart';

Future<void> writePackagesToJsonFile(
    String fileName, List<Package> packages) async {
  final packagesAsJson = packages.map((p) => p.toMap()).toList();
  final contents = jsonEncode(packagesAsJson);
  final file = File('$fileName.json');
  await file.writeAsString(contents);
}

Future<List<Package>> loadPackagesFromFile(String fileName) async {
  final file = File('$fileName.json');
  final contents = await file.readAsString();
  final json = jsonDecode(contents) as List;

  return json.map((packageJson) {
    return Package.fromMap(packageJson);
  }).toList();
}

Future<void> writePackagesToCsvFile(
    String filename, List<Package> packages) async {
  final asCsv = packagesToCsv(packages);
  final contents = ListToCsvConverter().convert(asCsv);
  final file = File('$filename.txt');
  await file.writeAsString(contents);
}
