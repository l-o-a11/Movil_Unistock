import '../../../core/api_client.dart';
import '../domain/auth_session_repository.dart';

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
  Future<void> clearSession() => _api.clearSession();

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

    for (final body in attempts) {
      try {
        final payload = await _api.post('/auth/login', body, withAuth: false);
        final responseMap = payload is Map<String, dynamic>
            ? payload
            : payload is Map
                ? Map<String, dynamic>.from(payload)
                : null;

        if (responseMap == null) continue;

        final token = responseMap['token']?.toString() ??
            responseMap['accessToken']?.toString() ??
            responseMap['data']?['token']?.toString() ??
            responseMap['data']?['accessToken']?.toString();

        final user = responseMap['user'] ??
            responseMap['usuario'] ??
            responseMap['userData'] ??
            responseMap['data']?['user'] ??
            responseMap['data']?['usuario'];

        if (token != null && token.isNotEmpty && user is Map) {
          await saveToken(token);
          await saveUser(Map<String, dynamic>.from(user));
          return true;
        }
      } catch (_) {}
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
}
