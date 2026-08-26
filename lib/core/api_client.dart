// lib/core/api_client.dart
//
// Cliente HTTP centralizado + manejo de sesión (token/usuario).
//
// Contrato que usa el resto de la app:
//   - Todas las respuestas del backend vienen envueltas como
//     { success, data, message }. Este cliente desenvuelve ese sobre:
//     si success es true, get/post/put/patch/delete devuelven SOLO
//     el contenido de "data"; si es false (o el status HTTP no es 2xx),
//     lanza ApiException con el mensaje del backend.
//   - ApiClient.instance es un singleton: todo el mundo comparte el mismo
//     token en memoria/almacenamiento seguro.
//
// FIX (2026): este archivo se sobreescribió por accidente con una versión
// simplificada (sin singleton, sin manejo de sesión) que pertenecía a
// shared/utils/api_client.dart — un archivo DISTINTO con el mismo nombre.
// Reconstruido a partir de cómo lo usan auth_service.dart,
// auth_session_repository_impl.dart, usuario_service.dart,
// product_service.dart y dashboard_data_source.dart.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._internal();

  /// Singleton — todas las pantallas comparten el mismo token/sesión.
  static final ApiClient instance = ApiClient._internal();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  // FIX: faltaba el prefijo /api. Los endpoints en todo el proyecto se
  // escriben sin él (p. ej. '/auth/login', '/users', '/products') porque
  // se espera que baseUrl YA lo incluya — así lo hacen el resto de
  // servicios (ver dashboard_data_source.dart: '${ApiConfig.baseUrl}/api').
  // Sin esto, cualquier petición de auth/usuarios/productos/dashboard le
  // pegaba a "/auth/login" en vez de "/api/auth/login" → 404 ("Ruta
  // /auth/login no encontrada").
  String get baseUrl => '${ApiConfig.baseUrl}/api';

  // ── Sesión ────────────────────────────────────────────────────────────

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> saveUser(Map<String, dynamic> user) =>
      _storage.write(key: _userKey, value: jsonEncode(user));

  Future<Map<String, dynamic>?> getUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Peticiones HTTP ───────────────────────────────────────────────────

  Future<Map<String, String>> _headers({required bool withAuth}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (withAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(String endpoint, {bool withAuth = true}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(
      uri,
      headers: await _headers(withAuth: withAuth),
    );
    return _unwrap(response);
  }

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      uri,
      headers: await _headers(withAuth: withAuth),
      body: jsonEncode(body),
    );
    return _unwrap(response);
  }

  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.put(
      uri,
      headers: await _headers(withAuth: withAuth),
      body: jsonEncode(body),
    );
    return _unwrap(response);
  }

  Future<dynamic> patch(String endpoint, [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.patch(
      uri,
      headers: await _headers(withAuth: true),
      body: body != null ? jsonEncode(body) : null,
    );
    return _unwrap(response);
  }

  Future<dynamic> delete(String endpoint, {bool withAuth = true}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(
      uri,
      headers: await _headers(withAuth: withAuth),
    );
    return _unwrap(response);
  }

  /// Desenvuelve `{ success, data, message }`, o lanza [ApiException] si
  /// el backend respondió con success:false o un status HTTP de error.
  dynamic _unwrap(http.Response response) {
    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }
    }

    final isOk = response.statusCode >= 200 && response.statusCode < 300;

    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);
      final success = map['success'];
      if (success == false || !isOk) {
        final message = (map['message'] as String?)?.trim();
        throw ApiException(
          message?.isNotEmpty == true
              ? message!
              : 'Error del servidor (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
      if (map.containsKey('data')) return map['data'];
      return map;
    }

    if (!isOk) {
      throw ApiException(
        'Error del servidor (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }
}
