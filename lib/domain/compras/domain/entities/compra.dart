// Modelos para Compras — reflejan la forma real del backend
// (domain/entities/Purchase.js y PurchaseDetail.js).

// ─── Modelos de Compras ───────────────────────────────────────────────────

class CompraDetalle {
  final String id;
  final String compraId;
  final String? productoId;
  final String? insumoId;
  // Nombre libre guardado en el detalle. Puede venir null cuando el detalle
  // solo referencia un insumo/producto existente por id (el backend no
  // resuelve el nombre del catálogo automáticamente aquí).
  final String? nombre;
  // Nombre resuelto aparte por [CompraService] consultando el catálogo de
  // insumos, para cuando `nombre` viene null pero sí hay `insumoId`.
  final String? nombreResuelto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  const CompraDetalle({
    required this.id,
    required this.compraId,
    this.productoId,
    this.insumoId,
    this.nombre,
    this.nombreResuelto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  /// Nombre a mostrar: prioriza el nombre libre guardado en el detalle,
  /// luego el resuelto vía catálogo, y por último un texto de respaldo.
  String get nombreMostrar => (nombre != null && nombre!.isNotEmpty)
      ? nombre!
      : (nombreResuelto ?? 'Insumo sin nombre');

  CompraDetalle copyWith({String? nombreResuelto}) => CompraDetalle(
    id: id,
    compraId: compraId,
    productoId: productoId,
    insumoId: insumoId,
    nombre: nombre,
    nombreResuelto: nombreResuelto ?? this.nombreResuelto,
    cantidad: cantidad,
    precioUnitario: precioUnitario,
    subtotal: subtotal,
  );

  factory CompraDetalle.fromJson(Map<String, dynamic> json) {
    final rawInsumo = json['insumoId'];
    final insumoId = rawInsumo is Map
        ? (rawInsumo['_id'] ?? rawInsumo['id'])?.toString()
        : rawInsumo?.toString();

    final rawProducto = json['productoId'];
    final productoId = rawProducto is Map
        ? (rawProducto['_id'] ?? rawProducto['id'])?.toString()
        : rawProducto?.toString();

    return CompraDetalle(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      compraId: (json['compraId'] ?? '').toString(),
      productoId: productoId,
      insumoId: insumoId,
      nombre: json['nombre']?.toString(),
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 0,
      precioUnitario: (json['precioUnitario'] as num?)?.toDouble() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
    );
  }
}

class Compra {
  final String id;
  final int? consecutivo;
  final String fecha; // ISO 8601
  final String proveedorId;
  // Nombre del proveedor: el backend NO lo incluye en la respuesta de
  // compras (solo el id), así que [CompraService] lo resuelve aparte
  // consultando `/api/proveedores/:id` y lo inyecta con [copyWith].
  final String? proveedorNombre;
  final double total;
  final bool anulada;
  final String observaciones;
  final String numeroFactura;
  final String? motivoAnulacion;
  final List<CompraDetalle> detalles;

  const Compra({
    required this.id,
    this.consecutivo,
    required this.fecha,
    required this.proveedorId,
    this.proveedorNombre,
    required this.total,
    required this.anulada,
    required this.observaciones,
    required this.numeroFactura,
    this.motivoAnulacion,
    this.detalles = const [],
  });

  String get estadoLabel => anulada ? 'Anulada' : 'Activa';

  Compra copyWith({String? proveedorNombre, List<CompraDetalle>? detalles}) =>
      Compra(
        id: id,
        consecutivo: consecutivo,
        fecha: fecha,
        proveedorId: proveedorId,
        proveedorNombre: proveedorNombre ?? this.proveedorNombre,
        total: total,
        anulada: anulada,
        observaciones: observaciones,
        numeroFactura: numeroFactura,
        motivoAnulacion: motivoAnulacion,
        detalles: detalles ?? this.detalles,
      );

  /// Tolerante a `id`/`_id` y a nombres alternativos de campos por si el
  /// backend cambia, pero mapea principalmente a la forma real de
  /// `Purchase.toPublic()`: id, consecutivo, fecha, proveedorId, total,
  /// anulada, observaciones, numeroFactura, motivoAnulacion, fechaAnulacion.
  factory Compra.fromJson(Map<String, dynamic> json) {
    final rawProveedor = json['proveedorId'];
    final proveedorId = rawProveedor is Map
        ? (rawProveedor['_id'] ?? rawProveedor['id'] ?? '').toString()
        : (rawProveedor ?? '').toString();

    final rawAnulada = json['anulada'];
    final anulada = rawAnulada is bool
        ? rawAnulada
        : (rawAnulada?.toString().toLowerCase() == 'true');

    return Compra(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      consecutivo: (json['consecutivo'] as num?)?.toInt(),
      fecha: json['fecha']?.toString() ?? '',
      proveedorId: proveedorId,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      anulada: anulada,
      observaciones: json['observaciones']?.toString() ?? '',
      numeroFactura: json['numeroFactura']?.toString() ?? '',
      motivoAnulacion: json['motivoAnulacion']?.toString(),
      detalles: (json['detalles'] as List<dynamic>? ?? [])
          .map((e) => CompraDetalle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
