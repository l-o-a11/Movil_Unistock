class ModuloRol {
  final int moduloId;
  final List<int> privilegios;

  const ModuloRol({required this.moduloId, required this.privilegios});

  factory ModuloRol.fromJson(Map<String, dynamic> json) => ModuloRol(
    moduloId: json['moduloId'] as int,
    privilegios: List<int>.from(json['privilegios'] as List),
  );
}

class Rol {
  final int id;
  final String nombre;
  final String descripcion;
  final bool estado;
  final List<ModuloRol> modulos;

  const Rol({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.estado,
    this.modulos = const [],
  });

  // ─── Lookup helpers ────────────────────────────────────────────────────────

  static const _modulos = {
    1: 'Usuarios',
    2: 'Productos',
    3: 'Insumos',
    4: 'Compras',
    5: 'Proveedores',
    6: 'Categorías de insumos',
    7: 'Dashboard',
    8: 'Configuración',
  };

  static const _privilegios = {
    1: 'Leer',
    2: 'Crear',
    3: 'Actualizar',
    4: 'Eliminar',
  };

  static const _privilegiosKeys = {
    1: 'leer',
    2: 'crear',
    3: 'actualizar',
    4: 'eliminar',
  };

  String get estadoLabel => estado ? 'Activo' : 'Inactivo';
  bool get isActivo => estado;

  String moduloNombre(int moduloId) => _modulos[moduloId] ?? 'Módulo $moduloId';

  String privilegioNombre(int privilegioId) =>
      _privilegios[privilegioId] ?? 'Privilegio $privilegioId';

  /// Cantidad de módulos asignados
  int get totalModulos => modulos.length;

  /// True si tiene acceso total a todos los módulos y privilegios
  bool get isAdmin =>
      modulos.length == _modulos.length &&
      modulos.every((m) => m.privilegios.length == _privilegios.length);

  factory Rol.fromJson(Map<String, dynamic> json) => Rol(
    id: json['id'] as int,
    nombre: json['nombre']?.toString() ?? '',
    descripcion: json['descripcion']?.toString() ?? '',
    estado: json['estado'] as bool,
    modulos: (json['modulos'] as List<dynamic>? ?? [])
        .map((e) => ModuloRol.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
