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
      id: '2', codigo: '318', nombre: 'Confecciones Medina',
      contacto: 'Luis Alberto Medina', nit: '860071234',
      direccion: 'Cra 45 #20-15, Medellín', telefono: '3005541289',
      estado: TerceroEstado.activo,
      producciones: [
        TerceroProduccionEntity(corte: '41201', fecha: DateTime(2025, 4, 20), ordenId: '3'),
      ],
    ),
    '3': TerceroDetailModel(
      id: '3', codigo: '201', nombre: 'Modas del Norte',
      contacto: 'Patricia Sánchez', nit: '700345678',
      direccion: 'Av. 33 #76B-40, Medellín', telefono: '3118899001',
      estado: TerceroEstado.inactivo,
      producciones: [],
    ),
    '4': TerceroDetailModel(
      id: '4', codigo: '475', nombre: 'Industrias Rosario',
      contacto: 'Carmen Rosario López', nit: '890123456',
      direccion: 'Calle 50 #80-10, Medellín', telefono: '3209876543',
      estado: TerceroEstado.activo,
      producciones: [
        TerceroProduccionEntity(corte: '55310', fecha: DateTime(2025, 4, 25), ordenId: '1'),
      ],
    ),
  };

  static TerceroDetailModel? findById(String id) => _mock[id];
}
