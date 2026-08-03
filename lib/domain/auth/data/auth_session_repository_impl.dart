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
    try {
      final data =
          await _api.post('/auth/login', {
                'correo': username,
                'password': password,
              }, withAuth: false)
              as Map<String, dynamic>;
      final token = data['token']?.toString();
      final user = data['user'];
      if (token != null && token.isNotEmpty && user is Map<String, dynamic>) {
        await saveToken(token);
        await saveUser(user);
        return true;
      }
    } catch (_) {}
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
