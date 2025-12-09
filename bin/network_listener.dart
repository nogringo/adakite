import 'package:dotenv/dotenv.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip01/bip340.dart';
// import 'package:network_listener/api_service.dart';
import 'package:network_listener/no_event_verifier.dart';
import 'package:network_listener/relay.dart';
import 'package:network_listener/url.dart';

void main(List<String> arguments) async {
  final env = DotEnv()..load();

  final storageRelays = env['STORAGE_RELAYS']!
      .split(',')
      .map((e) => e.trim())
      .toList();

  // final apiService = ApiService(baseUrl: 'http://localhost:3001/api');

  List<String> sourceRelays = await getNetworkRelays();
  for (var relay in storageRelays) {
    sourceRelays.remove(normalizeUrl(relay));
  }

  // List<String> trustedAuthors = await apiService.getTrustedAuthors(maxHops: 10);

  final ndk = Ndk(
    NdkConfig(
      eventVerifier: NoEventVerifier(),
      cache: MemCacheManager(),
    ),
  );

  final keyPair = Bip340.generatePrivateKey();
  ndk.accounts.loginPrivateKey(
    pubkey: keyPair.publicKey,
    privkey: keyPair.privateKey!,
  );

  final sub = ndk.requests.subscription(
    filters: [Filter(limit: 0)],
    explicitRelays: sourceRelays,
  );

  sub.stream.listen((event) async {
    // if (!trustedAuthors.contains(event.pubKey)) return;
    // print(event.sources);
    ndk.broadcast.broadcast(nostrEvent: event, specificRelays: storageRelays);
  });
}
