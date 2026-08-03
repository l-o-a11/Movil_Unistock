// lib/domain/usuarios/data/usuario_service.dart
//
// Servicio real — reemplaza UsuariosDataSource (que era 100% mock).
// Usa ApiClient para hablar con GET/POST/PUT/PATCH/DELETE /api/users.

import '../../../core/api_client.dart';
import '../domain/usuario_model.dart';

class UsuarioService {
  final ApiClient _api = ApiClient.instance;

  /// GET /api/users
  /// La API ya filtra por sede según el rol del usuario autenticado
  /// (Gerente ve todo, Administrador ve solo su sede) — no hay que
  /// replicar esa lógica en el cliente.
  Future<List<UsuarioModel>> getUsuarios() async {
    final data = await _api.get('/users') as List<dynamic>;
    return data
        .map((e) => UsuarioModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/users/:id
  Future<UsuarioModel> getUsuarioById(String id) async {
    final data = await _api.get('/users/$id') as Map<String, dynamic>;
    return UsuarioModel.fromJson(data);
  }

  /// PATCH /api/users/:id/status — activa/inactiva.
  /// El backend ya valida que no se pueda desactivar al último admin activo.
  Future<UsuarioModel> toggleStatus(String id) async {
    final data = await _api.patch('/users/$id/status') as Map<String, dynamic>;
    return UsuarioModel.fromJson(data);
  }

  /// DELETE /api/users/:id — devuelve 204, sin body.
  Future<void> deleteUsuario(String id) async {
    await _api.delete('/users/$id');
  }
}
