import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'model/package.dart';
import 'model/sheet.dart';

Future<void> writePackageDataToJsonFile(
    String fileName, List<Package> packages) async {
  final packagesAsJson = packages.map((p) => p.toMap()).toList();
  final contents = jsonEncode(packagesAsJson);
  final file = File('$fileName.json');
  await file.writeAsString(contents);
}

Future<List<Package>> loadPackageDataFromFile(String fileName) async {
  final file = File('$fileName.json');
  final contents = await file.readAsString();
  final json = jsonDecode(contents) as List;

  return json.map((packageJson) {
    return Package.fromMap(packageJson);
  }).toList();
}

Future<void> generatePackageAssessmentCsv(String filename, Sheet sheet) async {
  final converter = ListToCsvConverter();
  final asCsv = sheet.packagesToCsv();
  final contents = converter.convert(asCsv);
  final file = File('${filename}_assessment.txt');
  await file.writeAsString(contents);
}

Future<void> generateHistoryCsv(String filename, Sheet sheet) async {
  final converter = ListToCsvConverter();
  final chartFriendlyDataAsCsv = sheet.rankHistoriesToCsv;
  final contents = converter.convert(chartFriendlyDataAsCsv);
  final file = File('${filename}_history.txt');
  await file.writeAsString(contents);
}
