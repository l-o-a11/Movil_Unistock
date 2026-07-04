/// Tercero asignado a una orden de producción.
/// Parseado desde el campo [terceros] del backend.
class TerceroAsignacion {
  final String? id;
  final String nombre;
  final String? proceso;
  final int cantidad;
  final String estado;
  final String? telefono;
  final String? contacto;

  const TerceroAsignacion({
    this.id,
    required this.nombre,
    this.proceso,
    required this.cantidad,
    required this.estado,
    this.telefono,
    this.contacto,
  });

  factory TerceroAsignacion.fromJson(Map<String, dynamic> j) {
    final cantRaw = j['cantidad'] ?? j['unidades'] ?? 0;
    return TerceroAsignacion(
      id:       (j['id_tercero'] ?? j['_id'] ?? j['id'])?.toString(),
      nombre:   (j['nombre'] ?? j['name'] ?? j['nombreEmpresa'] ?? 'Tercero').toString(),
      proceso:  (j['proceso'] ?? j['proceso_asignado'])?.toString(),
      cantidad: cantRaw is num ? cantRaw.toInt() : int.tryParse(cantRaw.toString()) ?? 0,
      estado:   (j['estado'] ?? 'pendiente').toString(),
      telefono: (j['telefono'] ?? j['phone'])?.toString(),
      contacto: (j['contacto'] ?? j['nombreContacto'])?.toString(),
    );
  }
}
