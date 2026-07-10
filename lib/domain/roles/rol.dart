class ModuloRol {
  final String moduloId;
  // Nombre del módulo si la API ya lo envía poblado (sub-documento
  // `{ _id/id, nombre }`). Si es null se usa el mapa local
  // [Rol._modulos] como respaldo (válido para los ids 1-8 de los datos
  // de ejemplo).
  final String? moduloNombre;
  final List<String> privilegios;

  const ModuloRol({
    required this.moduloId,
    this.moduloNombre,
    required this.privilegios,
  });

  /// Tolerante a `moduloId` como id plano (int/string) o como objeto
  /// poblado `{ _id/id, nombre }`, y a `privilegios` como lista de ids
  /// planos o de objetos `{ _id/id }`.
  factory ModuloRol.fromJson(Map<String, dynamic> json) {
    final rawModulo = json['moduloId'] ?? json['modulo'];
    String moduloId = '';
    String? moduloNombre;
    if (rawModulo is Map) {
      moduloId = (rawModulo['_id'] ?? rawModulo['id'] ?? '').toString();
      moduloNombre = rawModulo['nombre']?.toString();
    } else if (rawModulo != null) {
      moduloId = rawModulo.toString();
    }

    final rawPrivilegios = json['privilegios'] as List? ?? [];
    final privilegios = rawPrivilegios
        .map((p) => p is Map ? (p['_id'] ?? p['id'] ?? '').toString() : p.toString())
        .toList();

    return ModuloRol(
      moduloId: moduloId,
      moduloNombre: moduloNombre,
      privilegios: privilegios,
    );
  }
}

class Rol {
  final String id;
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

  // ─── Lookup helpers (respaldo para datos de ejemplo con ids 1-8) ──────────

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

  String get estadoLabel => estado ? 'Activo' : 'Inactivo';
  bool get isActivo => estado;

  /// Nombre a mostrar para un módulo: prioriza el nombre poblado que venga
  /// de la API y cae al mapa local solo si no vino.
  String moduloNombre(ModuloRol m) =>
      m.moduloNombre ?? _modulos[int.tryParse(m.moduloId)] ?? 'Módulo ${m.moduloId}';

  String privilegioNombre(String privilegioId) =>
      _privilegios[int.tryParse(privilegioId)] ?? 'Privilegio $privilegioId';

  /// Cantidad de módulos asignados
  int get totalModulos => modulos.length;

  /// True si tiene acceso total a todos los módulos y privilegios (heurística
  /// basada en la cantidad de módulos/privilegios de los datos de ejemplo).
  bool get isAdmin =>
      modulos.length == _modulos.length &&
      modulos.every((m) => m.privilegios.length == _privilegios.length);

  /// Tolerante a `id`/`_id` y a `estado`/`activo`.
  factory Rol.fromJson(Map<String, dynamic> json) {
    final rawEstado = json['estado'] ?? json['activo'];
    final estado = rawEstado is bool
        ? rawEstado
        : (rawEstado?.toString().toLowerCase() == 'true' || rawEstado == null);

    return Rol(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      estado: estado,
      modulos: (json['modulos'] as List<dynamic>? ?? [])
          .map((e) => ModuloRol.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
