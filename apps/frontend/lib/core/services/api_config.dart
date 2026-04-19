import 'api_constants.dart';

/// API Configuration — Production Mode
/// Returns hardcoded production URLs synchronously.
/// No SharedPreferences I/O — eliminates per-request disk reads.
class ApiConfig {
  ApiConfig._();

  /// Returns the production backend base URL synchronously.
  static Future<String> get baseUrl async => kBaseUrl;

  /// Synchronous access — use this instead of await where possible.
  static String get baseUrlSync => kBaseUrl;

  /// Returns the production ML service URL synchronously.
  static Future<String> get mlServiceUrl async => kMlServiceUrl;

  /// Synchronous ML URL access.
  static String get mlServiceUrlSync => kMlServiceUrl;

  /// No-op — kept for compatibility.
  static void invalidate() {}

  /// No-op — kept for compatibility.
  static Future<void> clearOverride() async {}
}
