import 'dart:convert';
import 'package:http/http.dart' as http;
import 'rol.dart';

class RolService {
  // ─── Configuración ────────────────────────────────────────────────────────
  // TODO: reemplaza esta URL por la de tu backend real
  static const _baseUrl = 'https://tu-api.com/api';

  // Pon en false cuando tu API esté lista
  static const bool _useMock = true;

  // ─── Datos de ejemplo ─────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> _mockData = [
    {
      'id': 1,
      'nombre': 'Gerente',
      'descripcion':
          'Accede a todos los módulos y permisos completos del sistema. Puede crear, editar y eliminar cualquier registro.',
      'estado': true,
      'modulos': [
        {'moduloId': 1, 'privilegios': [1, 2, 3, 4]},
        {'moduloId': 2, 'privilegios': [1, 2, 3, 4]},
        {'moduloId': 3, 'privilegios': [1, 2, 3, 4]},
        {'moduloId': 4, 'privilegios': [1, 2, 3, 4]},
        {'moduloId': 5, 'privilegios': [1, 2, 3, 4]},
        {'moduloId': 6, 'privilegios': [1, 2, 3, 4]},
        {'moduloId': 7, 'privilegios': [1, 2, 3, 4]},
        {'moduloId': 8, 'privilegios': [1, 2, 3, 4]},
      ],
    },
    {
      'id': 2,
      'nombre': 'Vendedor',
      'descripcion':
          'Gestiona productos y compras. Solo puede leer usuarios y proveedores, sin acceso a configuración.',
      'estado': true,
      'modulos': [
        {'moduloId': 1, 'privilegios': [1]},           // Usuarios: leer
        {'moduloId': 2, 'privilegios': [1, 2, 3]},     // Productos: leer, crear, actualizar
        {'moduloId': 4, 'privilegios': [1, 2]},        // Compras: leer, crear
        {'moduloId': 5, 'privilegios': [1]},           // Proveedores: leer
        {'moduloId': 7, 'privilegios': [1]},           // Dashboard: leer
      ],
    },
    {
      'id': 3,
      'nombre': 'Almacenista',
      'descripcion':
          'Administra insumos, categorías y proveedores. Acceso de solo lectura a productos y compras.',
      'estado': true,
      'modulos': [
        {'moduloId': 2, 'privilegios': [1]},           // Productos: leer
        {'moduloId': 3, 'privilegios': [1, 2, 3]},     // Insumos: leer, crear, actualizar
        {'moduloId': 4, 'privilegios': [1]},           // Compras: leer
        {'moduloId': 5, 'privilegios': [1, 2, 3]},     // Proveedores: leer, crear, actualizar
        {'moduloId': 6, 'privilegios': [1, 2, 3, 4]}, // Categorías: todos
        {'moduloId': 7, 'privilegios': [1]},           // Dashboard: leer
      ],
    },
    {
      'id': 4,
      'nombre': 'Auditor',
      'descripcion':
          'Acceso de solo lectura a todos los módulos del sistema para fines de revisión y auditoría.',
      'estado': true,
      'modulos': [
        {'moduloId': 1, 'privilegios': [1]},
        {'moduloId': 2, 'privilegios': [1]},
        {'moduloId': 3, 'privilegios': [1]},
        {'moduloId': 4, 'privilegios': [1]},
        {'moduloId': 5, 'privilegios': [1]},
        {'moduloId': 6, 'privilegios': [1]},
        {'moduloId': 7, 'privilegios': [1]},
        {'moduloId': 8, 'privilegios': [1]},
      ],
    },
    {
      'id': 5,
      'nombre': 'Asistente',
      'descripcion':
          'Rol básico con acceso limitado. Solo puede ver insumos y productos, sin poder modificar nada.',
      'estado': false,
      'modulos': [
        {'moduloId': 2, 'privilegios': [1]},
        {'moduloId': 3, 'privilegios': [1]},
      ],
    },
  ];

  // ─── Métodos públicos ─────────────────────────────────────────────────────

  Future<List<Rol>> getRoles() async {
    if (_useMock) return _mockRoles();
    return _fetchRoles();
  }

  Future<Rol> getRolById(int id) async {
    if (_useMock) return _mockRolById(id);
    return _fetchRolById(id);
  }

  // ─── Mock ─────────────────────────────────────────────────────────────────

  Future<List<Rol>> _mockRoles() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockData.map((e) => Rol.fromJson(e)).toList();
  }

  Future<Rol> _mockRolById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final json = _mockData.firstWhere(
      (e) => e['id'] == id,
      orElse: () => throw Exception('Rol $id no encontrado'),
    );
    return Rol.fromJson(json);
  }

  // ─── API real ─────────────────────────────────────────────────────────────

  Future<List<Rol>> _fetchRoles() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/roles'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json
          .map((e) => Rol.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al cargar roles (${response.statusCode})');
  }

  Future<Rol> _fetchRolById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/roles/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return Rol.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Error al cargar rol $id (${response.statusCode})');
  }
}
