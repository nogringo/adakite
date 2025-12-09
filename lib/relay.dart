import 'dart:convert';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:network_listener/url.dart';

Future<List<String>> getNetworkRelays() async {
  final env = DotEnv()..load();
  final url = env['RELAYS_ONLINE_URL'];

  if (url == null) {
    throw Exception('RELAYS_ONLINE_URL not set in .env');
  }

  final client = HttpClient();

  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();

    if (response.statusCode == 200) {
      final body = await response.transform(utf8.decoder).join();
      final List<dynamic> relays = jsonDecode(body);
      return relays
          .cast<String>()
          .where((url) => !url.contains('///') && !url.contains('%7c') && !url.contains('|'))
          .map((url) => normalizeUrl(url))
          .whereType<String>()
          .toList();
    }

    return [];
  } finally {
    client.close();
  }
}
