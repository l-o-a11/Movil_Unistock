import '../../domain/entities/orden_entity.dart';

class OrdenModel extends OrdenEntity {
  const OrdenModel({
    required super.id,
    required super.numero,
    required super.unidades,
    required super.estado,
    required super.tipo,
    super.cliente,
    super.fechaEntrega,
    super.refCorte,
    super.ref,
    super.producto,
    super.color,
    super.fechaEstado,
  });

  /// Mapea la respuesta real del backend exactamente como lo hace
  /// mapOrder() + mergeDetails() + summarizeDetails() del useProduction.js
  ///
  /// Campos del backend:
  ///   _id/id, numero_orden, estado (string libre), tipo,
  ///   cliente, fecha_entrega, historial[].estado/fecha,
  ///   detalles[].cantidad/color/id_producto,
  ///   producto (string), referencia (objeto o string)
  factory OrdenModel.fromJson(Map<String, dynamic> json) {
    // id
    final id = (json['_id'] ?? json['id'] ?? '').toString();

    // numero_orden
    final rawNum = json['numero_orden'] ?? json['orderNumber'] ?? json['numero'] ?? 0;
    final numero = rawNum is num ? rawNum.toInt()
        : int.tryParse(rawNum.toString()) ?? 0;

    // estado: string exacto — NUNCA traducir a enum
    final estado = (json['estado'] ?? json['status'] ?? '').toString();

    // tipo: "produccion" | "terceros"
    final tipo = (json['tipo'] ?? json['type'] ?? 'produccion').toString().toLowerCase();

    // cliente
    final cliente = (json['cliente'] ?? json['client'])?.toString();

    // fechaEntrega
    final fechaEntrega = _parseDate(json['fecha_entrega'] ?? json['deliveryDate']);

    // detalles[]: suma de cantidad → unidades, primer color, primer id_producto
    final detalles = (json['detalles'] as List<dynamic>?) ?? [];
    final unidades = detalles.fold<int>(
        0, (s, d) => s + ((d['cantidad'] ?? 0) as num).toInt());

    // color: todos los colores únicos del primer detalle
    final firstColor = detalles.isNotEmpty
        ? (detalles[0]['color'] ?? '').toString()
        : '';
    final color = firstColor.isNotEmpty ? firstColor : null;

    // refCorte: id_producto del primer detalle
    final refCorte = detalles.isNotEmpty
        ? (detalles[0]['id_producto'] ?? '').toString()
        : null;

    // ref y producto: campo producto de la orden (string directo del backend)
    // En la tabla web: prod.producto || prod.referencia || '—'
    final productoRaw = json['producto']?.toString();
    // referencia puede ser objeto {nombre, codigo} o string
    final refObj = json['referencia'];
    String? ref;
    if (refObj is Map) {
      ref = (refObj['nombre'] ?? refObj['ref'] ?? refObj['codigo'])?.toString();
    } else if (refObj is String && refObj.isNotEmpty) {
      ref = refObj;
    }

    // fechaEstado: updatedAt del backend (igual que statusDate del web)
    final historial = (json['historial'] as List<dynamic>?) ?? [];
    final lastFecha = historial.isNotEmpty ? historial.last['fecha'] : null;
    final fechaEstado =
        _parseDate(lastFecha ?? json['updatedAt'] ?? json['createdAt']);

    return OrdenModel(
      id:           id,
      numero:       numero,
      unidades:     unidades,
      estado:       estado,
      tipo:         tipo,
      cliente:      cliente,
      fechaEntrega: fechaEntrega,
      refCorte:     refCorte,
      ref:          ref,
      producto:     productoRaw,
      color:        color,
      fechaEstado:  fechaEstado,
    );
  }

  static DateTime? _parseDate(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString());
}
