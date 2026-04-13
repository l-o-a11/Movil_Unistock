import 'dart:convert';
import 'package:http/http.dart' as http;
import 'categoria.dart';

class CategoriaService {
  // ─── Configuración ────────────────────────────────────────────────────────
  // TODO: reemplaza esta URL por la de tu backend real
  static const _baseUrl = 'https://tu-api.com/api';

  // Pon en false cuando tu API esté lista
  static const bool _useMock = true;

  // ─── Datos de ejemplo ─────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> _mockData = [
    {'id': 1, 'nombre': 'Hilos', 'estado': true},
    {'id': 2, 'nombre': 'Botones', 'estado': true},
    {'id': 3, 'nombre': 'Telas', 'estado': false},
    {'id': 4, 'nombre': 'Cierres', 'estado': false},
    {'id': 5, 'nombre': 'Elásticos', 'estado': true},

  ];

  // ─── Métodos públicos ─────────────────────────────────────────────────────

  Future<List<Categoria>> getCategorias() async {
    if (_useMock) return _mockCategorias();
    return _fetchCategorias();
  }

  Future<Categoria> getCategoriaById(int id) async {
    if (_useMock) return _mockCategoriaById(id);
    return _fetchCategoriaById(id);
  }

  // ─── Mock ─────────────────────────────────────────────────────────────────

  Future<List<Categoria>> _mockCategorias() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _mockData.map((e) => Categoria.fromJson(e)).toList();
  }

  Future<Categoria> _mockCategoriaById(int id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final json = _mockData.firstWhere(
      (e) => e['id'] == id,
      orElse: () => throw Exception('Categoria $id no encontrada'),
    );
    return Categoria.fromJson(json);
  }

  // ─── API real ─────────────────────────────────────────────────────────────

  Future<List<Categoria>> _fetchCategorias() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/categorias'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json
          .map((e) => Categoria.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al cargar categorias (${response.statusCode})');
  }

  Future<Categoria> _fetchCategoriaById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/categorias/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return Categoria.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Error al cargar categoria $id (${response.statusCode})');
  }
}
