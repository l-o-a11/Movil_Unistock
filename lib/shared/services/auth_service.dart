import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movil_unistock/config/api_config.dart';

String get kAuthBaseUrl => '${ApiConfig.baseUrl}/api';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  String? _cachedToken;

  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    return _cachedToken;
  }

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return jsonDecode(userJson) as Map<String, dynamic>;
  }

  Future<void> clearSession() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      // Backend expects 'correo' field, not 'username'
      final uri = Uri.parse('$kAuthBaseUrl/auth/login');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'correo': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final raw = jsonDecode(response.body);
        final token = raw['data']?['token'] ?? raw['token'];
        final user = raw['data']?['user'] ?? raw['user'];

        if (token != null) {
          await saveToken(token.toString());
          if (user != null) {
            await saveUser(user as Map<String, dynamic>);
          }
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}