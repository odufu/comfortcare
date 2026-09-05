abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // Defaulting to true in local/cross-platform environment; can integrate connectivity_plus when needed
    return true;
  }
}
