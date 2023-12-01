import 'package.dart';

List<List<String>> packagesToCsv(List<Package> packages) {
  final csvList = <List<String>>[
    [
      'Name',
      'All Time High',
      'All Time Low',
      'Change Since Previous',
      'Overall Change',
      'Current Data Date',
      'Current Data Rank',
      'Previous Date',
      'Previous Rank',
      "Continued..."
    ]
  ];

  for (final package in packages) {
    final asCsvRow = package.toCsvRow();
    csvList.add(asCsvRow);
  }

  return csvList;
}
