// lib/core/api_client.dart
//
// Cliente HTTP central — equivalente a httpClient.js en la web.
// Toda petición a la API pasa por aquí: agrega el header de autenticación,
// guarda/lee el token de forma segura, y parsea los errores de forma
// consistente con el formato { success, message, data } que ya usa la API.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Excepción específica de la API — incluye el código HTTP para que cada
/// pantalla decida cómo reaccionar (401 → logout, 409 → mostrar mensaje, etc.)
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  // ── Configuración ──────────────────────────────────────────────────────
  // TODO: cuando despliegues la API, cambia esta URL.
  //
  // El valor correcto depende de DÓNDE corres la app:
  //   - Flutter Web (Chrome/Edge, lo que viste en el navegador) → 'http://localhost:3000/api'
  //   - Emulador de Android                                      → 'http://10.0.2.2:3000/api'
  //   - Simulador de iOS                                         → 'http://localhost:3000/api'
  //   - Dispositivo físico (celular real en la misma red WiFi)   → 'http://<IP-de-tu-PC>:3000/api'
  //
  // 10.0.2.2 es una IP especial que SOLO existe dentro del emulador de
  // Android — en un navegador normal no resuelve a nada, por eso daba
  // ERR_CONNECTION_TIMED_OUT al correr en Flutter Web.
  static const String baseUrl = 'http://localhost:3000/api';

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  // ── Token ──────────────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Usuario autenticado ────────────────────────────────────────────────
  // El login (POST /auth/login) ya devuelve el objeto "user" público junto
  // con el token. Lo guardamos para no tener que pedir un GET /auth/me
  // extra solo para precargar la pantalla de "Editar perfil".

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Limpia token y usuario — usar en logout.
  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  // ── Headers ────────────────────────────────────────────────────────────

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ── Parseo de respuesta ────────────────────────────────────────────────
  // La API siempre responde { success: bool, data?: ..., message?: ... }
  // Esta función desenvuelve ese sobre y lanza ApiException si success es false
  // o si el código HTTP indica error.
  dynamic _parseResponse(http.Response response) {
    // 204 No Content (ej: DELETE) — no hay body que parsear
    if (response.statusCode == 204) return null;

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        response.statusCode,
        'Respuesta inválida del servidor',
      );
    }

    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    if (!isSuccess) {
      final message = body['message'] as String? ?? 'Error desconocido';
      throw ApiException(response.statusCode, message);
    }

    return body['data'];
  }

  // ── Métodos HTTP ───────────────────────────────────────────────────────

  Future<dynamic> get(String path, {bool withAuth = true}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http
        .get(uri, headers: await _headers(withAuth: withAuth))
        .timeout(const Duration(seconds: 15));
    return _parseResponse(response);
  }

  Future<dynamic> post(
    String path,
    Map<String, dynamic> body, {
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http
        .post(
          uri,
          headers: await _headers(withAuth: withAuth),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return _parseResponse(response);
  }

  Future<dynamic> put(
    String path,
    Map<String, dynamic> body, {
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http
        .put(
          uri,
          headers: await _headers(withAuth: withAuth),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return _parseResponse(response);
  }

  Future<dynamic> patch(String path, [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http
        .patch(
          uri,
          headers: await _headers(),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 15));
    return _parseResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http
        .delete(uri, headers: await _headers())
        .timeout(const Duration(seconds: 15));
    return _parseResponse(response);
  }
}
