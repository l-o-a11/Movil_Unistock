abstract class AuthSessionRepository {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> saveUser(Map<String, dynamic> user);
  Future<Map<String, dynamic>?> getUser();
  Future<void> clearSession();
  Future<bool> login({required String username, required String password});
  Future<bool> isLoggedIn();
  Future<String> getRolNombre();
  Future<String?> getUserId();
}
