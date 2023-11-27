import 'dart:convert';

import 'package:http/http.dart' as http;

/// This endpoint returns the top 20,000 packages,
/// ordered by their over all rank on pub.dev
/// https://pub.dev/help/api#package-names-for-name-completion
Future<List<String>> getOrderedPackageNames(http.Client client) async {
  final uri = Uri.https('pub.dev', 'api/package-name-completion-data');
  var response = await client.get(uri);
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  return (json['packages'] as List).cast<String>();
}

/// Returns all packages from Pub, in alphabetical order
Future<List<String>> getPackageNames(http.Client client) async {
  final uri = Uri.https('pub.dev', 'api/package-names');
  var response = await client.get(uri);
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  return (json['packages'] as List).cast<String>();
}
