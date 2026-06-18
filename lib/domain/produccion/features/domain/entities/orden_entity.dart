// Estados reales del backend: "Diseño","Ficha Técnica","Corte","Compras",
// "Producción","En producción","Empaque","Enviado","Anulada", etc.
// HIDDEN por defecto: "Anulada" y "Enviado" (igual que HIDDEN_STATUSES del web)

class OrdenEntity {
  final String id;
  final int numero;
  final int unidades;
  final String estado;   // String exacto del backend — nunca enum
  final String tipo;     // "produccion" | "terceros"
  final String? cliente;
  final DateTime? fechaEntrega;
  final String? refCorte;
  final String? ref;
  final String? producto;
  final String? color;
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
    this.producto,
    this.color,
    this.fechaEstado,
  });

  // Helpers (reemplazan al enum y estadoLabel)
  bool get isHidden       => estado == 'Anulada' || estado == 'Enviado';
  bool get isEnProduccion => estado == 'Producción' || estado == 'En producción';
  bool get isTerceros     => tipo == 'terceros';
  String get estadoLabel  => estado; // ya es el string correcto del backend
}
