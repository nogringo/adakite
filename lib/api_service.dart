import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = 'http://localhost:3001/api'});

  /// Fetches all trusted authors (pubkeys) from the API.
  /// These are all non-blacklisted pubkeys in the trust network.
  ///
  /// [maxHops] - Maximum distance from seeds (default: 3)
  /// Returns a list of hex pubkeys
  Future<List<String>> getTrustedAuthors({int maxHops = 3}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trust/all?maxHops=$maxHops'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pubkeys = List<String>.from(data['pubkeys'] ?? []);
        return pubkeys;
      } else {
        throw Exception('Failed to fetch trusted authors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching trusted authors: $e');
      rethrow;
    }
  }

  /// Fetches pubkeys within a certain number of hops from seeds,
  /// along with their distance information.
  ///
  /// [maxHops] - Maximum distance from seeds (default: 3)
  /// Returns a list of maps with 'hex' and 'minDistance' keys
  Future<List<Map<String, dynamic>>> getReachablePubkeys({int maxHops = 3}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trust/reachable?maxHops=$maxHops'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pubkeys = List<Map<String, dynamic>>.from(data['pubkeys'] ?? []);
        return pubkeys;
      } else {
        throw Exception('Failed to fetch reachable pubkeys: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching reachable pubkeys: $e');
      rethrow;
    }
  }

  /// Fetches all seed pubkeys (fully trusted).
  /// Returns a list of seed pubkey records
  Future<List<Map<String, dynamic>>> getSeeds() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/seeds'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final seeds = List<Map<String, dynamic>>.from(data['seeds'] ?? []);
        return seeds;
      } else {
        throw Exception('Failed to fetch seeds: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching seeds: $e');
      rethrow;
    }
  }

  /// Fetches all blacklisted pubkeys.
  /// Returns a list of blacklisted pubkey records
  Future<List<Map<String, dynamic>>> getBlacklist() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/blacklist'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final blacklist = List<Map<String, dynamic>>.from(data['blacklist'] ?? []);
        return blacklist;
      } else {
        throw Exception('Failed to fetch blacklist: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching blacklist: $e');
      rethrow;
    }
  }

  /// Checks if the API is reachable
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl.replaceAll('/api', '/health')),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
