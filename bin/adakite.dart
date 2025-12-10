import 'package:adakite/utils/normalize_relay_url.dart';
import 'package:dotenv/dotenv.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip01/bip340.dart';
// import 'package:adakite/api_service.dart';
import 'package:adakite/no_event_verifier.dart';
import 'package:adakite/get_online_relays.dart';

void main(List<String> arguments) async {
  final env = DotEnv()..load();

  final storageRelays = env['STORAGE_RELAYS']!
      .split(',')
      .map((e) => e.trim())
      .toList();

  final ndk = Ndk(
    NdkConfig(eventVerifier: NoEventVerifier(), cache: MemCacheManager(), logLevel: LogLevel.off),
  );

  final keyPair = Bip340.generatePrivateKey();
  ndk.accounts.loginPrivateKey(
    pubkey: keyPair.publicKey,
    privkey: keyPair.privateKey!,
  );

  // final apiService = ApiService(baseUrl: 'http://localhost:3001/api');

  List<String> sourceRelays = await getOnlineRelays(
    ndk: ndk,
    sourceRelays: storageRelays,
  );
  for (var relay in storageRelays) {
    sourceRelays.remove(normalizeRelayUrl(relay));
  }

  // List<String> trustedAuthors = await apiService.getTrustedAuthors(maxHops: 10);

  final sub = ndk.requests.subscription(
    filters: [Filter(limit: 0)],
    explicitRelays: sourceRelays,
  );

  sub.stream.listen((event) async {
    // if (!trustedAuthors.contains(event.pubKey)) return;
    ndk.broadcast.broadcast(nostrEvent: event, specificRelays: storageRelays);
  });

  print("Running");
}
