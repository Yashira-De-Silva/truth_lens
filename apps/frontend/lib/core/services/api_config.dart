import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

/// API Configuration — Production Mode
/// Always uses hardcoded Render production URLs.
/// SharedPreferences cache is CLEARED on startup to prevent stale local URLs.
class ApiConfig {
  ApiConfig._();

  static const _prefKey = 'api_base_url_override';

  /// Returns the production backend base URL.
  /// Always returns the Render production URL, ignoring any cached overrides.
  static Future<String> get baseUrl async {
    // Clear any stale local dev URL override from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    return kBaseUrl;
  }

  /// Returns the production ML service URL.
  static Future<String> get mlServiceUrl async {
    return kMlServiceUrl;
  }

  /// No-op — kept for compatibility.
  static void invalidate() {}

  /// Clears any saved manual override.
  static Future<void> clearOverride() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }
}
