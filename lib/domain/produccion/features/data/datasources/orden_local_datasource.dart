import '../../domain/entities/orden_entity.dart';
import '../../domain/entities/orden_detail_entity.dart';
import '../models/orden_model.dart';
import '../models/orden_detail_model.dart';

abstract class OrdenLocalDataSource {
  Future<List<OrdenModel>> getOrdenes({OrdenEstado? estado, OrdenTipo? tipo, String? query});
  Future<OrdenDetailEntity?> getOrdenDetail(String id);
}

class OrdenLocalDataSourceImpl implements OrdenLocalDataSource {
  static final List<OrdenModel> _mockData = [
    // ── Terceros ──────────────────────────────────────────────────────────
    OrdenModel(id:'1', numero:21, unidades:300, estado:OrdenEstado.enProduccion,
      tipo:OrdenTipo.terceros, cliente:'Sorelly santana rojo',
      fechaEntrega:DateTime(2025,4,11), refCorte:'513_3005', ref:'513',
      fechaEstado:DateTime(2025,4,11)),
    OrdenModel(id:'2', numero:23, unidades:50, estado:OrdenEstado.pendiente,
      tipo:OrdenTipo.terceros, cliente:'Maria García López',
      fechaEntrega:DateTime(2025,4,15), refCorte:'520_1002', ref:'520',
      fechaEstado:DateTime(2025,4,12)),
    OrdenModel(id:'5', numero:27, unidades:180, estado:OrdenEstado.enProduccion,
      tipo:OrdenTipo.terceros, cliente:'Distribuidora Ropa S.A.',
      fechaEntrega:DateTime(2025,4,22), refCorte:'560_4010', ref:'560',
      fechaEstado:DateTime(2025,4,15)),
    OrdenModel(id:'6', numero:29, unidades:90, estado:OrdenEstado.pendiente,
      tipo:OrdenTipo.terceros, cliente:'Boutique Luna Nueva',
      fechaEntrega:DateTime(2025,4,28), refCorte:'575_4020', ref:'575',
      fechaEstado:DateTime(2025,4,16)),
    // ── Producción propia ─────────────────────────────────────────────────
    OrdenModel(id:'3', numero:24, unidades:120, estado:OrdenEstado.enProduccion,
      tipo:OrdenTipo.produccion, cliente:'Carlos Restrepo',
      fechaEntrega:DateTime(2026,4,20), refCorte:'530_2010', ref:'530',
      fechaEstado:DateTime(2026,4,13)),
    OrdenModel(id:'4', numero:25, unidades:75, estado:OrdenEstado.pendiente,
      tipo:OrdenTipo.produccion, cliente:'Ana Rodríguez',
      fechaEntrega:DateTime(2026,4,18), refCorte:'540_3005', ref:'540',
      fechaEstado:DateTime(2026,4,14)),
       OrdenModel(id:'5', numero:26, unidades:75, estado:OrdenEstado.pendiente,
      tipo:OrdenTipo.terceros, cliente:'Ana Rodríguez',
      fechaEntrega:DateTime(2026,4,18), refCorte:'540_3005', ref:'540',
      fechaEstado:DateTime(2026,4,14)),
    OrdenModel(id:'7', numero:28, unidades:200, estado:OrdenEstado.enProduccion,
      tipo:OrdenTipo.produccion, cliente:'Moda Express Ltda.',
      fechaEntrega:DateTime(2026,4,25), refCorte:'550_1500', ref:'550',
      fechaEstado:DateTime(2026,4,17)),
    OrdenModel(id:'8', numero:30, unidades:60, estado:OrdenEstado.pendiente,
      tipo:OrdenTipo.produccion, cliente:'Estilo y Color S.A.S.',
      fechaEntrega:DateTime(2026,5,2), refCorte:'580_2200', ref:'580',
      fechaEstado:DateTime(2026,4,18)),
    // ── Órdenes en etapa avanzada ────────────────────────────────────────────
    OrdenModel(id:'9', numero:33, unidades:250, estado:OrdenEstado.enProduccion,
      tipo:OrdenTipo.terceros, cliente:'Almacenes Éxito Moda',
      fechaEntrega:DateTime(2025,4,30), refCorte:'590_3300', ref:'590',
      fechaEstado:DateTime(2025,4,19)),
    OrdenModel(id:'10', numero:35, unidades:400, estado:OrdenEstado.enProduccion,
      tipo:OrdenTipo.produccion, cliente:'Falabella Colombia S.A.',
      fechaEntrega:DateTime(2025,5,5), refCorte:'610_4400', ref:'610',
      fechaEstado:DateTime(2025,4,20)),
  ];

  @override
  Future<List<OrdenModel>> getOrdenes({OrdenEstado? estado, OrdenTipo? tipo, String? query}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockData.where((orden) {
      if (estado != null && orden.estado != estado) return false;
      if (tipo != null && orden.tipo != tipo) return false;
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        if (!orden.numero.toString().contains(q) &&
            !(orden.cliente?.toLowerCase().contains(q) ?? false) &&
            !(orden.ref?.toLowerCase().contains(q) ?? false)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<OrdenDetailEntity?> getOrdenDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return OrdenDetailModel.findById(id);
  }
}
