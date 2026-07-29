import '../models/orden_model.dart';
import '../models/orden_detail_model.dart';
import '../../domain/entities/orden_detail_entity.dart';

/// Contrato para acceso local a datos de órdenes.
abstract class OrdenLocalDataSource {
  Future<List<OrdenModel>> getOrdenes({
    String? estado,
    String? tipo,
    String? query,
  });

  Future<OrdenDetailEntity?> getOrdenDetail(String id);

  Future<OrdenDetailEntity?> avanzarEstado(String id, String nuevoEstado);

  Future<OrdenDetailEntity?> confirmarEtapa(String id);
}

/// Implementación local de [OrdenLocalDataSource].
/// En producción, los datos provienen de la API. Este fallback sirve
/// como mock para desarrollo cuando no hay conexión.
class OrdenLocalDataSourceImpl implements OrdenLocalDataSource {
  @override
  Future<List<OrdenModel>> getOrdenes({
    String? estado,
    String? tipo,
    String? query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 260));
    // Mock data útil para desarrollo y para que los filtros funcionen
    final mocks = [
      {
        '_id': '101',
        'numero_orden': 101,
        'estado': 'Producción',
        'tipo': 'produccion',
        'cliente': 'ACME S.A.',
        'fecha_entrega': DateTime.now()
            .add(const Duration(days: 3))
            .toIso8601String(),
        'detalles': [
          {'cantidad': 50, 'color': 'Rojo', 'id_producto': 'P-01'},
        ],
      },
      {
        '_id': '102',
        'numero_orden': 102,
        'estado': 'Diseño',
        'tipo': 'produccion',
        'cliente': 'Textilería Andina',
        'fecha_entrega': DateTime.now()
            .add(const Duration(days: 10))
            .toIso8601String(),
        'detalles': [
          {'cantidad': 30, 'color': 'Azul', 'id_producto': 'P-02'},
        ],
      },
      {
        '_id': '103',
        'numero_orden': 103,
        'estado': 'Enviado',
        'tipo': 'produccion',
        'cliente': 'Corte Express',
        'fecha_entrega': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        'detalles': [
          {'cantidad': 20, 'color': 'Negro', 'id_producto': 'P-03'},
        ],
      },
      {
        '_id': '104',
        'numero_orden': 104,
        'estado': 'Anulada',
        'tipo': 'produccion',
        'cliente': 'Cliente X',
        'fecha_entrega': DateTime.now()
            .add(const Duration(days: 5))
            .toIso8601String(),
        'detalles': [
          {'cantidad': 10, 'color': 'Blanco', 'id_producto': 'P-04'},
        ],
      },
      {
        '_id': '201',
        'numero_orden': 201,
        'estado': 'Producción',
        'tipo': 'terceros',
        'cliente': 'Proveedor Tercero',
        'fecha_entrega': DateTime.now()
            .add(const Duration(days: 7))
            .toIso8601String(),
        'detalles': [
          {'cantidad': 120, 'color': 'Verde', 'id_producto': 'P-10'},
        ],
      },
      {
        '_id': '202',
        'numero_orden': 202,
        'estado': 'Empaque',
        'tipo': 'terceros',
        'cliente': 'Proveedor Y',
        'fecha_entrega': DateTime.now()
            .add(const Duration(days: 1))
            .toIso8601String(),
        'detalles': [
          {'cantidad': 5, 'color': 'Amarillo', 'id_producto': 'P-11'},
        ],
      },
    ];

    List<OrdenModel> list = mocks.map((m) => OrdenModel.fromJson(m)).toList();

    // Aplicar filtros locales como hace la API opcionalmente
    if (tipo != null && tipo.isNotEmpty) {
      list = list.where((o) => o.tipo == tipo.toLowerCase()).toList();
    }
    if (estado != null && estado.isNotEmpty) {
      list = list.where((o) => o.estado == estado).toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((o) {
        return (o.cliente ?? '').toLowerCase().contains(q) ||
            (o.producto ?? '').toLowerCase().contains(q) ||
            (o.ref ?? '').toLowerCase().contains(q) ||
            ('${o.numero}').contains(q);
      }).toList();
    }

    return list;
  }

  @override
  Future<OrdenDetailEntity?> getOrdenDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 180));
    // Proveer un detalle simple de mock para desarrollo
    try {
      final mock = {
        '_id': id,
        'numero_orden': int.tryParse(id) ?? 0,
        'unidades': 50,
        'estado': 'Producción',
        'tipo': 'produccion',
        'cliente': 'ACME S.A.',
        'fechaEntrega': DateTime.now()
            .add(const Duration(days: 3))
            .toIso8601String(),
        'detalles': [
          {
            'cantidad': 50,
            'color': 'Rojo',
            'id_producto': 'P-01',
            'producto': 'Camiseta',
          },
        ],
        'historial': [
          {
            'etapa': 'Producción',
            'fecha': DateTime.now().toIso8601String(),
            'responsable': 'Operario',
          },
        ],
        // Progreso puede venir en 0..1 o 0..100. Probamos con 45 (normalizable).
        'progreso': 45,
        'etapaActual': 3,
        'referencias': [
          {
            'codigo': 'REF-01',
            'cantidad': 50,
            'colorHex': '#FF0000',
            'colorName': 'Rojo',
          },
        ],
        // Ficha técnica de ejemplo para que la UI muestre nombre/version y costos
        'fichaCosto': {
          'nombre': 'Ficha Camiseta Básica',
          'version': '1.2',
          'costoPorUnidad': 1200,
          'costoTotal': 60000,
          'completado': false,
        },
      };
      // Usar el modelo de detalle que extiende OrdenDetailEntity
      return OrdenDetailModel.fromJson(Map<String, dynamic>.from(mock));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<OrdenDetailEntity?> avanzarEstado(String id, String nuevoEstado) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final current = await getOrdenDetail(id);
    if (current == null) return null;
    return OrdenDetailModel.fromJson({
      ..._toMockJson(current),
      'estado': nuevoEstado,
      'etapaConfirmada': false,
    });
  }

  @override
  Future<OrdenDetailEntity?> confirmarEtapa(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final current = await getOrdenDetail(id);
    if (current == null) return null;
    return OrdenDetailModel.fromJson({
      ..._toMockJson(current),
      'etapaConfirmada': true,
    });
  }

  Map<String, dynamic> _toMockJson(OrdenDetailEntity d) => {
    '_id': d.id,
    'numero_orden': d.numero,
    'unidades': d.unidades,
    'estado': d.estado,
    'tipo': d.tipo,
    'cliente': d.cliente,
    'fechaEntrega': d.fechaEntrega?.toIso8601String(),
  };
}
