enum OrdenEstado { enProduccion, pendiente, completado, cancelado }

enum OrdenTipo { produccion, terceros }

class OrdenEntity {
  final String id;
  final int numero;
  final int unidades;
  final OrdenEstado estado;
  final OrdenTipo tipo;
  final String? cliente;
  final DateTime? fechaEntrega;
  final String? refCorte;
  final String? ref;
  final DateTime? fechaEstado;

  const OrdenEntity({
    required this.id,
    required this.numero,
    required this.unidades,
    required this.estado,
    required this.tipo,
    this.cliente,
    this.fechaEntrega,
    this.refCorte,
    this.ref,
    this.fechaEstado,
  });

  String get estadoLabel {
    switch (estado) {
      case OrdenEstado.enProduccion:
        return 'En producción';
      case OrdenEstado.pendiente:
        return 'Pendiente';
      case OrdenEstado.completado:
        return 'Completado';
      case OrdenEstado.cancelado:
        return 'Cancelado';
    }
  }

  bool get isEnProduccion => estado == OrdenEstado.enProduccion;
  bool get isPendiente => estado == OrdenEstado.pendiente;
}
