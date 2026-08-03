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
    super.sede,
    super.terceroNombre,
    super.empleadoAsignadoId,
    super.etapaConfirmada,
  });

  /// Mapea la respuesta real del backend exactamente como lo hace
  /// mapOrder() + mergeDetails() + summarizeDetails() del useProduction.js
  ///
  /// Campos del backend:
  ///   _id/id, numero_orden, estado (string libre), tipo,
  ///   cliente, fecha_entrega, historial[].estado/fecha,
  ///   detalles[].cantidad/color/id_producto,
  ///   producto (string), referencia (objeto o string)
  ///
  /// Parseo DEFENSIVO: si `detalles`/`historial`/`terceros` llegan como un
  /// tipo distinto a List, se tratan como vacíos en lugar de lanzar una
  /// excepción (que antes disparaba el fallback a datos mock).
  factory OrdenModel.fromJson(Map<String, dynamic> json) {
    // id
    final id = (json['_id'] ?? json['id'] ?? '').toString();

    // numero_orden
    final rawNum =
        json['numero_orden'] ?? json['orderNumber'] ?? json['numero'] ?? 0;
    final numero = rawNum is num
        ? rawNum.toInt()
        : int.tryParse(rawNum.toString()) ?? 0;

    // estado: string exacto — NUNCA traducir a enum
    final estado = (json['estado'] ?? json['status'] ?? '').toString();

    // tipo: "produccion" | "terceros"
    final tipo = (json['tipo'] ?? json['type'] ?? 'produccion')
        .toString()
        .toLowerCase();

    // cliente
    final cliente = (json['cliente'] ?? json['client'])?.toString();

    // fechaEntrega
    final fechaEntrega = _parseDate(
      json['fecha_entrega'] ?? json['deliveryDate'],
    );

    // detalles[]: suma de cantidad → unidades, primer color, primer id_producto
    final detallesRaw = json['detalles'];
    final detalles = detallesRaw is List ? detallesRaw : const <dynamic>[];
    final unidades = detalles.fold<int>(0, (suma, d) {
      if (d is! Map) return suma;
      final cant = d['cantidad'] ?? 0;
      return suma +
          (cant is num ? cant.toInt() : int.tryParse(cant.toString()) ?? 0);
    });

    // color: todos los colores únicos del primer detalle
    final firstMap = detalles.isNotEmpty && detalles.first is Map
        ? detalles.first as Map
        : null;
    final colorRaw = firstMap?['color']?.toString() ?? '';
    final color = colorRaw.isNotEmpty ? colorRaw : null;

    // refCorte: id_producto del primer detalle
    final refCorteRaw = firstMap?['id_producto']?.toString() ?? '';
    final refCorte = refCorteRaw.isNotEmpty ? refCorteRaw : null;

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
    final historialRaw = json['historial'];
    final historial = historialRaw is List ? historialRaw : const <dynamic>[];
    final lastFecha = historial.isNotEmpty && historial.last is Map
        ? historial.last['fecha']
        : null;
    final fechaEstado = _parseDate(
      lastFecha ?? json['updatedAt'] ?? json['createdAt'],
    );

    // Tercero principal (resumen rápido)
    final tercerosRaw = json['terceros'];
    final tercerosList = tercerosRaw is List ? tercerosRaw : const <dynamic>[];
    String? terceroNombre;
    if (tercerosList.isNotEmpty && tercerosList.first is Map) {
      final t0 = tercerosList.first as Map;
      terceroNombre = (t0['nombre'] ?? t0['nombreEmpresa'])?.toString();
    }

    // Asignación/confirmación de etapa por parte del empleado — mismo
    // mapeo que toFrontendFormat() en ProductionAPIClient.js del web.
    // Necesario aquí (y no solo en el detalle) porque el listado filtra
    // por estos campos para que el Empleado solo vea su orden asignada.
    final empleadoAsignaciones = json['empleadoAsignaciones'];
    final empleadoAsignadoId =
        json['empleadoAsignadoId']?.toString() ??
        _resolveEmpleadoAsignadoId(empleadoAsignaciones, estado);
    final etapaConfirmada = json['etapaConfirmada'] == true;

    return OrdenModel(
      id: id,
      numero: numero,
      unidades: unidades,
      estado: estado,
      tipo: tipo,
      cliente: cliente,
      fechaEntrega: fechaEntrega,
      refCorte: refCorte,
      ref: ref,
      producto: productoRaw,
      color: color,
      fechaEstado: fechaEstado,
      sede: (json['sede'] ?? json['sede_nombre'])?.toString(),
      terceroNombre: terceroNombre,
      empleadoAsignadoId: empleadoAsignadoId,
      etapaConfirmada: etapaConfirmada,
    );
  }

  static DateTime? _parseDate(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString());

  static String? _resolveEmpleadoAsignadoId(
    dynamic asignaciones,
    String estado,
  ) {
    if (asignaciones is Map) {
      final asig = asignaciones[estado] as Map?;
      return asig?['id_empleado']?.toString();
    }
    return null;
  }
}
