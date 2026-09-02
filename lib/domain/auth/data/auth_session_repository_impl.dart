import '../../../core/api_client.dart';
import '../../roles/domain/rol.dart';
import '../domain/auth_session_repository.dart';

class LoginSessionResult {
  const LoginSessionResult({required this.token, required this.user});

  final String? token;
  final Map<String, dynamic> user;
}

class AuthSessionRepositoryImpl implements AuthSessionRepository {
  final ApiClient _api = ApiClient.instance;

  @override
  Future<String?> getToken() => _api.getToken();

  @override
  Future<void> saveToken(String token) => _api.saveToken(token);

  @override
  Future<void> saveUser(Map<String, dynamic> user) => _api.saveUser(user);

  @override
  Future<Map<String, dynamic>?> getUser() => _api.getUser();

  @override
  Future<void> clearSession() async {
    await _api.clearSession();
    _cachedModulosUserId = null;
    _cachedModulos = null;
  }

  static LoginSessionResult parseLoginSession(dynamic payload) {
    final responseMap = payload is Map<String, dynamic>
        ? payload
        : payload is Map
        ? Map<String, dynamic>.from(payload)
        : <String, dynamic>{};

    final data = responseMap['data'] is Map
        ? Map<String, dynamic>.from(responseMap['data'])
        : <String, dynamic>{};

    final token =
        _extractStringValue(responseMap, [
          'token',
          'accessToken',
          'authToken',
        ]) ??
        _extractStringValue(data, ['token', 'accessToken', 'authToken']);

    final user = _extractUserMap(responseMap, data);

    return LoginSessionResult(token: token, user: user);
  }

  static Map<String, dynamic> _extractUserMap(
    Map<String, dynamic> responseMap,
    Map<String, dynamic> data,
  ) {
    final candidates = <dynamic>[
      responseMap['user'],
      responseMap['usuario'],
      responseMap['userData'],
      data['user'],
      data['usuario'],
      data['userData'],
    ];

    for (final candidate in candidates) {
      if (candidate is Map) {
        return Map<String, dynamic>.from(candidate);
      }
    }

    return <String, dynamic>{};
  }

  static String? _extractStringValue(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
      if (value != null) {
        final stringValue = value.toString();
        if (stringValue.isNotEmpty) {
          return stringValue;
        }
      }
    }
    return null;
  }

  @override
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final normalizedUsername = username.trim();
    final attempts = <Map<String, dynamic>>[
      {'correo': normalizedUsername, 'password': password},
      {'email': normalizedUsername, 'password': password},
      {'username': normalizedUsername, 'password': password},
    ];

    Object? lastError;

    for (final body in attempts) {
      try {
        final payload = await _api.post('/auth/login', body, withAuth: false);
        final parsed = parseLoginSession(payload);

        if (parsed.token != null && parsed.token!.isNotEmpty) {
          await saveToken(parsed.token!);
          await saveUser(parsed.user);
          return true;
        }
      } on ApiException catch (error) {
        lastError = error;
      } catch (error) {
        lastError = error;
      }
    }

    if (lastError is ApiException) {
      throw lastError;
    }

    if (lastError != null) {
      throw Exception(lastError.toString());
    }

    return false;
  }

  @override
  Future<bool> isLoggedIn() => _api.isLoggedIn();

  @override
  Future<String> getRolNombre() async {
    final user = await getUser();
    return (user?['rolNombre'] ?? user?['rol'] ?? '').toString();
  }

  @override
  Future<String?> getUserId() async {
    final user = await getUser();
    return user?['id']?.toString() ?? user?['_id']?.toString();
  }

  // ── Módulos permitidos según el rol ───────────────────────────────────
  // El login solo devuelve rolId/rolNombre, no los permisos del rol. Para
  // saber qué módulos puede ver el usuario se pide una vez GET
  // /auth/me/permissions y se cachea en memoria mientras dure la sesión,
  // para no repetir la petición en cada pantalla que consulta el menú.
  //
  // FIX: antes se pedía el rol completo vía GET /roles/:id (RolService),
  // pero esa ruta exige requirePermission("roles", "leer") en el backend
  // — es decir, solo la puede llamar un usuario cuyo ROL ya tenga acceso
  // al módulo "roles" (Administrador/Gerente). Cualquier Empleado (que
  // por definición no tiene ese módulo) recibía un 403, el catch de abajo
  // lo silenciaba y el menú quedaba vacío ("No tienes módulos asignados"),
  // aunque su rol sí tuviera módulos configurados.
  //
  // /auth/me/permissions solo exige requireAuth (estar logueado) y
  // devuelve los permisos del usuario autenticado sin importar si su rol
  // tiene acceso al módulo "roles", así que es la ruta correcta para esto.
  static String? _cachedModulosUserId;
  static List<String>? _cachedModulos;

  @override
  Future<List<String>> getModulosPermitidos() async {
    final userId = await getUserId();

    if (_cachedModulos != null && _cachedModulosUserId == userId) {
      return _cachedModulos!;
    }

    try {
      final body = await _api.get('/auth/me/permissions');
      final data = body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};
      final rawPermisos = data['permisos'] as List<dynamic>? ?? const [];

      final permisos = rawPermisos
          .whereType<Map>()
          .map((e) => ModuloRol.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final modulos = permisos
          .where((m) => m.privilegios.isNotEmpty)
          .map((m) => m.modulo.trim().toLowerCase())
          .toSet()
          .toList();

      _cachedModulosUserId = userId;
      _cachedModulos = modulos;
      return modulos;
    } catch (_) {
      // Si falla la consulta (sin red, rol eliminado, etc.) no se rompe el
      // menú: simplemente no se muestra ningún módulo restringido.
      return const [];
    }
  }
}