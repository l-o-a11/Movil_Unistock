/// Permiso de un rol sobre un módulo del sistema.
///
/// Forma real del backend (`RoleModel.permisoSchema`):
/// `{ modulo: "insumos", privilegios: ["crear", "leer"] }` — tanto el
/// módulo como los privilegios ya son nombres planos del catálogo
/// (`shared/constants/rolePermissions.js`), no ids que requieran lookup.
class ModuloRol {
  final String modulo;
  final List<String> privilegios;

  const ModuloRol({required this.modulo, required this.privilegios});

  factory ModuloRol.fromJson(Map<String, dynamic> json) {
    final rawModulo = json['modulo'] ?? json['moduloId'];
    final modulo = rawModulo is Map
        ? (rawModulo['nombre'] ?? rawModulo['_id'] ?? rawModulo['id'] ?? '').toString()
        : (rawModulo ?? '').toString();

    final rawPrivilegios = json['privilegios'] as List? ?? [];
    final privilegios = rawPrivilegios
        .map((p) => p is Map ? (p['nombre'] ?? p['_id'] ?? p['id'] ?? '').toString() : p.toString())
        .toList();

    return ModuloRol(modulo: modulo, privilegios: privilegios);
  }
}

class Rol {
  final String id;
  final String nombre;
  final String descripcion;
  final bool estado;
  final List<ModuloRol> permisos;

  const Rol({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.estado,
    this.permisos = const [],
  });

  // ─── Catálogo canónico del backend ─────────────────────────────────────────
  // (shared/constants/rolePermissions.js) — se usa solo para la heurística
  // de "isAdmin" (rol con acceso total). Los nombres a mostrar NO usan este
  // catálogo: ya vienen como texto plano desde la API.
  static const modulosCatalogo = [
    'usuarios',
    'dashboard',
    'empleados',
    'roles',
    'compras',
    'insumos',
    'categorias de insumos',
    'produccion',
    'proveedores',
    'terceros',
    'sedes',
    'productos',
    'categorias de productos',
  ];

  static const privilegiosCatalogo = ['crear', 'leer', 'actualizar', 'eliminar'];

  String get estadoLabel => estado ? 'Activo' : 'Inactivo';
  bool get isActivo => estado;

  /// Nombre legible para un módulo (capitaliza cada palabra).
  String moduloNombre(ModuloRol m) => _capitalizar(m.modulo);

  /// Nombre legible para un privilegio.
  String privilegioNombre(String privilegio) => _capitalizar(privilegio);

  static String _capitalizar(String s) {
    if (s.isEmpty) return s;
    return s
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  /// Cantidad de módulos con al menos un privilegio asignado.
  int get totalModulos => permisos.length;

  /// True si el rol tiene todos los módulos del catálogo con todos los
  /// privilegios (equivalente a "acceso total").
  bool get isAdmin =>
      permisos.length >= modulosCatalogo.length &&
      permisos.every(
        (m) => privilegiosCatalogo.every((p) => m.privilegios.contains(p)),
      );

  /// Tolerante a `id`/`_id` y a `estado`/`activo`.
  factory Rol.fromJson(Map<String, dynamic> json) {
    final rawEstado = json['estado'] ?? json['activo'];
    final estado = rawEstado is bool
        ? rawEstado
        : (rawEstado?.toString().toLowerCase() == 'true' || rawEstado == null);

    final rawPermisos = json['permisos'] ?? json['modulos'];

    return Rol(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      estado: estado,
      permisos: (rawPermisos as List<dynamic>? ?? [])
          .map((e) => ModuloRol.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
