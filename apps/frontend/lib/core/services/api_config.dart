import 'api_constants.dart';

/// API Configuration — Production Mode
/// Returns hardcoded production URLs synchronously.
/// No SharedPreferences I/O — eliminates per-request disk reads.
class ApiConfig {
  ApiConfig._();

  /// Change this to 'true' to use the local Laravel & ML servers (10.0.2.2)
  /// Change this to 'false' to use the production Render servers.
  static const bool useLocal = false; 

  /// Returns the backend base URL synchronously.
  static String get baseUrl => useLocal ? kLocalBaseUrl : kProdBaseUrl;

  /// Synchronous access (legacy alias).
  static String get baseUrlSync => baseUrl;

  /// Returns the ML service URL synchronously.
  static String get mlServiceUrl => useLocal ? kLocalMlUrl : kProdMlUrl;

  /// Synchronous ML URL access (legacy alias).
  static String get mlServiceUrlSync => mlServiceUrl;

  /// No-op — kept for compatibility.
  static void invalidate() {}

  /// No-op — kept for compatibility.
  static Future<void> clearOverride() async {}
}
