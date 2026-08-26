// lib/domain/auth/data/auth_service.dart
//
// Cubre los endpoints de auth que NO son el login:
//   - POST /auth/forgot-password   (público)
//   - POST /auth/verify-code       (público)
//   - POST /auth/reset-password    (público)
//   - PUT  /auth/profile           (requiere token)
//   - PUT  /auth/change-password   (requiere token)
//
// Todos devuelven { success, data, message } — ApiClient ya desenvuelve
// ese sobre y lanza ApiException si success es false.

import '../../../core/api_client.dart';
import '../domain/auth_user.dart';

class AuthService {
  final ApiClient _api = ApiClient.instance;

  /// Paso 1 del flujo de recuperación — siempre responde igual exista o no
  /// el correo (el backend evita enumeración de usuarios a propósito).
  Future<String> forgotPassword(String correo) async {
    final data =
        await _api.post('/auth/forgot-password', {
              'correo': correo,
            }, withAuth: false)
            as Map<String, dynamic>;
    return data['message'] as String? ??
        'Si el correo existe, recibirás un código';
  }

  /// Paso 2 — valida el código de 6 dígitos y devuelve el resetToken de un
  /// solo uso que se necesita para el paso 3.
  Future<String> verifyCode(String correo, String codigo) async {
    final data =
        await _api.post('/auth/verify-code', {
              'correo': correo,
              'codigo': codigo,
            }, withAuth: false)
            as Map<String, dynamic>;
    return data['resetToken'] as String;
  }

  /// Paso 3 — establece la nueva contraseña usando el resetToken del paso 2.
  Future<String> resetPassword({
    required String resetToken,
    required String password,
    required String confirmarPassword,
  }) async {
    final data =
        await _api.post('/auth/reset-password', {
              'resetToken': resetToken,
              'password': password,
              'confirmarPassword': confirmarPassword,
            }, withAuth: false)
            as Map<String, dynamic>;
    return data['message'] as String? ?? 'Contraseña actualizada correctamente';
  }

  /// Actualiza nombre y/o correo del usuario autenticado.
  /// El backend solo aplica los campos que vengan no-nulos/no-vacíos.
  Future<AuthUser> updateProfile({
    String? nombreCompleto,
    String? correo,
  }) async {
    final body = <String, dynamic>{};
    if (nombreCompleto != null && nombreCompleto.trim().isNotEmpty) {
      body['nombreCompleto'] = nombreCompleto.trim();
    }
    if (correo != null && correo.trim().isNotEmpty) {
      body['correo'] = correo.trim();
    }
    final data = await _api.put('/auth/profile', body) as Map<String, dynamic>;
    final updated = AuthUser.fromJson(data);
    // Mantener sincronizado lo que se muestra en el resto de la app
    // (header del dashboard, etc.) sin esperar a un nuevo login.
    await _api.saveUser(data);
    return updated;
  }

  /// Cambia la contraseña sabiendo la actual (distinto del flujo de "olvidé
  /// mi contraseña", que no la requiere).
  Future<String> changePassword({
    required String passwordActual,
    required String passwordNueva,
    required String confirmarPassword,
  }) async {
    final data =
        await _api.put('/auth/change-password', {
              'passwordActual': passwordActual,
              'passwordNueva': passwordNueva,
              'confirmarPassword': confirmarPassword,
            })
            as Map<String, dynamic>;
    return data['message'] as String? ?? 'Contraseña actualizada correctamente';
  }
}
