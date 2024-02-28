import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';

import 'csv.dart';
import 'model/package.dart';
import 'model/sheet.dart';

Future<void> writePackagesToJsonFile(
    String fileName, List<Package> packages) async {
  final packagesAsJson = packages.map((p) => p.toMap()).toList();
  final contents = jsonEncode(packagesAsJson);
  final file = File('${fileName}_test.json');
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
  bool withChart = true,
}) async {
  final Sheet sheet = Sheet(packages);

  final converter = ListToCsvConverter();
  final asCsv = packagesToCsv(packages);
  final contents = converter.convert(asCsv);
  final file = File('${filename}_assessment.txt');
  await file.writeAsString(contents);

  if (withHistory) {
    final historyAsCsv = rankHistoriesToCSV(packages);
    final contents = converter.convert(historyAsCsv);
    final file = File('${filename}_history.txt');
    await file.writeAsString(contents);
  }

  if (withChart) {
    final chartFriendlyDataAsCsv = sheet.csvChartData;
    final contents = converter.convert(chartFriendlyDataAsCsv);
    final file = File('${filename}_history_for_chart.txt');
    await file.writeAsString(contents);
  }
}
