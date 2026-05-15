import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_config.dart';

const _tokenKey = 'auth_token';
const _userKey = 'auth_user';
const _loginTimestampKey = 'auth_login_timestamp';
const _sessionDays = 30;

SharedPreferences? _prefsCache;
Future<SharedPreferences> get _prefs async {
  _prefsCache ??= await SharedPreferences.getInstance();
  return _prefsCache!;
}

Map<String, String> get _jsonHeaders => {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

Map<String, String> _authHeaders(String token) => {
      ..._jsonHeaders,
      'Authorization': 'Bearer $token',
    };
Future<void> saveToken(String token) async {
  final p = await _prefs;
  await p.setString(_tokenKey, token);
}

Future<String?> loadToken() async {
  final p = await _prefs;
  return p.getString(_tokenKey);
}

Future<void> clearToken() async {
  final p = await _prefs;
  await p.remove(_tokenKey);
  await p.remove(_userKey);
  await p.remove(_loginTimestampKey);
}

Future<void> saveUser(Map<String, dynamic> user) async {
  final p = await _prefs;
  await p.setString(_userKey, jsonEncode(user));
}

Future<Map<String, dynamic>?> loadUser() async {
  final p = await _prefs;
  final raw = p.getString(_userKey);
  if (raw == null) return null;
  return jsonDecode(raw) as Map<String, dynamic>;
}

Future<void> saveLoginTimestamp() async {
  final p = await _prefs;
  await p.setInt(
    _loginTimestampKey,
    DateTime.now().toUtc().millisecondsSinceEpoch,
  );
}

Future<bool> isSessionExpired() async {
  final p = await _prefs;
  final ts = p.getInt(_loginTimestampKey);
  if (ts == null) return true;
  final loginTime = DateTime.fromMillisecondsSinceEpoch(ts, isUtc: true);
  return DateTime.now().toUtc().difference(loginTime).inDays >= _sessionDays;
}
Future<AuthResult> register({
  required String name,
  required String email,
  required String password,
}) async {
  final base = ApiConfig.baseUrl;
  final response = await http
      .post(
        Uri.parse('$base/register'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        }),
      )
      .timeout(const Duration(seconds: 60));
  return _parseAuthResponse(response);
}

Future<AuthResult> login({
  required String email,
  required String password,
}) async {
  final base = ApiConfig.baseUrl;
  final response = await http
      .post(
        Uri.parse('$base/login'),
        headers: _jsonHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      )
      .timeout(const Duration(seconds: 60));
  return _parseAuthResponse(response);
}

Future<void> logout(String token) async {
  try {
    final base = ApiConfig.baseUrl;
    await http
        .post(
          Uri.parse('$base/logout'),
          headers: _authHeaders(token),
        )
        .timeout(const Duration(seconds: 30));
  } catch (_) {}
  await clearToken();
}

Future<Map<String, dynamic>> me(String token) async {
  final base = ApiConfig.baseUrl;
  final response = await http
      .get(
        Uri.parse('$base/me'),
        headers: _authHeaders(token),
      )
      .timeout(const Duration(seconds: 10));
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  if (response.statusCode == 200 && body['success'] == true) {
    return body['data'] as Map<String, dynamic>;
  }
  throw AuthException(body['message'] as String? ?? 'Failed to fetch user');
}

Future<Map<String, dynamic>> updateProfile({
  required String token,
  String? name,
  String? bio,
  String? avatarPath,
  bool removeImage = false,
}) async {
  final base = ApiConfig.baseUrl;
  final uri = Uri.parse('$base/profile');
  
  final request = http.MultipartRequest('POST', uri);
  request.headers.addAll({
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  });
  
  if (name != null) request.fields['name'] = name;
  if (bio != null) request.fields['bio'] = bio;
  if (removeImage) request.fields['remove_image'] = '1';
  
  if (avatarPath != null && !removeImage) {
    if (!avatarPath.startsWith('http')) {
      request.files.add(await http.MultipartFile.fromPath('profile_image', avatarPath));
    }
  }
  
  final streamedResponse = await request.send().timeout(const Duration(seconds: 90));
  final response = await http.Response.fromStream(streamedResponse);

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

Future<void> upgradeToPremium(String token) async {
  final base = ApiConfig.baseUrl;
  final response = await http
      .post(
        Uri.parse('$base/upgrade-premium'),
        headers: _authHeaders(token),
        body: jsonEncode({}),
      )
      .timeout(const Duration(seconds: 60));
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  if (response.statusCode != 200 || body['success'] != true) {
    throw AuthException(
      body['message'] as String? ?? 'Failed to upgrade to premium',
    );
  }
}

Future<void> cancelPremium(String token) async {
  final base = ApiConfig.baseUrl;
  final response = await http
      .post(
        Uri.parse('$base/cancel-premium'),
        headers: _authHeaders(token),
        body: jsonEncode({}),
      )
      .timeout(const Duration(seconds: 60));
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  if (response.statusCode != 200 || body['success'] != true) {
    throw AuthException(
      body['message'] as String? ?? 'Failed to cancel premium subscription',
    );
  }
}

Future<void> logRead(String token, int articleId) async {
  final base = ApiConfig.baseUrl;
  await http
      .post(
        Uri.parse('$base/news/$articleId/log-read'),
        headers: _authHeaders(token),
      )
      .timeout(const Duration(seconds: 10));
}

Future<List<Map<String, dynamic>>> fetchBookmarks(String token) async {
  final base = ApiConfig.baseUrl;
  final response = await http
      .get(
        Uri.parse('$base/bookmarks'),
        headers: _authHeaders(token),
      )
      .timeout(const Duration(seconds: 60));
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  if (response.statusCode == 200 && body['success'] == true) {
    return (body['data'] as List).cast<Map<String, dynamic>>();
  }
  return [];
}

Future<void> saveBookmark({
  required String token,
  required int articleId,
  required String title,
  String? source,
  String? summary,
  Map<String, dynamic>? rawData,
}) async {
  final base = ApiConfig.baseUrl;
  await http
      .post(
        Uri.parse('$base/bookmarks'),
        headers: _authHeaders(token),
        body: jsonEncode({
          'article_id': articleId,
          'title': title,
          'source': source,
          'summary': summary,
          'raw_data': rawData,
        }),
      )
      .timeout(const Duration(seconds: 60));
}

Future<void> removeBookmark(String token, int articleId) async {
  final base = ApiConfig.baseUrl;
  await http
      .delete(
        Uri.parse('$base/bookmarks/$articleId'),
        headers: _authHeaders(token),
      )
      .timeout(const Duration(seconds: 10));
}

Future<void> forgotPassword(String email) async {
  final base = ApiConfig.baseUrl;
  final response = await http
      .post(
        Uri.parse('$base/forgot-password'),
        headers: _jsonHeaders,
        body: jsonEncode({'email': email}),
      )
      .timeout(const Duration(seconds: 60));
  
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  if (response.statusCode != 200 || body['success'] != true) {
    throw AuthException(body['message'] as String? ?? 'Failed to send OTP');
  }
}

Future<void> verifyOtp(String email, String otp) async {
  final base = ApiConfig.baseUrl;
  final response = await http
      .post(
        Uri.parse('$base/verify-otp'),
        headers: _jsonHeaders,
        body: jsonEncode({'email': email, 'otp': otp}),
      )
      .timeout(const Duration(seconds: 60));
  
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  if (response.statusCode != 200 || body['success'] != true) {
    throw AuthException(body['message'] as String? ?? 'Invalid OTP');
  }
}

Future<void> resetPassword({
  required String email,
  required String otp,
  required String password,
}) async {
  final base = ApiConfig.baseUrl;
  final response = await http
      .post(
        Uri.parse('$base/reset-password'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': password,
        }),
      )
      .timeout(const Duration(seconds: 60));
  
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  if (response.statusCode != 200 || body['success'] != true) {
    throw AuthException(body['message'] as String? ?? 'Failed to reset password');
  }
}

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
  if (body['errors'] != null) {
    final errors = body['errors'] as Map<String, dynamic>;
    final first = (errors.values.first as List).first as String;
    throw AuthException(first);
  }
  throw AuthException(body['message'] as String? ?? 'An error occurred');
}

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
