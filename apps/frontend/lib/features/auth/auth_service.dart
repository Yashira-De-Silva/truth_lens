import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Base URL of the Laravel backend.
/// Uses the Mac's LAN IP so real Android/iOS devices on the same Wi-Fi can reach it.
const String _baseUrl = 'http://192.168.1.220:8000/api';

const _tokenKey = 'auth_token';
const _userKey = 'auth_user';

// ── Helpers ──────────────────────────────────────────────────────────────────

Map<String, String> get _jsonHeaders => {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

Map<String, String> _authHeaders(String token) => {
      ..._jsonHeaders,
      'Authorization': 'Bearer $token',
    };

// ── Token persistence ────────────────────────────────────────────────────────

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_tokenKey, token);
}

Future<String?> loadToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_tokenKey);
}

Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_tokenKey);
  await prefs.remove(_userKey);
}

Future<void> saveUser(Map<String, dynamic> user) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_userKey, jsonEncode(user));
}

Future<Map<String, dynamic>?> loadUser() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_userKey);
  if (raw == null) return null;
  return jsonDecode(raw) as Map<String, dynamic>;
}

// ── API calls ────────────────────────────────────────────────────────────────

/// Registers a new user. Returns the JWT token string on success.
/// Throws [AuthException] on failure.
Future<AuthResult> register({
  required String name,
  required String email,
  required String password,
}) async {
  final response = await http
      .post(
        Uri.parse('$_baseUrl/register'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      )
      .timeout(const Duration(seconds: 15));

  return _parseAuthResponse(response);
}

/// Logs in an existing user. Returns the JWT token string on success.
/// Throws [AuthException] on failure.
Future<AuthResult> login({
  required String email,
  required String password,
}) async {
  final response = await http
      .post(
        Uri.parse('$_baseUrl/login'),
        headers: _jsonHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      )
      .timeout(const Duration(seconds: 15));

  return _parseAuthResponse(response);
}

/// Logs out and invalidates the server-side token.
Future<void> logout(String token) async {
  try {
    await http
        .post(
          Uri.parse('$_baseUrl/logout'),
          headers: _authHeaders(token),
        )
        .timeout(const Duration(seconds: 10));
  } catch (_) {
    // Even if the request fails, clear locally.
  }
  await clearToken();
}

/// Fetches the currently authenticated user's profile.
Future<Map<String, dynamic>> me(String token) async {
  final response = await http
      .get(
        Uri.parse('$_baseUrl/me'),
        headers: _authHeaders(token),
      )
      .timeout(const Duration(seconds: 10));

  final body = jsonDecode(response.body) as Map<String, dynamic>;
  if (response.statusCode == 200 && body['success'] == true) {
    return body['data'] as Map<String, dynamic>;
  }
  throw AuthException(body['message'] as String? ?? 'Failed to fetch user');
}

/// Updates name and/or bio for the authenticated user.
Future<Map<String, dynamic>> updateProfile({
  required String token,
  String? name,
  String? bio,
}) async {
  final payload = <String, dynamic>{};
  if (name != null) payload['name'] = name;
  if (bio != null) payload['bio'] = bio;

  final response = await http
      .put(
        Uri.parse('$_baseUrl/profile'),
        headers: _authHeaders(token),
        body: jsonEncode(payload),
      )
      .timeout(const Duration(seconds: 15));

  final body = jsonDecode(response.body) as Map<String, dynamic>;
  if (response.statusCode == 200 && body['success'] == true) {
    return body['data'] as Map<String, dynamic>;
  }
  if (body['errors'] != null) {
    final errors = body['errors'] as Map<String, dynamic>;
    final first = (errors.values.first as List).first as String;
    throw AuthException(first);
  }
  throw AuthException(body['message'] as String? ?? 'Failed to update profile');
}

// ── Internal helpers ─────────────────────────────────────────────────────────

AuthResult _parseAuthResponse(http.Response response) {
  final body = jsonDecode(response.body) as Map<String, dynamic>;

  if ((response.statusCode == 200 || response.statusCode == 201) &&
      body['success'] == true) {
    final data = body['data'] as Map<String, dynamic>;
    return AuthResult(
      token: data['token'] as String,
      user: data['user'] as Map<String, dynamic>,
    );
  }

  // Validation errors (422)
  if (body['errors'] != null) {
    final errors = body['errors'] as Map<String, dynamic>;
    final first = (errors.values.first as List).first as String;
    throw AuthException(first);
  }

  throw AuthException(body['message'] as String? ?? 'An error occurred');
}

// ── Value objects ─────────────────────────────────────────────────────────────

class AuthResult {
  final String token;
  final Map<String, dynamic> user;
  const AuthResult({required this.token, required this.user});
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}
