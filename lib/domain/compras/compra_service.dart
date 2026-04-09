import 'dart:convert';
import 'package:http/http.dart' as http;
import 'compra.dart';

class CompraService {
  // ─── Configuración ────────────────────────────────────────────────────────
  // TODO: reemplaza esta URL por la de tu backend real
  static const _baseUrl = 'https://tu-api.com/api';

  // Pon en false cuando tu API esté lista
  static const bool _useMock = true;

  // ─── Datos de ejemplo ─────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> _mockData = [
    {
      'id': 1,
      'numeroFactura': '1873',
      'proveedorId': 1,
      'proveedor': 'Compras Corseteros',
      'fecha': '2025-12-10',
      'observaciones': 'Compra para la orden x para la ref x',
      'costoTotal': 13300.0,
      'anulada': false,
      'detalles': [
        {
          'id': 101,
          'nombre': 'Tela Rosada',
          'cantidad': 50,
          'costoUnitario': 200.0,
          'costo': 10000.0,
        },
        {
          'id': 102,
          'nombre': 'Hilos',
          'cantidad': 100,
          'costoUnitario': 3.0,
          'costo': 300.0,
        },
        {
          'id': 103,
          'nombre': 'Botones',
          'cantidad': 300,
          'costoUnitario': 10.0,
          'costo': 3000.0,
        },
      ],
    },
    {
      'id': 2,
      'numeroFactura': '1874',
      'proveedorId': 2,
      'proveedor': 'Distribuciones S.A.',
      'fecha': '2025-12-12',
      'observaciones': 'Reposición de insumos',
      'costoTotal': 2500.0,
      'anulada': false,
      'detalles': [
        {
          'id': 201,
          'nombre': 'Elástico plano 2 cm',
          'cantidad': 100,
          'costoUnitario': 0.8,
          'costo': 80.0,
        },
        {
          'id': 202,
          'nombre': 'Velcro adhesivo 2 cm',
          'cantidad': 200,
          'costoUnitario': 1.8,
          'costo': 360.0,
        },
      ],
    },
  ];

  // ─── Métodos públicos ─────────────────────────────────────────────────────

  Future<List<Compra>> getCompras() async {
    if (_useMock) return _mockCompras();
    return _fetchCompras();
  }

  Future<Compra> getCompraById(int id) async {
    if (_useMock) return _mockCompraById(id);
    return _fetchCompraById(id);
  }

  // ─── Mock ─────────────────────────────────────────────────────────────────

  Future<List<Compra>> _mockCompras() async {
    // Simula latencia de red
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockData.map((e) => Compra.fromJson(e)).toList();
  }

  Future<Compra> _mockCompraById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final json = _mockData.firstWhere(
      (e) => e['id'] == id,
      orElse: () => throw Exception('Compra $id no encontrado'),
    );
    return Compra.fromJson(json);
  }

  // ─── API real ─────────────────────────────────────────────────────────────

  Future<List<Compra>> _fetchCompras() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/compras'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json
          .map((e) => Compra.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al cargar compras (${response.statusCode})');
  }

  Future<Compra> _fetchCompraById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/compras/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return Compra.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Error al cargar compra $id (${response.statusCode})');
  }
}
