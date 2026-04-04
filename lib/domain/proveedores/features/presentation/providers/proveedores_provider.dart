import 'package:flutter/material.dart';
import '../../domain/entities/proveedor_entity.dart';
import '../../data/services/proveedores_api_service.dart';

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

  Future<void> load({String? q}) async {
    _q = q ?? _q;
    isLoading = true; error = null; notifyListeners();
    try {
      items = await _apiService.getAll(query: _q.isEmpty ? null : _q);
    } catch (e) { error = 'Error al cargar: $e'; }
    isLoading = false; notifyListeners();
  }

  void search(String q) => load(q: q);
}

