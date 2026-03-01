import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

/// Dynamically resolves the backend base URL at runtime.
///
/// Priority order:
///   1. User-saved override in SharedPreferences (set via debug settings)
///   2. Auto-discovered URL (scans the local subnet for the backend)
///   3. Compile-time constant [kBaseUrl] from api_constants.dart
///
/// Usage:
///   final url = await ApiConfig.baseUrl;     // full base URL
///   ApiConfig.invalidate();                  // force re-discovery next call
class ApiConfig {
  ApiConfig._();

  static const _prefKey = 'api_base_url_override';
  static const _port = 8000;
  static const _timeoutMs = 1500;

  static String? _cached;

  /// Returns the resolved base URL (e.g. `http://192.168.1.110:8000/api`).
  /// Caches the result for the lifetime of the app process.
  static Future<String> get baseUrl async {
    if (_cached != null) return _cached!;

    // 1. Check for a saved override (set manually or via settings screen)
    final prefs = await SharedPreferences.getInstance();
    final override = prefs.getString(_prefKey);
    if (override != null && override.isNotEmpty) {
      _cached = override;
      return _cached!;
    }

    // 2. Try to auto-discover the backend on the local network
    final discovered = await _discover();
    if (discovered != null) {
      _cached = discovered;
      return _cached!;
    }

    // 3. Fall back to the compile-time constant
    _cached = kBaseUrl;
    return _cached!;
  }

  /// Clears the cached URL so [baseUrl] re-resolves on next call.
  static void invalidate() => _cached = null;

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
  /// checking port 8000 on each host. Returns the first responding URL.
  static Future<String?> _discover() async {
    try {
      // Get the device's own LAN IP to determine subnet
      final subnet = await _getSubnet();
      if (subnet == null) return null;

      // First try the compile-time constant IP directly (fastest path)
      final knownIp = _extractIp(kBaseUrl);
      if (knownIp != null) {
        final knownUrl = 'http://$knownIp:$_port/api';
        if (await _isReachable(knownIp)) return knownUrl;
      }

      // Scan the whole /24 subnet in parallel
      final futures = List.generate(254, (i) {
        final host = '$subnet.${i + 1}';
        return _isReachable(host).then((ok) => ok ? host : null);
      });

      final results = await Future.wait(futures);
      final hit = results.firstWhere((r) => r != null, orElse: () => null);
      if (hit != null) return 'http://$hit:$_port/api';
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

  /// Tries to open a TCP socket to [host]:8000 within the timeout.
  static Future<bool> _isReachable(String host) async {
    try {
      final socket = await Socket.connect(
        host,
        _port,
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
