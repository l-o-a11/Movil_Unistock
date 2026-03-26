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

  static final Map<String, TerceroDetailModel> _mock = {
    '1': TerceroDetailModel(
      id: '1', codigo: '542', nombre: 'Textil Aurora',
      contacto: 'Rosalba de los milagros', nit: '520021626',
      direccion: 'Calle 60 #54-4B', telefono: '3147162451',
      estado: TerceroEstado.activo,
      producciones: [
        TerceroProduccionEntity(corte: '32341', fecha: DateTime(2025, 4, 11), ordenId: '1'),
        TerceroProduccionEntity(corte: '32342', fecha: DateTime(2025, 4, 18), ordenId: '2'),
      ],
    ),
    '2': TerceroDetailModel(
      id: '2', codigo: '542', nombre: 'Textil Aurora',
      contacto: 'Rosalba de los milagros', nit: '520021626',
      direccion: 'Calle 60 #54-4B', telefono: '3147162451',
      estado: TerceroEstado.activo,
      producciones: [
        TerceroProduccionEntity(corte: '32343', fecha: DateTime(2025, 4, 20), ordenId: '3'),
      ],
    ),
    '3': TerceroDetailModel(
      id: '3', codigo: '542', nombre: 'Textil Aurora',
      contacto: 'Rosalba de los milagros', nit: '520021626',
      direccion: 'Calle 60 #54-4B', telefono: '3147162451',
      estado: TerceroEstado.inactivo, producciones: [],
    ),
    '4': TerceroDetailModel(
      id: '4', codigo: '542', nombre: 'Textil Aurora',
      contacto: 'Rosalba de los milagros', nit: '520021626',
      direccion: 'Calle 60 #54-4B', telefono: '3147162451',
      estado: TerceroEstado.activo,
      producciones: [
        TerceroProduccionEntity(corte: '32344', fecha: DateTime(2025, 4, 25), ordenId: '1'),
      ],
    ),
  };

  static TerceroDetailModel? findById(String id) => _mock[id];
}
