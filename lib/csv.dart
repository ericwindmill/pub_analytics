import 'model/package.dart';

List<List<String>> packagesToCsv(List<Package> packages) {
  final csvAssessmentData = <List<String>>[
    [
      'Name',
      'Current rank',
      'Change since previous',
      'Overall gain',
      'All time change',
      'All time high',
      'All time low',
      'Most common rank',
      'Most common rank occurrence',
      'Second most common rank',
      'Second most common rank occurrence',
      'Continued...',
    ],
  ];

  for (final package in packages) {
    final asCsvRow = packageToCsvRow(package);
    csvAssessmentData.add(asCsvRow);
  }

  return csvAssessmentData;
}

List<List<String>> rankHistoriesToCSV(List<Package> packages) {
  final csvRankHistory = <List<String>>[
    [
      'Name',
      'Current rank',
      'Current data date',
      'Current data rank',
      'Previous date',
      'Previous rank',
      "Continued..."
    ],
  ];

  for (final package in packages) {
    final historyAsCsvRow = packageRankHistoryToCsvRow(package);
    csvRankHistory.add(historyAsCsvRow);
  }

  return csvRankHistory;
}

/// Data is formatted differently, in order to easily make line charts in Sheets
///
/// Order of operations:
/// 1. Find package with the most rank history data
/// 2. Create the date list from that data

List<String> packageToCsvRow(Package package) {
  final rankDispersionToCsv = <String>[];
  final sortedDispersion = Map.fromEntries(
      package.rankDispersion.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)));
  sortedDispersion.forEach((key, value) {
    rankDispersionToCsv.addAll([
      key.toString(),
      value.toString(),
    ]);
  });

  return [
    package.name,
    package.currentRank.toString(),
    package.changeSinceLastRanking.toString(),
    package.overallGain.toString(),
    package.allTimeChange.toString(),
    package.allTimeHighRanking.toString(),
    package.allTimeLowRanking.toString(),
    ...rankDispersionToCsv,
  ];
}

List<String> packageRankHistoryToCsvRow(Package package) {
  final historyToCsv = <String>[];
  for (var ranking in package.rankHistory) {
    historyToCsv.addAll(
      [
        '${ranking.date.month}/${ranking.date.day}/${ranking.date.year}',
        ranking.rank.toString(),
      ],
    );
  }

  return [
    package.name,
    package.currentRank.toString(),
    ...historyToCsv,
  ];
}
