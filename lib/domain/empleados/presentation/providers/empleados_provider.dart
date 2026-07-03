// lib/domain/empleados/presentation/providers/empleados_provider.dart
//
// Reemplaza el provider anterior (que usaba EmpleadosDataSource mock).
//
// Decisión de diseño: "Empleados" no es un módulo separado en el backend —
// es el mismo GET /api/usuarios filtrado por rol en el cliente (cualquier
// rol que no sea Gerente ni Administrador). Por eso reutiliza UsuarioService
// en vez de tener su propio servicio — un solo origen de verdad para la
// lista de personas del sistema.

import 'package:flutter/material.dart';

import '../../../usuarios/data/usuario_service.dart';
import '../../../usuarios/domain/usuario_model.dart';
import '../../../../core/api_client.dart';

class EmpleadosProvider extends ChangeNotifier {
  final UsuarioService _service;

  List<UsuarioModel> _allEmpleados = [];
  List<UsuarioModel> items = [];
  bool isLoading = false;
  String? error;

  EmpleadosProvider({UsuarioService? service})
    : _service = service ?? UsuarioService() {
    load();
  }

  Future<void> load({String q = ''}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final todos = await _service.getUsuarios();
      // Filtro clave: todo rol menos Gerente y Administrador
      _allEmpleados = todos.where((u) => u.esEmpleado).toList();
      _applyFilter(q);
    } on ApiException catch (e) {
      items = [];
      error = e.message;
    } catch (_) {
      items = [];
      error = 'No se pudo cargar los empleados';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void search(String q) {
    _applyFilter(q);
    notifyListeners();
  }

  void _applyFilter(String q) {
    final value = q.trim().toLowerCase();
    if (value.isEmpty) {
      items = _allEmpleados;
      return;
    }
    items = _allEmpleados.where((u) {
      return u.nombreCompleto.toLowerCase().contains(value) ||
          u.numeroDocumento.toLowerCase().contains(value) ||
          (u.rolNombre ?? '').toLowerCase().contains(value);
    }).toList();
  }

  Future<String?> toggleStatus(String id) async {
    try {
      final updated = await _service.toggleStatus(id);
      _allEmpleados = _allEmpleados
          .map((u) => u.id == id ? updated : u)
          .toList();
      _applyFilter('');
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo cambiar el estado';
    }
  }

  Future<String?> deleteEmpleado(String id) async {
    try {
      await _service.deleteUsuario(id);
      _allEmpleados = _allEmpleados.where((u) => u.id != id).toList();
      _applyFilter('');
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo eliminar el empleado';
    }
  }
}
