String? normalizeUrl(String url) {
  try {
    var normalized = url.trim().toLowerCase();

    // Must be a websocket URL
    if (!normalized.startsWith('wss://') && !normalized.startsWith('ws://')) {
      return null;
    }

    // Remove trailing slash
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    return normalized;
  } catch (e) {
    return null;
  }
}
