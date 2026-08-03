import 'package:movil_unistock/domain/terceros/features/domain/entities/tercero_entity.dart';
import 'package:movil_unistock/domain/terceros/features/domain/entities/tercero_produccion_entity.dart';
import 'package:movil_unistock/domain/terceros/features/domain/entities/tercero_detail_entity.dart';

/// DataSource local (mock) con datos de terceros.
/// En producción, los datos provienen de la API. Este fallback solo se usa
/// cuando no hay conexión.
class TerceroLocalDataSourceImpl {
  static final List<TerceroEntity> _mockData = [
    const TerceroEntity(
      id: '1',
      codigo: '001',
      nombre: 'Corte Express',
      contacto: 'Carlos Ruiz',
      nit: '900123456',
      direccion: 'Carrera 45 #12-30, Medellín',
      telefono: '3123456789',
      estado: TerceroEstado.activo,
    ),
    const TerceroEntity(
      id: '2',
      codigo: '002',
      nombre: 'Textilería Andina',
      contacto: 'María López',
      nit: '900987654',
      direccion: 'Calle 23 #45-60, Bogotá',
      telefono: '3159876543',
      estado: TerceroEstado.activo,
    ),
    const TerceroEntity(
      id: '3',
      codigo: '003',
      nombre: 'Subcontratación Delta',
      contacto: 'Jorge Martínez',
      nit: '900456789',
      direccion: 'Av. Bolivariana #100, Cali',
      telefono: '3145678901',
      estado: TerceroEstado.inactivo,
    ),
  ];

  Future<List<TerceroEntity>> getTerceros({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 260));
    if (query == null || query.isEmpty) return _mockData;
    final q = query.toLowerCase();
    return _mockData.where((t) =>
        t.nombre.toLowerCase().contains(q) ||
        t.codigo.toLowerCase().contains(q) ||
        t.nit.contains(q) ||
        t.contacto.toLowerCase().contains(q)).toList();
  }

  Future<TerceroDetailEntity?> getTerceroDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 180));
    TerceroEntity? tercero;
    try {
      tercero = _mockData.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }

    // Mock producciones asociadas - filtrar según estados no finalizados
    // Estados finalizados: "Anulada", "Enviado", "Empaque" → no mostrar
    final mockProducciones = [
      if (tercero.estado == TerceroEstado.activo && tercero.id == '1')
        TerceroProduccionEntity(corte: 'OP-001', fecha: DateTime.now(), ordenId: '101'),
      if (tercero.estado == TerceroEstado.activo && tercero.id == '2')
        TerceroProduccionEntity(corte: 'OP-002', fecha: DateTime.now(), ordenId: '102'),
    ];

    return TerceroDetailEntity(
      id: tercero.id,
      codigo: tercero.codigo,
      nombre: tercero.nombre,
      contacto: tercero.contacto,
      nit: tercero.nit,
      direccion: tercero.direccion,
      telefono: tercero.telefono,
      estado: tercero.estado,
      producciones: mockProducciones,
    );
  }
}