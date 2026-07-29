class OrdenEntity {
  final String id;
  final int numero;
  final int unidades;
  final String estado;
  final String tipo;
  final String? cliente;
  final DateTime? fechaEntrega;
  final String? refCorte;
  final String? ref;
  final String? producto;
  final String? color;
  final DateTime? fechaEstado;
  final String? sede;          // sede asignada (puede venir como string)
  final String? terceroNombre; // nombre del tercero principal (resumen rápido)
  // ── Asignación / confirmación de etapa (empleado) ─────────────────────
  // Necesarios ya en la ENTIDAD BASE (no solo en el detalle) porque el
  // listado de órdenes (ProduccionState.ordenesFiltradas) filtra por
  // estos campos para que un Empleado solo vea SU orden asignada — igual
  // que `matchesSede` en ProductionPage.jsx del frontend web.
  final String? empleadoAsignadoId;
  final bool etapaConfirmada;

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
    this.sede,
    this.terceroNombre,
    this.empleadoAsignadoId,
    this.etapaConfirmada = false,
  });

  bool get isHidden       => estado == 'Anulada' || estado == 'Enviado';
  bool get isEnProduccion => estado == 'Producción' || estado == 'En producción';
  bool get isTerceros     => tipo == 'terceros';
  String get estadoLabel  => estado;
}
