import 'package:flutter/material.dart';

import '../../data/usuarios_data_source.dart';
import '../../domain/usuarios_entity.dart';

class UsuariosProvider extends ChangeNotifier {
  final UsuariosDataSource _dataSource;

  List<UsuarioEntity> items = [];
  bool isLoading = false;
  String? error;

  UsuariosProvider({UsuariosDataSource? dataSource})
    : _dataSource = dataSource ?? UsuariosDataSource() {
    load();
  }

  Future<void> load({String q = ''}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      items = await _dataSource.getUsuarios(query: q);
    } catch (_) {
      items = [];
      error = 'No se pudo cargar los usuarios';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void search(String q) => load(q: q);
}
