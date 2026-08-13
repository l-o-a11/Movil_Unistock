import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import '../../../core/api_client.dart';
import '../domain/dashboard_chart_point_entity.dart';
import '../domain/dashboard_metric_entity.dart';

String get _kBase => '${ApiConfig.baseUrl}/api';

// Espejo exacto de ESTADO_TO_PROCESO en dashboard.jsx (web).
// FIX: se quitaron 'En espera', 'Tráfico entre sedes' y 'Mercadeo' — no
// existen como estados válidos en el backend (ProductionOrderModel.js no
// los tiene en su enum, y no aparecen en ningún lado de Api_Unistock), así
// que esos 3 procesos siempre mostraban 0. Se quitan hasta que el backend
// implemente esas etapas.
const _estadoAProceso = {
  'Diseño': 'Diseño',
  'Ficha Técnica': 'Ficha técnica',
  'Ficha tecnica': 'Ficha técnica',
  'Corte': 'Corte',
  'Producción': 'En producción',
  'En producción': 'En producción',
  'Compras': 'Compras',
  'Empaque': 'Bodega',
  'Enviado': 'Recepción',
  'Anulada': 'Cancelado',
};

const _barProcesses = [
  'Ficha técnica',
  'Corte',
  'Diseño',
  'En producción',
  'Bodega',
  'Cancelado',
  'Compras',
  'Recepción',
];

// El backend guarda el estado "en producción" con dos nombres distintos
// según la ruta que lo creó — igual que ESTADOS_EN_PRODUCCION en el web.
const _estadosEnProduccion = ['Producción', 'En producción'];

const _estadosPorIniciar = ['Diseño', 'Ficha Técnica', 'Ficha tecnica'];

/// Período de filtro — mismo que el web (Semana/Mes/Año)
enum DashboardPeriod { semana, mes, anio }

extension DashboardPeriodExt on DashboardPeriod {
  String get label {
    switch (this) {
      case DashboardPeriod.semana:
        return 'Semana';
      case DashboardPeriod.mes:
        return 'Mes';
      case DashboardPeriod.anio:
        return 'Año';
    }
  }
}

class DashboardDataSource {
  Future<DashboardStats> getStats({
    DashboardPeriod period = DashboardPeriod.mes,
    // FIX: en la web, "Procesos en Curso" (barData) usa un período
    // INDEPENDIENTE (barTimeView, por defecto 'Año') distinto al de las
    // tarjetas de KPI (timeView, por defecto 'Mes'). El móvil usaba el mismo
    // período para todo, así que "Cancelado" (y el resto de procesos)
    // contaba solo el mes actual en vez del año — de ahí el conteo distinto
    // entre web y móvil para el mismo dato.
    DashboardPeriod procesoPeriod = DashboardPeriod.anio,
  }) async {
    // Los insumos se calculan de forma AISLADA e independiente: aunque el
    // procesamiento de órdenes falle, el "Control de Insumos" del dashboard
    // siempre muestra los datos reales de insumos.
    //
    // Espejo de supplyAPI.getAll({ estado: true, limit: 1000 }) en dashboard.jsx:
    // solo se cuentan los insumos ACTIVOS (estado === true) y el stock total
    // suma EXCLUSIVAMENTE el campo `stock` (Number(s.stock) || 0), sin buscar
    // en otros campos (cantidad, stockActual, etc.) que la web no usa.
    final insumos = await _fetchList('$_kBase/insumos');
    final insumosActivos = insumos.where((i) {
      final estado = i['estado'];
      // El backend puede reportar estado como bool o como string; solo se
      // consideran los insumos activos (true / 'true' / 'Activo' / 'activo').
      if (estado == null) return true;
      if (estado is bool) return estado;
      final es = estado.toString().toLowerCase();
      return es == 'true' || es == 'activo';
    }).toList();
    // Suma SOLO el campo `stock` de cada insumo, como hace la web con
    // Number(s.stock) || 0. Los decimales se redondean para la vista.
    final stockTotal = insumosActivos.fold<int>(
      0,
      (s, i) => s + _toIntDecimal(i['stock']),
    );
    final insumosSinStock = insumosActivos
        .where((s) => _toIntDecimal(s['stock']) == 0)
        .length;
    final insumosTotal = insumosActivos.length;

    try {
      final orders = await _fetchList('$_kBase/produccion/ordenes');
      final now = DateTime.now();

      DateTime? parseDate(dynamic v) =>
          v == null ? null : DateTime.tryParse(v.toString());

      bool matchPeriod(dynamic rawDate, DashboardPeriod p) {
        final d = parseDate(rawDate);
        if (d == null) return false;
        switch (p) {
          case DashboardPeriod.semana:
            final weekday = now.weekday; // 1=lunes … 7=domingo
            final startOfWeek = DateTime(
              now.year,
              now.month,
              now.day,
            ).subtract(Duration(days: weekday - 1));
            final endOfWeek = startOfWeek
                .add(const Duration(days: 7))
                .subtract(const Duration(milliseconds: 1));
            return !d.isBefore(startOfWeek) && !d.isAfter(endOfWeek);
          case DashboardPeriod.mes:
            return d.month == now.month && d.year == now.year;
          case DashboardPeriod.anio:
            return d.year == now.year;
        }
      }

      List<Map> _safeHist(dynamic raw) {
        if (raw is List) return raw.whereType<Map>().toList();
        return const [];
      }

      dynamic orderDate(Map o) {
        final hist = _safeHist(o['historial']);
        final last = hist.isNotEmpty ? hist.last : null;
        return last?['fecha'] ??
            o['updatedAt'] ??
            o['createdAt'] ??
            o['fecha_creacion'];
      }

      bool inPeriodActive(Map o) {
        if (matchPeriod(o['updatedAt'], period)) return true;
        if (matchPeriod(o['createdAt'] ?? o['fecha_creacion'], period))
          return true;
        final hist = _safeHist(o['historial']);
        return hist.any((h) => matchPeriod(h['fecha'], period));
      }

      final currentInPeriod = orders.where((o) {
        final e = (o['estado'] ?? '').toString();
        return _estadosEnProduccion.contains(e) && inPeriodActive(o);
      }).length;
      final currentTotal = orders.where((o) {
        final e = (o['estado'] ?? '').toString();
        return _estadosEnProduccion.contains(e);
      }).length;
      final activas = currentInPeriod > 0 ? currentInPeriod : currentTotal;

      final completadasMes = orders.where((o) {
        if ((o['estado'] ?? '') != 'Enviado') return false;
        final hist = _safeHist(o['historial']);
        final entry = hist.cast<Map>().firstWhere(
          (h) => (h['estado'] ?? '') == 'Enviado',
          orElse: () => <String, dynamic>{},
        );
        return matchPeriod(entry['fecha'] ?? o['updatedAt'], period);
      }).length;

      final porIniciar = orders.where((o) {
        final e = (o['estado'] ?? '').toString();
        return e.isNotEmpty &&
            e != 'Anulada' &&
            _estadosPorIniciar.contains(e) &&
            inPeriodActive(o);
      }).length;

      final bool prevIsYear = period == DashboardPeriod.anio;
      final prevYearTarget = now.year - 1;
      final prevMonth = now.month == 1 ? 12 : now.month - 1;
      final prevMonthYear = now.month == 1 ? now.year - 1 : now.year;

      final prevDone = orders.where((o) {
        if ((o['estado'] ?? '') != 'Enviado') return false;
        final hist = _safeHist(o['historial']);
        final entry = hist.cast<Map>().firstWhere(
          (h) => (h['estado'] ?? '') == 'Enviado',
          orElse: () => <String, dynamic>{},
        );
        final d = parseDate(entry['fecha'] ?? o['updatedAt']);
        if (d == null) return false;
        return prevIsYear
            ? d.year == prevYearTarget
            : (d.month == prevMonth && d.year == prevMonthYear);
      }).toList();

      String avgTime = '—';
      if (prevDone.isNotEmpty) {
        int totalDays = 0, count = 0;
        for (final o in prevDone) {
          final hist = _safeHist(o['historial']);
          final primera = hist.isNotEmpty ? hist.first : null;
          final start = parseDate(
            o['createdAt'] ?? o['fecha_creacion'] ?? primera?['fecha'],
          );
          final entry = hist.cast<Map>().firstWhere(
            (h) => (h['estado'] ?? '') == 'Enviado',
            orElse: () => <String, dynamic>{},
          );
          final ultima = hist.isNotEmpty ? hist.last : null;
          final end = parseDate(
            entry['fecha'] ?? o['updatedAt'] ?? ultima?['fecha'],
          );
          if (start != null && end != null) {
            final dias = (end.difference(start).inMilliseconds / 86400000)
                .round();
            totalDays += dias < 0 ? 0 : dias;
            count++;
          }
        }
        if (count > 0) avgTime = '${(totalDays / count).round()}d';
      }

      final activeOrders = orders.where((o) {
        final e = (o['estado'] ?? '').toString();
        return e.isNotEmpty &&
            e != 'Anulada' &&
            e != 'Enviado' &&
            inPeriodActive(o);
      }).toList();

      int delayed = 0, onTrack = 0;
      for (final o in activeOrders) {
        bool isDelayed = false;
        final fe = o['fecha_entrega'] ?? o['deliveryDate'];
        if (fe != null) {
          final d = parseDate(fe);
          if (d != null && now.isAfter(d)) isDelayed = true;
        }
        if (!isDelayed) {
          final estado = (o['estado'] ?? '').toString();
          // FIX: el backend no tiene un campo unificado "asignaciones" — se
          // dividió en sedeAsignaciones/terceroAsignaciones/empleadoAsignadoId
          // (ver Production.js toJSON). Antes esto siempre leía una lista
          // vacía y esta señal de retraso nunca se activaba.
          final tieneAsignacion =
              (o['empleadoAsignadoId'] != null &&
                  o['empleadoAsignadoId'].toString().isNotEmpty) ||
              (o['sedeAsignaciones'] is List &&
                  (o['sedeAsignaciones'] as List).isNotEmpty) ||
              (o['terceroAsignaciones'] is List &&
                  (o['terceroAsignaciones'] as List).isNotEmpty);
          if (_estadosEnProduccion.contains(estado) && tieneAsignacion) {
            final hist = _safeHist(o['historial']);
            final entrada = hist.cast<Map>().firstWhere(
              (h) =>
                  _estadosEnProduccion.contains((h['estado'] ?? '').toString()),
              orElse: () => <String, dynamic>{},
            );
            final fechaEntrada =
                parseDate(entrada['fecha']) ?? parseDate(o['updatedAt']);
            if (fechaEntrada != null) {
              final dias = now.difference(fechaEntrada).inDays;
              if (dias > 17) isDelayed = true;
            }
          }
        }
        isDelayed ? delayed++ : onTrack++;
      }

      final Map<String, int> procesoCounts = {
        for (final p in _barProcesses) p: 0,
      };
      for (final o in orders) {
        final estado = (o['estado'] ?? '').toString();
        if (estado.isEmpty) continue;
        if (!matchPeriod(orderDate(o), procesoPeriod)) continue;
        final proceso = _estadoAProceso[estado];
        if (proceso != null)
          procesoCounts[proceso] = (procesoCounts[proceso] ?? 0) + 1;
      }

      return DashboardStats(
        activas: activas,
        completadasMes: completadasMes,
        porIniciar: porIniciar,
        avgTime: avgTime,
        delayed: delayed,
        onTrack: onTrack,
        procesoCounts: procesoCounts,
        insumosSinStock: insumosSinStock,
        insumosTotal: insumosTotal,
        stockTotal: stockTotal,
      );
    } catch (_) {
      // Si el procesamiento de órdenes falla, al menos conservamos los
      // datos de insumos ya calculados (no devolvemos todo en 0).
      return DashboardStats(
        activas: 0,
        completadasMes: 0,
        porIniciar: 0,
        avgTime: '—',
        delayed: 0,
        onTrack: 0,
        procesoCounts: {for (final p in _barProcesses) p: 0},
        insumosSinStock: insumosSinStock,
        insumosTotal: insumosTotal,
        stockTotal: stockTotal,
      );
    }
  }

  Future<List<DashboardMetricEntity>> getMetrics() async {
    final s = await getStats();
    return [
      DashboardMetricEntity(
        title: 'ACTUALES',
        subtitle: 'prod.',
        icon: Icons.bolt_rounded,
        color: const Color(0xFF7C4DFF),
        value: s.activas,
      ),
      DashboardMetricEntity(
        title: 'COMPLETADAS',
        subtitle: 'este mes',
        icon: Icons.check_rounded,
        color: const Color(0xFF00C853),
        value: s.completadasMes,
      ),
      DashboardMetricEntity(
        title: 'POR INICIAR',
        subtitle: 'pendientes',
        icon: Icons.schedule_rounded,
        color: const Color(0xFFFF4FA3),
        value: s.porIniciar,
      ),
    ];
  }

  Future<List<DashboardChartPointEntity>> getChartPoints() async {
    final s = await getStats();
    return s.procesoCounts.entries
        .map((e) => DashboardChartPointEntity(label: e.key, value: e.value))
        .toList();
  }

  /// Descarga la lista COMPLETA de un recurso recorriendo la paginación
  /// del backend.
  ///
  /// El backend (Mongoose) pagina `/insumos` y `/produccion/ordenes` con un
  /// límite por defecto (p. ej. 30), por lo que una sola petición devuelve
  /// solo la primera página. Este método pide `page`/`limit` de forma
  /// iterativa y acumula los resultados hasta:
  ///   - alcanzar el `total` reportado en los metadatos, o
  ///   - no obtener más registros nuevos (fin de los datos), o
  ///   - llegar a un tope de seguridad de 500 páginas.
  /// Los resultados se deduplican por id para evitar repetidos entre páginas.
  Future<List<Map<String, dynamic>>> _fetchList(String url) async {
    final headers = <String, String>{'Accept': 'application/json'};
    try {
      // Usamos el mismo mecanismo de autenticación robusto que el resto de
      // la app (ApiClient.getToken): lee SharedPreferences y, si no hay
      // token allí, hace fallback a FlutterSecureStorage. Leer solo de
      // SharedPreferences hacía que el endpoint de insumos devolviera 401
      // (sin token) y el dashboard mostrara 0.
      final token = await ApiClient.instance.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}

    const limit = 1000;
    final byId = <String, Map<String, dynamic>>{};
    var total = 0;
    var page = 1;

    while (page <= 500) {
      final base = Uri.parse(url);
      final pageUrl = base.replace(
        queryParameters: {
          ...base.queryParameters,
          'page': '$page',
          'limit': '$limit',
        },
      );

      List<Map<String, dynamic>> items;
      try {
        final response = await http
            .get(pageUrl, headers: headers)
            .timeout(const Duration(seconds: 8));
        if (response.statusCode != 200) break;
        final body = jsonDecode(response.body);
        items = _extractList(body);
        final t = _extractTotal(body);
        if (t > total) total = t;
      } catch (_) {
        // Error de red/parseo: conservar lo ya obtenido.
        break;
      }

      if (items.isEmpty) break;

      var added = 0;
      for (final item in items) {
        final id = (item['id'] ?? item['_id'] ?? '').toString();
        if (id.isNotEmpty) {
          if (!byId.containsKey(id)) {
            byId[id] = item;
            added++;
          }
        } else {
          // Sin id, lo agregamos siempre.
          byId['__no_id_${page}_${byId.length}'] = item;
          added++;
        }
      }

      // Si ya alcanzamos el total reportado por el backend, terminamos.
      if (total > 0 && byId.length >= total) break;
      // Si no hubo registros nuevos, el backend no avanzó la página:
      // terminamos con lo que llevamos.
      if (added == 0) break;

      page++;
    }
    return byId.values.toList();
  }

  /// Extrae el `total` de registros de los metadatos de paginación del
  /// backend, tolerando las variantes más comunes: `total` / `totalDocs` /
  /// `count` / `totalCount`. Busca tanto a nivel raíz como anidado en `data`.
  /// Devuelve 0 si no encuentra un total.
  int _extractTotal(dynamic body) {
    if (body is! Map) return 0;
    final root = Map<String, dynamic>.from(body);

    int? fromMap(Map<String, dynamic> m) {
      final t = m['total'] ?? m['totalDocs'] ?? m['count'] ?? m['totalCount'];
      return (t is num && t > 0) ? t.toInt() : null;
    }

    final direct = fromMap(root);
    if (direct != null) return direct;

    final inner = root['data'];
    if (inner is Map) {
      final nested = fromMap(Map<String, dynamic>.from(inner));
      if (nested != null) return nested;
    }
    return 0;
  }

  /// Convierte el campo `stock` de un insumo a entero (redondeado), espejo de
  /// `Number(s.stock) || 0` en dashboard.jsx. Tolera `num` y `String`.
  int _toIntDecimal(dynamic value) {
    if (value is num) return value.round();
    if (value is String && value.trim().isNotEmpty) {
      final v = double.tryParse(value.trim());
      return v?.round() ?? 0;
    }
    return 0;
  }

  /// Extrae una lista tolerando varios formatos de respuesta del backend:
  /// `[...]`, `{data:[...]}`, `{data:{data:[...]}}`, `{docs:[...]}`,
  /// `{results:[...]}`, `{ordenes:[...]}`, `{items:[...]}`, `{insumos:[...]}`
  /// y variantes paginadas anidadas (`{data:{items:[...]}}`, etc.).
  List<Map<String, dynamic>> _extractList(dynamic raw) {
    List<dynamic> list;
    if (raw is List) {
      list = raw;
    } else if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      if (map['data'] is List) {
        list = map['data'] as List;
      } else if (map['data'] is Map) {
        final inner = Map<String, dynamic>.from(map['data'] as Map);
        list = _firstList(inner);
      } else {
        list = _firstList(map);
      }
    } else {
      list = const [];
    }
    return list.whereType<Map>().cast<Map<String, dynamic>>().toList();
  }

  /// Devuelve la primera lista reconocible dentro de un mapa, recorriendo
  /// las claves más comunes de respuestas paginadas del backend.
  List<dynamic> _firstList(Map<String, dynamic> map) {
    const keys = ['data', 'docs', 'results', 'ordenes', 'items', 'insumos'];
    for (final key in keys) {
      if (map[key] is List) return map[key] as List;
    }
    return const [];
  }
}

class DashboardStats {
  final int activas, completadasMes, porIniciar, delayed, onTrack;
  final String avgTime;
  final Map<String, int> procesoCounts;
  final int insumosSinStock, insumosTotal, stockTotal;

  const DashboardStats({
    required this.activas,
    required this.completadasMes,
    required this.porIniciar,
    required this.avgTime,
    required this.delayed,
    required this.onTrack,
    required this.procesoCounts,
    required this.insumosSinStock,
    required this.insumosTotal,
    required this.stockTotal,
  });

  factory DashboardStats.empty() => DashboardStats(
    activas: 0,
    completadasMes: 0,
    porIniciar: 0,
    avgTime: '—',
    delayed: 0,
    onTrack: 0,
    procesoCounts: {for (final p in _barProcesses) p: 0},
    insumosSinStock: 0,
    insumosTotal: 0,
    stockTotal: 0,
  );
}