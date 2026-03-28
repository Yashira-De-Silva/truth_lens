import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class ApiConfig {
  ApiConfig._();

  static const _prefKey = 'api_base_url_override';
  static const _port = 8000;
  static const _mlPort = 5001;
  static const _timeoutMs = 1500;

  static String? _cached;
  static String? _mlCached;

  static Future<String> get baseUrl async {
    if (_cached != null) return _cached!;

    final prefs = await SharedPreferences.getInstance();
    final override = prefs.getString(_prefKey);
    if (override != null && override.isNotEmpty) {
      _cached = override;
      return _cached!;
    }

    final discovered = await _discoverHost(port: _port);
    if (discovered != null) {
      _cached = 'http://$discovered:$_port/api';
      return _cached!;
    }

    // 3. Fall back to the compile-time constant
    _cached = kBaseUrl;
    return _cached!;
  }

  /// Returns the resolved ML service URL (e.g. `http://192.168.1.110:5001`).
  static Future<String> get mlServiceUrl async {
    if (_mlCached != null) return _mlCached!;

    // Try the known IP from the compile-time constant first (fastest path)
    final knownIp = _extractIp(kMlServiceUrl);
    if (knownIp != null && await _isReachable(knownIp, _mlPort)) {
      _mlCached = 'http://$knownIp:$_mlPort';
      return _mlCached!;
    }

    // Auto-discover on port 5001
    final discovered = await _discoverHost(port: _mlPort);
    if (discovered != null) {
      _mlCached = 'http://$discovered:$_mlPort';
      return _mlCached!;
    }

    // Fall back to compile-time constant
    _mlCached = kMlServiceUrl;
    return _mlCached!;
  }

  /// Clears the cached URLs so [baseUrl] and [mlServiceUrl] re-resolve on next call.
  static void invalidate() {
    _cached = null;
    _mlCached = null;
  }

  /// Saves a manual URL override that persists across app restarts.
  static Future<void> setOverride(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, url.trim());
    _cached = url.trim();
  }

  /// Clears any saved manual override.
  static Future<void> clearOverride() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    _cached = null;
  }

  // ── Private: LAN discovery ──────────────────────────────────────────────

  /// Scans the device's own subnet (e.g. 192.168.1.x) in parallel,
  /// checking [port] on each host. Returns the first responding IP.
  static Future<String?> _discoverHost({required int port}) async {
    try {
      final subnet = await _getSubnet();
      if (subnet == null) return null;

      // Try the compile-time constant IP first (fastest path)
      final knownIp = _extractIp(port == _port ? kBaseUrl : kMlServiceUrl);
      if (knownIp != null && await _isReachable(knownIp, port)) return knownIp;

      // Scan the whole /24 subnet in parallel
      final futures = List.generate(254, (i) {
        final host = '$subnet.${i + 1}';
        return _isReachable(host, port).then((ok) => ok ? host : null);
      });

      final results = await Future.wait(futures);
      return results.firstWhere((r) => r != null, orElse: () => null);
    } catch (_) {}
    return null;
  }

  /// Gets the first three octets of the device's LAN IP (e.g. "192.168.1").
  static Future<String?> _getSubnet() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final ip = addr.address;
          if (!ip.startsWith('127.') && !ip.startsWith('169.254.')) {
            final parts = ip.split('.');
            if (parts.length == 4) return '${parts[0]}.${parts[1]}.${parts[2]}';
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Tries to open a TCP socket to [host]:[port] within the timeout.
  static Future<bool> _isReachable(String host, int port) async {
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: Duration(milliseconds: _timeoutMs),
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Extracts the IP from a URL like `http://192.168.1.110:8000/api`.
  static String? _extractIp(String url) {
    final match = RegExp(r'http://(\d+\.\d+\.\d+\.\d+)').firstMatch(url);
    return match?.group(1);
  }
}
