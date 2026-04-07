import '../../domain/entities/tercero_entity.dart';
import '../../domain/entities/tercero_detail_entity.dart';
import '../models/tercero_model.dart';
import '../models/tercero_detail_model.dart';

/// Contrato para acceso local a datos de terceros (mock/caché).
/// Implementado por [TerceroLocalDataSourceImpl].
abstract class TerceroLocalDataSource {
  /// Obtiene lista de terceros con búsqueda opcional.
  Future<List<TerceroModel>> getTerceros({String? query});

  /// Obtiene el detalle completo de un tercero por ID.
  Future<TerceroDetailEntity?> getTerceroDetail(String id);
}

/// Implementación local (mock) de [TerceroLocalDataSource].
///
/// Contiene datos de ejemplo con 4 terceros activos e inactivos.
/// En desarrollo, proporciona datos inmediatos sin latencia de red.
class TerceroLocalDataSourceImpl implements TerceroLocalDataSource {
  static final List<TerceroModel> _mockData = [
    const TerceroModel(
      id: '1',
      codigo: '542',
      nombre: 'Textil Aurora',
      contacto: 'Rosalba de los milagros',
      nit: '520021626',
      direccion: 'Calle 60 #54-4B',
      telefono: '3147162451',
      estado: TerceroEstado.activo,
    ),
    const TerceroModel(
      id: '2',
      codigo: '318',
      nombre: 'Confecciones Medina',
      contacto: 'Luis Alberto Medina',
      nit: '860071234',
      direccion: 'Cra 45 #20-15, Medellín',
      telefono: '3005541289',
      estado: TerceroEstado.activo,
    ),
    const TerceroModel(
      id: '3',
      codigo: '201',
      nombre: 'Modas del Norte',
      contacto: 'Patricia Sánchez',
      nit: '700345678',
      direccion: 'Av. 33 #76B-40, Medellín',
      telefono: '3118899001',
      estado: TerceroEstado.inactivo,
    ),
    const TerceroModel(
      id: '4',
      codigo: '475',
      nombre: 'Industrias Rosario',
      contacto: 'Carmen Rosario López',
      nit: '890123456',
      direccion: 'Calle 50 #80-10, Medellín',
      telefono: '3209876543',
      estado: TerceroEstado.activo,
    ),
  ];

  @override
  Future<List<TerceroModel>> getTerceros({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 280));
    if (query == null || query.isEmpty) return _mockData;
    final q = query.toLowerCase();
    return _mockData
        .where(
          (t) =>
              t.nombre.toLowerCase().contains(q) ||
              t.codigo.toLowerCase().contains(q) ||
              t.contacto.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Future<TerceroDetailEntity?> getTerceroDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 220));
    return TerceroDetailModel.findById(id);
  }
}
