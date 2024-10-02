import 'package:path/path.dart' as p;

class FileNames {
  const FileNames();

  static final String jsonFileExtension = '.json';
  static final String txtFileExtension = '.txt';
  static final String allTimeData = 'assets/all_time_data';
  static final String allTimeOverview = 'assets/all_time_overview';
  static final String allTimeRankHistory = 'assets/all_time_rank_history';
  static final String allTimeMoverScoreHistory =
      'assets/all_time_mover_history';

  static String currentPeriodData(String baseFileName) {
    final strippedFileName = _getFileNameWithoutExtension(baseFileName);
    return '${strippedFileName}_data';
  }

  static String currentPeriodOverview(String baseFileName) {
    final strippedFileName = _getFileNameWithoutExtension(baseFileName);
    return '${strippedFileName}_overview';
  }

  static String currentPeriodRankHistory(String baseFileName) {
    final strippedFileName = _getFileNameWithoutExtension(baseFileName);
    return '${strippedFileName}_rank_history';
  }

  static String currentPeriodMoverScoreHistory(String baseFileName) {
    final strippedFileName = _getFileNameWithoutExtension(baseFileName);
    return '${strippedFileName}_mover_history';
  }

  /// Removes the file extension so the script can generate both JSON and txt
  /// files.
  static String _getFileNameWithoutExtension(String pathArg) {
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
}
