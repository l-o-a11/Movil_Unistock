import 'dart:convert';
import 'package:http/http.dart' as http;
import 'insumo.dart';

class InsumoService {
  // ─── Configuración ────────────────────────────────────────────────────────
  // TODO: reemplaza esta URL por la de tu backend real
  static const _baseUrl = 'https://tu-api.com/api';

  // Pon en false cuando tu API esté lista
  static const bool _useMock = true;

  // ─── Datos de ejemplo ─────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> _mockData = [
    {
      'id': 1,
      'nombre': 'Tela blanca encaje',
      'categoriaId': 1,
      'stock': 10,
      'valorMedida': 45.0,
      'medidaId': 2,
      'estado': true,
      'image': null,
      'propiedades': [
        {'id': 1, 'propiedadId': 5, 'valor': 'Algodón'},
        {'id': 2, 'propiedadId': 1, 'valor': 'Blanco'},
      ],
    },
    {
      'id': 2,
      'nombre': 'Hilo negro 40/2',
      'categoriaId': 2,
      'stock': 200,
      'valorMedida': 3.5,
      'medidaId': 1,
      'estado': true,
      'image': null,
      'propiedades': [
        {'id': 3, 'propiedadId': 1, 'valor': 'Negro'},
        {'id': 4, 'propiedadId': 5, 'valor': 'Poliéster'},
      ],
    },
    {
      'id': 3,
      'nombre': 'Cierre invisible 20 cm',
      'categoriaId': 3,
      'stock': 50,
      'valorMedida': 1.2,
      'medidaId': 1,
      'estado': true,
      'image': null,
      'propiedades': [
        {'id': 5, 'propiedadId': 1, 'valor': 'Beige'},
        {'id': 6, 'propiedadId': 2, 'valor': '20'},
      ],
    },
    {
      'id': 4,
      'nombre': 'Elástico plano 2 cm',
      'categoriaId': 4,
      'stock': 30,
      'valorMedida': 0.8,
      'medidaId': 2,
      'estado': false,
      'image': null,
      'propiedades': [
        {'id': 7, 'propiedadId': 2, 'valor': '2'},
        {'id': 8, 'propiedadId': 3, 'valor': 'Alta'},
      ],
    },
    {
      'id': 5,
      'nombre': 'Encaje floral blanco',
      'categoriaId': 5,
      'stock': 15,
      'valorMedida': 12.0,
      'medidaId': 2,
      'estado': true,
      'image': null,
      'propiedades': [
        {'id': 9,  'propiedadId': 1, 'valor': 'Blanco'},
        {'id': 10, 'propiedadId': 4, 'valor': 'Floral'},
        {'id': 11, 'propiedadId': 5, 'valor': 'Nylon'},
      ],
    },
    {
      'id': 6,
      'nombre': 'Entretela fusionable',
      'categoriaId': 6,
      'stock': 8,
      'valorMedida': 5.5,
      'medidaId': 2,
      'estado': true,
      'image': null,
      'propiedades': [
        {'id': 12, 'propiedadId': 5, 'valor': 'Poliéster'},
      ],
    },
    {
      'id': 7,
      'nombre': 'Botón nácar 18 mm',
      'categoriaId': 7,
      'stock': 500,
      'valorMedida': 0.3,
      'medidaId': 1,
      'estado': true,
      'image': null,
      'propiedades': [
        {'id': 13, 'propiedadId': 1, 'valor': 'Blanco nacarado'},
        {'id': 14, 'propiedadId': 2, 'valor': '18'},
      ],
    },
    {
      'id': 8,
      'nombre': 'Velcro adhesivo 2 cm',
      'categoriaId': 8,
      'stock': 0,
      'valorMedida': 1.8,
      'medidaId': 2,
      'estado': false,
      'image': null,
      'propiedades': [
        {'id': 15, 'propiedadId': 1, 'valor': 'Negro'},
        {'id': 16, 'propiedadId': 2, 'valor': '2'},
      ],
    },
  ];

  // ─── Métodos públicos ─────────────────────────────────────────────────────

  Future<List<Insumo>> getInsumos() async {
    if (_useMock) return _mockInsumos();
    return _fetchInsumos();
  }

  Future<Insumo> getInsumoById(int id) async {
    if (_useMock) return _mockInsumoById(id);
    return _fetchInsumoById(id);
  }

  // ─── Mock ─────────────────────────────────────────────────────────────────

  Future<List<Insumo>> _mockInsumos() async {
    // Simula latencia de red
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockData.map((e) => Insumo.fromJson(e)).toList();
  }

  Future<Insumo> _mockInsumoById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final json = _mockData.firstWhere(
      (e) => e['id'] == id,
      orElse: () => throw Exception('Insumo $id no encontrado'),
    );
    return Insumo.fromJson(json);
  }

  // ─── API real ─────────────────────────────────────────────────────────────

  Future<List<Insumo>> _fetchInsumos() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/insumos'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json
          .map((e) => Insumo.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al cargar insumos (${response.statusCode})');
  }

  Future<Insumo> _fetchInsumoById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/insumos/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return Insumo.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Error al cargar insumo $id (${response.statusCode})');
  }
}