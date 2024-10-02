import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:pub_analytics/util/path_util.dart';
import 'model/package.dart';
import 'model/sheet.dart';

Future<void> writePackageDataToJsonFile(
  String fileName,
  List<Package> packages,
) async {
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

Future<void> writePackageOverviewToCSV(
  String filename,
  Sheet sheet,
) async {
  final converter = ListToCsvConverter();
  final asCsv = sheet.packagesToCsv();
  final contents = converter.convert(asCsv);
  final file = File('$filename.txt');
  await file.writeAsString(contents);
}

Future<void> writeRankHistoryCsv(
  String fileName,
  Sheet sheet,
) async {
  final converter = ListToCsvConverter();
  final dataAsCsv = sheet.rankHistoriesToCsv;
  final contents = converter.convert(dataAsCsv);
  final file = File('$fileName${FileNames.txtFileExtension}');
  await file.writeAsString(contents);
}

Future<void> writeMoverScoreHistoryCsv(
  String fileName,
  Sheet sheet,
) async {
  final converter = ListToCsvConverter();
  final dataAsCsv = sheet.moverScoreHistoriesToCsv;
  final contents = converter.convert(dataAsCsv);
  final file = File('$fileName${FileNames.txtFileExtension}');
  await file.writeAsString(contents);
}
