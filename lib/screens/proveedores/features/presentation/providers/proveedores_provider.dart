import 'package:flutter/material.dart';
import '../../domain/entities/proveedor_entity.dart';
import '../../data/datasources/proveedor_datasource.dart';

class ProveedoresProvider extends ChangeNotifier {
  final _ds = ProveedorDataSource();
  List<ProveedorEntity> items = [];
  bool isLoading = true;
  String? error;
  String _q = '';

  ProveedoresProvider() { load(); }

  Future<void> load({String? q}) async {
    _q = q ?? _q;
    isLoading = true; error = null; notifyListeners();
    try {
      items = await _ds.getAll(query: _q.isEmpty ? null : _q);
    } catch (e) { error = 'Error al cargar: $e'; }
    isLoading = false; notifyListeners();
  }
  void search(String q) => load(q: q);
}
