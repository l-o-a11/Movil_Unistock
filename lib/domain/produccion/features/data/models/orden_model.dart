import '../../domain/entities/orden_entity.dart';

/// Modelo de datos para órdenes: mapeo entre JSON y [OrdenEntity].
///
/// Extiende [OrdenEntity] con métodos para serialización/deserialización JSON.
/// Utilizado por [ProduccionApiService] y [OrdenLocalDataSourceImpl].
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
    super.fechaEstado,
  });

  /// Crea un [OrdenModel] desde JSON.
  ///
  /// Parsea automáticamente:
  /// - Enums de estado y tipo
  /// - Fechas en formato ISO 8601
  ///
  /// Lanza excepción si faltan campos requeridos.
  factory OrdenModel.fromJson(Map<String, dynamic> json) {
    return OrdenModel(
      id: json['id'] as String,
      numero: json['numero'] as int,
      unidades: json['unidades'] as int,
      estado: _parseEstado(json['estado'] as String),
      tipo: _parseTipo(json['tipo'] as String),
      cliente: json['cliente'] as String?,
      fechaEntrega: json['fechaEntrega'] != null
          ? DateTime.parse(json['fechaEntrega'] as String)
          : null,
      refCorte: json['refCorte'] as String?,
      ref: json['ref'] as String?,
      fechaEstado: json['fechaEstado'] != null
          ? DateTime.parse(json['fechaEstado'] as String)
          : null,
    );
  }

  /// Convierte el modelo a JSON.
  ///
  /// Serializa enums a sus nombres (strings) y fechas a ISO 8601.
  Map<String, dynamic> toJson() => {
    'id': id,
    'numero': numero,
    'unidades': unidades,
    'estado': estado.name,
    'tipo': tipo.name,
    'cliente': cliente,
    'fechaEntrega': fechaEntrega?.toIso8601String(),
    'refCorte': refCorte,
    'ref': ref,
    'fechaEstado': fechaEstado?.toIso8601String(),
  };

  static OrdenEstado _parseEstado(String value) {
    switch (value) {
      case 'enProduccion':
        return OrdenEstado.enProduccion;
      case 'completado':
        return OrdenEstado.completado;
      case 'cancelado':
        return OrdenEstado.cancelado;
      default:
        return OrdenEstado.pendiente;
    }
  }

  static OrdenTipo _parseTipo(String value) {
    return value == 'terceros' ? OrdenTipo.terceros : OrdenTipo.produccion;
  }
}
