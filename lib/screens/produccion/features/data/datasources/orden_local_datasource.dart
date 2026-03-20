import '../../domain/entities/orden_entity.dart';
import '../models/orden_model.dart';

abstract class OrdenLocalDataSource {
  Future<List<OrdenModel>> getOrdenes({
    OrdenEstado? estado,
    OrdenTipo? tipo,
    String? query,
  });
}

class OrdenLocalDataSourceImpl implements OrdenLocalDataSource {
  static final List<OrdenModel> _mockData = [
    OrdenModel(
      id: '1',
      numero: 21,
      unidades: 300,
      estado: OrdenEstado.enProduccion,
      tipo: OrdenTipo.terceros,
      cliente: 'Sorelly santana rojo',
      fechaEntrega: DateTime(2025, 4, 11),
      refCorte: '513_3005',
      ref: '513',
      fechaEstado: DateTime(2025, 4, 11),
    ),
    OrdenModel(
      id: '2',
      numero: 23,
      unidades: 50,
      estado: OrdenEstado.pendiente,
      tipo: OrdenTipo.terceros,
      cliente: 'Maria García López',
      fechaEntrega: DateTime(2025, 4, 15),
      refCorte: '520_1002',
      ref: '520',
      fechaEstado: DateTime(2025, 4, 12),
    ),
    OrdenModel(
      id: '3',
      numero: 24,
      unidades: 120,
      estado: OrdenEstado.enProduccion,
      tipo: OrdenTipo.produccion,
      cliente: 'Carlos Restrepo',
      fechaEntrega: DateTime(2025, 4, 20),
      refCorte: '530_2010',
      ref: '530',
      fechaEstado: DateTime(2025, 4, 13),
    ),
    OrdenModel(
      id: '4',
      numero: 25,
      unidades: 75,
      estado: OrdenEstado.pendiente,
      tipo: OrdenTipo.produccion,
      cliente: 'Ana Rodríguez',
      fechaEntrega: DateTime(2025, 4, 18),
      refCorte: '540_3005',
      ref: '540',
      fechaEstado: DateTime(2025, 4, 14),
    ),
  ];

  @override
  Future<List<OrdenModel>> getOrdenes({
    OrdenEstado? estado,
    OrdenTipo? tipo,
    String? query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _mockData.where((orden) {
      if (estado != null && orden.estado != estado) return false;
      if (tipo != null && orden.tipo != tipo) return false;
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchNumero = orden.numero.toString().contains(q);
        final matchCliente = orden.cliente?.toLowerCase().contains(q) ?? false;
        final matchRef = orden.ref?.toLowerCase().contains(q) ?? false;
        if (!matchNumero && !matchCliente && !matchRef) return false;
      }
      return true;
    }).toList();
  }
}
