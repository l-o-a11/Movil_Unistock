import '../../domain/entities/tercero_entity.dart';

/// Modelo de datos para terceros: mapeo entre JSON y [TerceroEntity].
/// 
/// Extiende [TerceroEntity] con métodos para serialización JSON.
/// Utilizado por [TercerosApiService] y [TerceroLocalDataSourceImpl].
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

  /// Crea un [TerceroModel] desde JSON.
  /// 
  /// Parsea automáticamente el enum [TerceroEstado].
  /// Lanza excepción si faltan campos requeridos.
  factory TerceroModel.fromJson(Map<String, dynamic> json) {
    return TerceroModel(
      id: json['id'] as String,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      contacto: json['contacto'] as String,
      nit: json['nit'] as String,
      direccion: json['direccion'] as String,
      telefono: json['telefono'] as String,
      estado: TerceroEstado.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => TerceroEstado.activo,
      ),
    );
  }
}
