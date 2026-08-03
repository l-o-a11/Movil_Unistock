import 'package:flutter/material.dart';
import '../../../usuarios/domain/usuario_model.dart';
import '../../../usuarios/presentation/providers/usuarios_provider.dart';

class EmpleadosProvider extends ChangeNotifier {
  EmpleadosProvider({UsuariosProvider? provider})
    : _provider = provider ?? UsuariosProvider() {
    _provider.addListener(_handleProviderChanged);
  }

  final UsuariosProvider _provider;

  List<UsuarioModel> get items => _provider.items;
  bool get isLoading => _provider.isLoading;
  String? get error => _provider.error;

  Future<void> load({String q = ''}) async {
    await _provider.load(q: q);
  }

  void search(String q) => _provider.search(q);

  Future<String?> toggleStatus(String id) => _provider.toggleStatus(id);

  Future<String?> deleteEmpleado(String id) => _provider.deleteUsuario(id);

  void _handleProviderChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _provider.removeListener(_handleProviderChanged);
    super.dispose();
  }
}
