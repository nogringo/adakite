import 'dart:convert';

import 'package:adakite/utils/normalize_relay_url.dart';
import 'package:ndk/ndk.dart';

/// Fetches online relays from breccia's kind 6301 DVM result event
Future<List<String>> getOnlineRelays({
  required Ndk ndk,
  required List<String> sourceRelays,
}) async {
  final query = ndk.requests.query(
    filters: [
      Filter(kinds: [6301], limit: 1),
    ],
    explicitRelays: sourceRelays,
  );

  final events = await query.future;

  events.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  final List<dynamic> relays = jsonDecode(events.first.content);
  return relays
      .cast<String>()
      .where(
        (url) =>
            !url.contains('///') && !url.contains('%7c') && !url.contains('|'),
      )
      .map((url) => normalizeRelayUrl(url))
      .whereType<String>()
      .toList();
}
