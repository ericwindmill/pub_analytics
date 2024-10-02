import 'package:path/path.dart' as p;

class FileNames {
  const FileNames();

  static final String _allTimeFilePrefix = 'all_time';
  static final String _moverScoreHistoryFileName = 'mover_score_history';
  static final String _rankHistoryFileName = 'rank_history';

  static final String jsonFileExtension = '.json';
  static final String txtFileExtension = '.txt';

  static final String allTimeRankHistory =
      '$_allTimeFilePrefix$_rankHistoryFileName';

  static final String allTimeMoverScoreHistory =
      '$_allTimeFilePrefix$_moverScoreHistoryFileName';

  static String currentRankHistory(String baseFileName) =>
      '$baseFileName$_rankHistoryFileName';

  static String currentMoverScoreHistory(String baseFileName) =>
      '$baseFileName$_moverScoreHistoryFileName';
}

/// Removes the file extension so the script can generate both JSON and txt
/// files.
String getFileNameWithoutExtension(String pathArg) {
  // Removes any leading dots, i.e. to denote the current location
  final normalized = p.normalize(pathArg);

  final startIndexOfExtension = normalized.lastIndexOf('.');
  if (startIndexOfExtension == -1) {
    return pathArg;
  } else {
    final extension = normalized.substring(startIndexOfExtension);
    if (extension != '.json' && extension != '.txt') {
      throw ArgumentError("Only .json and .txt files are supported");
    } else {
      return normalized.substring(0, startIndexOfExtension);
    }
  }
}
