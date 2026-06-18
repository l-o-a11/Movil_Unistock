import '../../domain/entities/tercero_entity.dart';

class TerceroModel extends TerceroEntity {
  const TerceroModel({
    required super.id,
    required super.codigo,
    required super.nombre,
    required super.contacto,
    required super.nit,
    required super.direccion,
    required super.telefono,
    required super.estado,
  });

  /// Mapea la respuesta REAL del backend (igual que toFrontend() del web):
  ///
  /// Campo backend             → campo Flutter
  /// _id / id                  → id
  /// codigo / CODIGO           → codigo   (solo la parte numérica)
  /// nit / NIT                 → nit
  /// nombre_empresa            → nombre
  /// nombre_contacto / contacto→ contacto
  /// telefono                  → telefono
  /// direccion                 → direccion
  /// estado  (bool true/false) → TerceroEstado.activo / inactivo
  ///
  /// Nunca lanza excepción: usa toString() y fallbacks vacíos.
  factory TerceroModel.fromJson(Map<String, dynamic> json) {
    // ── id ────────────────────────────────────────────────────────────────────
    final id = (json['_id'] ?? json['id'] ?? '').toString();

    // ── codigo: solo parte numérica (igual que el web) ────────────────────────
    final rawCodigo = (json['codigo'] ?? json['CODIGO'] ?? json['codigo_tercero'] ?? '').toString();
    final codigo = RegExp(r'\d+').firstMatch(rawCodigo)?.group(0) ?? rawCodigo;

    // ── nit ───────────────────────────────────────────────────────────────────
    final nit = (json['nit'] ?? json['NIT'] ?? json['nit_empresa'] ?? '').toString();

    // ── nombre (nombre_empresa) ───────────────────────────────────────────────
    final nombre = (json['nombre_empresa'] ??
            json['nombreEmpresa'] ??
            json['nombre'] ??
            '')
        .toString();

    // ── contacto (nombre_contacto) ────────────────────────────────────────────
    final contacto = (json['nombre_contacto'] ??
            json['nombreContacto'] ??
            json['contacto'] ??
            json['contacto_principal'] ??
            '')
        .toString();

    // ── telefono ──────────────────────────────────────────────────────────────
    final telefono = (json['telefono'] ?? json['phone'] ?? '').toString();

    // ── direccion ─────────────────────────────────────────────────────────────
    final direccion = (json['direccion'] ?? json['direccion_empresa'] ?? '').toString();

    // ── estado: el backend guarda bool (true = activo) ────────────────────────
    final rawEstado = json['estado'];
    final TerceroEstado estado;
    if (rawEstado is bool) {
      estado = rawEstado ? TerceroEstado.activo : TerceroEstado.inactivo;
    } else if (rawEstado == null) {
      estado = TerceroEstado.activo; // default
    } else {
      final s = rawEstado.toString().toLowerCase();
      estado = (s == 'activo' || s == 'true')
          ? TerceroEstado.activo
          : TerceroEstado.inactivo;
    }

    return TerceroModel(
      id:        id,
      codigo:    codigo,
      nombre:    nombre,
      contacto:  contacto,
      nit:       nit,
      direccion: direccion,
      telefono:  telefono,
      estado:    estado,
    );
  }
}
