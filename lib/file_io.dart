import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';

import 'package.dart';

Future<void> writeJsonToFile(String fileName, dynamic json) async {
  final contents = jsonEncode(json);
  final file = File('$fileName.json');
  await file.writeAsString(contents);
}

Future<List<Package>> loadPackagesFromFile(String fileName) async {
  final file = File(fileName);
  final contents = await file.readAsString();
  final json = jsonDecode(contents) as List;

  return json.map((packageJson) {
    return Package.fromMap(packageJson);
  }).toList();
}

Future<void> writeCsvToFile(String filename, List<List<String>> csv) async {
  final contents = ListToCsvConverter().convert(csv);
  final file = File('$filename.txt');
  await file.writeAsString(contents);
}
