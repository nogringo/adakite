String normalizeRelayUrl(String url) {
  try {
    var uri = Uri.parse(url.trim());

    // Case normalization (6.2.2.1) - scheme and host to lowercase
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();

    // Port normalization - remove default ports
    var port = uri.port;
    if ((scheme == 'wss' && port == 443) || (scheme == 'ws' && port == 80)) {
      port = 0;
    }

    // Path normalization (6.2.2.3) - remove trailing slashes
    var path = uri.path;
    while (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    uri = Uri(
      scheme: scheme,
      host: host,
      port: port == 0 ? null : port,
      path: path.isEmpty ? null : path,
      query: uri.query.isEmpty ? null : uri.query,
    );

    return uri.toString();
  } catch (e) {
    return url.trim().toLowerCase();
  }
}
