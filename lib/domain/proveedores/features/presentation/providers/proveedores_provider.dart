import 'package:flutter/material.dart';
import '../../domain/entities/proveedor_entity.dart';
import '../../data/services/proveedores_api_service.dart';

/// Proveedor de estado para la lista de proveedores.
/// 
/// Gestiona:
/// - Carga de proveedores desde [ProveedoresApiService]
/// - Búsqueda de texto
/// - Estados de carga y error
/// 
/// Propiedades públicas:
/// - [items]: lista de proveedores
/// - [isLoading]: indica carga en progreso
/// - [error]: mensaje de error (null si no hay error)
class ProveedoresProvider extends ChangeNotifier {
  final ProveedoresApiService _apiService;
  List<ProveedorEntity> items = [];
  bool isLoading = true;
  String? error;
  String _q = '';

  ProveedoresProvider({ProveedoresApiService? apiService})
      : _apiService = apiService ?? ProveedoresApiService() {
    load();
  }

  /// Carga la lista de proveedores desde el servicio API.
  /// 
  /// Parámetro:
  /// - [q]: Búsqueda opcional (actualiza la consulta si se proporciona)
  Future<void> load({String? q}) async {
    _q = q ?? _q;
    isLoading = true; error = null; notifyListeners();
    try {
      items = await _apiService.getAll(query: _q.isEmpty ? null : _q);
    } catch (e) { error = 'Error al cargar: $e'; }
    isLoading = false; notifyListeners();
  }

  /// Realiza búsqueda de proveedores y recarga la lista.
  /// 
  /// Parámetro:
  /// - [q]: Término de búsqueda
  void search(String q) => load(q: q);
}

