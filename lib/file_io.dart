import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'model/package.dart';
import 'model/sheet.dart';

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
  String filename,
  List<Package> packages, {
  bool withHistory = true,
}) async {
  /// Todo: this class should take care of all CSV generation
  final Sheet sheet = Sheet(packages);

  final converter = ListToCsvConverter();
  final asCsv = sheet.packagesToCsv();
  final contents = converter.convert(asCsv);
  final file = File('${filename}_assessment.txt');
  await file.writeAsString(contents);

  if (withHistory) {
    final chartFriendlyDataAsCsv = sheet.rankHistoriesToCsv;
    final contents = converter.convert(chartFriendlyDataAsCsv);
    final file = File('${filename}_history.txt');
    await file.writeAsString(contents);
  }
}
