import '../../domain/entities/tercero_entity.dart';
import '../../domain/entities/tercero_detail_entity.dart';
import '../../domain/entities/tercero_produccion_entity.dart';

class TerceroDetailModel extends TerceroDetailEntity {
  const TerceroDetailModel({
    required super.id,
    required super.codigo,
    required super.nombre,
    required super.contacto,
    required super.nit,
    required super.direccion,
    required super.telefono,
    required super.estado,
    required super.producciones,
  });

  factory TerceroDetailModel.fromJson(Map<String, dynamic> json) {
    return TerceroDetailModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      codigo: _extractCodigo(json),
      nombre: (json['nombre_empresa'] ?? '').toString(),
      contacto: (json['nombre_contacto'] ?? '').toString(),
      nit: (json['nit'] ?? '').toString(),
      direccion: (json['direccion'] ?? '').toString(),
      telefono: (json['telefono'] ?? '').toString(),
      estado: (json['estado'] == true || json['estado'].toString().toLowerCase() == 'activo')
          ? TerceroEstado.activo
          : TerceroEstado.inactivo,
      producciones: (json['producciones'] as List<dynamic>? ?? [])
          .where((p) {
            final estadoProduccion = (p['estado'] ?? '').toString().toLowerCase();
            return estadoProduccion != 'anulada' && estadoProduccion != 'enviado';
          })
          .map((p) => TerceroProduccionEntity(
                corte: (p['orden'] ?? '').toString(),
                fecha: DateTime.tryParse((p['fecha'] ?? '').toString()) ?? DateTime.now(),
                ordenId: (p['produccionId'] ?? '').toString(),
              ))
          .toList(),
    );
  }

  static String _extractCodigo(Map<String, dynamic> json) {
    final raw = (json['codigo'] ?? json['codigo_tercero'] ?? '').toString();
    return RegExp(r'\d+').firstMatch(raw)?.group(0) ?? raw;
  }
}