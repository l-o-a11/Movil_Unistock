import 'package:flutter/material.dart';

import '../../data/empleados_data_source.dart';
import '../../domain/empleados_entity.dart';

class EmpleadosProvider extends ChangeNotifier {
  final EmpleadosDataSource _dataSource;

  List<EmpleadoEntity> items = [];
  bool isLoading = false;
  String? error;
  String query = '';

  EmpleadosProvider({EmpleadosDataSource? dataSource})
    : _dataSource = dataSource ?? EmpleadosDataSource() {
    load();
  }

  Future<void> load({String q = ''}) async {
    query = q;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      items = await _dataSource.getEmpleados(query: q);
    } catch (_) {
      error = 'No se pudo cargar empleados';
      items = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void search(String q) => load(q: q);
}
