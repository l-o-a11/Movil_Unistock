import 'package:flutter/material.dart';
import '../../domain/entities/proveedor_entity.dart';
import '../../data/services/proveedores_api_service.dart';

const int kProveedoresPageSize = 5;

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
  String _searchQuery = '';
  int _visibleCount = kProveedoresPageSize;

  List<ProveedorEntity> get visibleItems =>
      proveedoresFiltrados.take(_visibleCount).toList();
  bool get hasMore => _visibleCount < proveedoresFiltrados.length;

  ProveedoresProvider({ProveedoresApiService? apiService})
      : _apiService = apiService ?? ProveedoresApiService() {
    load();
  }

  Future<void> load() async {
    isLoading = true;
    error = null;
    _visibleCount = kProveedoresPageSize;
    notifyListeners();
    try {
      items = await _apiService.getAll(query: null);
    } catch (e) {
      error = 'Error al cargar: $e';
    }
    isLoading = false;
    notifyListeners();
  }

  List<ProveedorEntity> get proveedoresFiltrados {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((p) {
      return p.nombre.toLowerCase().contains(q) ||
          p.nit.toLowerCase().contains(q) ||
          p.contacto.toLowerCase().contains(q) ||
          p.direccion.toLowerCase().contains(q) ||
          p.telefono.toLowerCase().contains(q) ||
          p.correo.toLowerCase().contains(q);
    }).toList();
  }

  void search(String q) {
    _searchQuery = q;
    _visibleCount = kProveedoresPageSize;
    notifyListeners();
  }

  void showMore() {
    if (!hasMore) return;
    _visibleCount += kProveedoresPageSize;
    notifyListeners();
  }
}
