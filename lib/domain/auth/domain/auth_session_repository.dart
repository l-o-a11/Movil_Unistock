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

  /// Nombres de módulo (en minúsculas, ver modulo_constants.dart) a los que
  /// el rol del usuario actual tiene al menos un privilegio asignado.
  /// Se usa para mostrar/ocultar accesos según permisos reales del rol.
  Future<List<String>> getModulosPermitidos();
}