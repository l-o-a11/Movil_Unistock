import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sede.dart';

class SedeService {
  // ─── Configuración ────────────────────────────────────────────────────────
  // TODO: reemplaza esta URL por la de tu backend real
  static const _baseUrl = 'https://tu-api.com/api';

  // Pon en false cuando tu API esté lista
  static const bool _useMock = true;

  // ─── Datos de ejemplo (INITIAL_SEDES) ─────────────────────────────────────
  static final List<Map<String, dynamic>> _mockData = [
    {
      'id': 1,
      'nombre': 'Sede Principal',
      'ciudad': 'Medellín',
      'barrio': 'Parque Berrío',
      'direccion': 'Calle 50 #45-30',
      'telefono': '6042345678',
      'estado': true,
    },
    {
      'id': 2,
      'nombre': 'Sucursal Norte',
      'ciudad': 'Medellín',
      'barrio': 'Laureles',
      'direccion': 'Avenida 80 #20-10',
      'telefono': '6049876543',
      'estado': true,
    },
  ];

  // ─── Métodos públicos ─────────────────────────────────────────────────────

  Future<List<Sede>> getSedes() async {
    if (_useMock) return _mockSedes();
    return _fetchSedes();
  }

  Future<Sede> getSedeById(int id) async {
    if (_useMock) return _mockSedeById(id);
    return _fetchSedeById(id);
  }

  // ─── Mock ─────────────────────────────────────────────────────────────────

  Future<List<Sede>> _mockSedes() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return _mockData.map((e) => Sede.fromJson(e)).toList();
  }

  Future<Sede> _mockSedeById(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final json = _mockData.firstWhere(
      (e) => e['id'] == id,
      orElse: () => throw Exception('Sede $id no encontrada'),
    );
    return Sede.fromJson(json);
  }

  // ─── API real ─────────────────────────────────────────────────────────────

  Future<List<Sede>> _fetchSedes() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/sedes'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => Sede.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Error al cargar sedes (${response.statusCode})');
  }

  Future<Sede> _fetchSedeById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/sedes/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return Sede.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Error al cargar sede $id (${response.statusCode})');
  }
}
