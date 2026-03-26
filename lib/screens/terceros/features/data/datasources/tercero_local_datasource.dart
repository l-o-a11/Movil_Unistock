import '../../domain/entities/tercero_entity.dart';
import '../../domain/entities/tercero_detail_entity.dart';
import '../models/tercero_model.dart';
import '../models/tercero_detail_model.dart';

abstract class TerceroLocalDataSource {
  Future<List<TerceroModel>> getTerceros({String? query});
  Future<TerceroDetailEntity?> getTerceroDetail(String id);
}

class TerceroLocalDataSourceImpl implements TerceroLocalDataSource {
  static final List<TerceroModel> _mockData = [
    const TerceroModel(id: '1', codigo: '542', nombre: 'Textil Aurora',
        contacto: 'Rosalba de los milagros', nit: '520021626',
        direccion: 'Calle 60 #54-4B', telefono: '3147162451',
        estado: TerceroEstado.activo),
    const TerceroModel(id: '2', codigo: '542', nombre: 'Textil Aurora',
        contacto: 'Rosalba de los milagros', nit: '520021626',
        direccion: 'Calle 60 #54-4B', telefono: '3147162451',
        estado: TerceroEstado.activo),
    const TerceroModel(id: '3', codigo: '542', nombre: 'Textil Aurora',
        contacto: 'Rosalba de los milagros', nit: '520021626',
        direccion: 'Calle 60 #54-4B', telefono: '3147162451',
        estado: TerceroEstado.inactivo),
    const TerceroModel(id: '4', codigo: '542', nombre: 'Textil Aurora',
        contacto: 'Rosalba de los milagros', nit: '520021626',
        direccion: 'Calle 60 #54-4B', telefono: '3147162451',
        estado: TerceroEstado.activo),
  ];

  @override
  Future<List<TerceroModel>> getTerceros({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 280));
    if (query == null || query.isEmpty) return _mockData;
    final q = query.toLowerCase();
    return _mockData.where((t) =>
        t.nombre.toLowerCase().contains(q) ||
        t.codigo.toLowerCase().contains(q) ||
        t.contacto.toLowerCase().contains(q)).toList();
  }

  @override
  Future<TerceroDetailEntity?> getTerceroDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 220));
    return TerceroDetailModel.findById(id);
  }
}
