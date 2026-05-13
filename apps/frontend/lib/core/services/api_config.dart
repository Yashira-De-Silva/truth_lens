import 'api_constants.dart';

/// API Configuration — Production Mode
/// Returns hardcoded production URLs synchronously.
/// No SharedPreferences I/O — eliminates per-request disk reads.
class ApiConfig {
  ApiConfig._();

  /// Change this to 'true' to use the local Laravel & ML servers (10.0.2.2)
  /// Change this to 'false' to use the production Render servers.
  static const bool useLocal = true; 

  /// Returns the backend base URL.
  static Future<String> get baseUrl async => useLocal ? kLocalBaseUrl : kProdBaseUrl;

  /// Synchronous access — use this instead of await where possible.
  static String get baseUrlSync => useLocal ? kLocalBaseUrl : kProdBaseUrl;

  /// Returns the ML service URL.
  static Future<String> get mlServiceUrl async => useLocal ? kLocalMlUrl : kProdMlUrl;

  /// Synchronous ML URL access.
  static String get mlServiceUrlSync => useLocal ? kLocalMlUrl : kProdMlUrl;

  /// No-op — kept for compatibility.
  static void invalidate() {}

  /// No-op — kept for compatibility.
  static Future<void> clearOverride() async {}
}
