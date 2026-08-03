import 'package:flutter/foundation.dart';
import '../data/auth_session_repository_impl.dart';
import '../domain/auth_session_repository.dart';

class AccessController extends ChangeNotifier {
  AccessController({AuthSessionRepository? repository})
    : _repository = repository ?? AuthSessionRepositoryImpl();

  final AuthSessionRepository _repository;

  bool isLoading = false;
  String? error;

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final success = await _repository.login(
        username: username,
        password: password,
      );
      if (!success) {
        error = 'Credenciales inválidas';
      }
      return success;
    } catch (_) {
      error = 'No se pudo iniciar sesión';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.clearSession();
    notifyListeners();
  }
}
