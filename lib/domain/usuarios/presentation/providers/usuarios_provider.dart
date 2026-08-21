// lib/domain/usuarios/presentation/providers/usuarios_provider.dart
//
// Reemplaza el provider anterior (que usaba UsuariosDataSource mock).
// Mismo patrón ChangeNotifier de siempre — solo cambia la fuente de datos.

import 'package:flutter/material.dart';

import '../../data/usuario_service.dart';
import '../../domain/usuario_model.dart';
import '../../../../core/api_client.dart';

const int kUsuariosPageSize = 5;

class UsuariosProvider extends ChangeNotifier {
  final UsuarioService _service;

  List<UsuarioModel> _all = []; // lista completa sin filtrar — cache local
  List<UsuarioModel> items = []; // lista mostrada (filtrada por búsqueda)
  bool isLoading = false;
  String? error;
  String _query = '';
  int _visibleCount = kUsuariosPageSize;

  List<UsuarioModel> get visibleItems => items.take(_visibleCount).toList();
  bool get hasMore => _visibleCount < items.length;

  UsuariosProvider({UsuarioService? service})
    : _service = service ?? UsuarioService() {
    load();
  }

  Future<void> load({String q = ''}) async {
    _query = q;
    _visibleCount = kUsuariosPageSize;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      _all = await _service.getUsuarios();
      _applyFilter(q);
    } on ApiException catch (e) {
      items = [];
      error = e.message;
    } catch (_) {
      items = [];
      error = 'No se pudo cargar los usuarios';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void search(String q) {
    _query = q;
    _visibleCount = kUsuariosPageSize;
    _applyFilter(q);
    notifyListeners();
  }

  void showMore() {
    if (!hasMore) return;
    _visibleCount += kUsuariosPageSize;
    notifyListeners();
  }

  void _applyFilter(String q) {
    final value = q.trim().toLowerCase();
    if (value.isEmpty) {
      items = _all;
      return;
    }
    items = _all.where((u) {
      return u.nombreCompleto.toLowerCase().contains(value) ||
          u.numeroDocumento.toLowerCase().contains(value) ||
          (u.rolNombre ?? '').toLowerCase().contains(value);
    }).toList();
  }

  /// Activa/inactiva un usuario. Devuelve un mensaje de error si falla
  /// (ej: "no se puede desactivar el único administrador activo"),
  /// o null si fue exitoso — la pantalla decide cómo mostrarlo.
  Future<String?> toggleStatus(String id) async {
    try {
      final updated = await _service.toggleStatus(id);
      _all = _all.map((u) => u.id == id ? updated : u).toList();
      _applyFilter(_query);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo cambiar el estado del usuario';
    }
  }

  /// Elimina un usuario. Devuelve un mensaje de error si falla, o null
  /// si fue exitoso.
  Future<String?> deleteUsuario(String id) async {
    try {
      await _service.deleteUsuario(id);
      _all = _all.where((u) => u.id != id).toList();
      _applyFilter(_query);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo eliminar el usuario';
    }
  }
}
