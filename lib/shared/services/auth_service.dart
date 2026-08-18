import '../../domain/auth/domain/auth_session_repository.dart';
import '../../domain/auth/data/auth_session_repository_impl.dart';

class AuthService implements AuthSessionRepository {
  AuthService({AuthSessionRepository? repository})
    : _repository = repository ?? AuthSessionRepositoryImpl();

  final AuthSessionRepository _repository;

  @override
  Future<String?> getToken() => _repository.getToken();

  @override
  Future<void> saveToken(String token) => _repository.saveToken(token);

  @override
  Future<void> saveUser(Map<String, dynamic> user) =>
      _repository.saveUser(user);

  @override
  Future<Map<String, dynamic>?> getUser() => _repository.getUser();c

  @override
  Future<void> clearSession() => _repository.clearSession();

  @override
  Future<bool> login({required String username, required String password}) =>
      _repository.login(username: username, password: password);

  @override
  Future<bool> isLoggedIn() => _repository.isLoggedIn();

  @override
  Future<String> getRolNombre() => _repository.getRolNombre();

  @override
  Future<String?> getUserId() => _repository.getUserId();

  @override
  Future<List<String>> getModulosPermitidos() =>
      _repository.getModulosPermitidos();
}