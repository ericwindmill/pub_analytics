import 'package:path/path.dart' as p;

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
