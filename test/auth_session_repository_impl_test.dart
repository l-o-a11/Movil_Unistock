import 'package:flutter_test/flutter_test.dart';
import 'package:movil_unistock/domain/auth/data/auth_session_repository_impl.dart';

void main() {
  group('parseLoginSession', () {
    test('acepta un payload con token y sin user cuando el backend lo devuelve así', () {
      final result = AuthSessionRepositoryImpl.parseLoginSession({
        'token': 'abc123',
        'message': 'ok',
      });

      expect(result.token, 'abc123');
      expect(result.user, isEmpty);
    });

    test('extrae el usuario desde data.user cuando viene anidado', () {
      final result = AuthSessionRepositoryImpl.parseLoginSession({
        'data': {
          'token': 'xyz789',
          'user': {'id': 42, 'correo': 'test@demo.com'},
        },
      });

      expect(result.token, 'xyz789');
      expect(result.user['correo'], 'test@demo.com');
    });
  });
}
