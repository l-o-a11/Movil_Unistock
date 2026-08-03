import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/api_config.dart';
import '../domain/dashboard_chart_point_entity.dart';
import '../domain/dashboard_metric_entity.dart';

String get _kBase => '${ApiConfig.baseUrl}/api';

// Espejo exacto de ESTADO_TO_PROCESO en dashboard.jsx (web).
const _estadoAProceso = {
  'En espera': 'En espera',
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
  'Tráfico entre sedes': 'Tráfico entre sedes',
  'Mercadeo': 'Mercadeo',
};

const _barProcesses = [
  'En espera',
  'Tráfico entre sedes',
  'Ficha técnica',
  'Corte',
  'Diseño',
  'En producción',
  'Bodega',
  'Mercadeo',
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
  }) async {
    try {
      final results = await Future.wait([
        _fetchList('$_kBase/produccion/ordenes'),
        _fetchList('$_kBase/insumos'),
      ]);

      final orders = results[0];
      final insumos = results[1];
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
          final asignacionesRaw = o['asignaciones'];
          final asignaciones = asignacionesRaw is List
              ? asignacionesRaw
              : const <dynamic>[];
          if (_estadosEnProduccion.contains(estado) &&
              asignaciones.isNotEmpty) {
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
        if (!matchPeriod(orderDate(o), period)) continue;
        final proceso = _estadoAProceso[estado];
        if (proceso != null)
          procesoCounts[proceso] = (procesoCounts[proceso] ?? 0) + 1;
      }

      final insumosSinStock = insumos
          .where((s) => (s['stock'] ?? s['cantidad'] ?? 0) == 0)
          .length;
      final insumosTotal = insumos.length;
      final stockTotal = insumos.fold<int>(
        0,
        (s, i) => s + ((i['stock'] ?? i['cantidad'] ?? 0) as num).toInt(),
      );

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
      return DashboardStats.empty();
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

  Future<List<Map<String, dynamic>>> _fetchList(String url) async {
    final headers = <String, String>{'Accept': 'application/json'};
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}

    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return _extractList(body);
      }
    } catch (_) {}
    return [];
  }

  /// Extrae una lista tolerando varios formatos de respuesta del backend:
  /// `[...]`, `{data:[...]}`, `{data:{data:[...]}}`, `{docs:[...]}`,
  /// `{results:[...]}`, `{ordenes:[...]}`.
  List<Map<String, dynamic>> _extractList(dynamic raw) {
    List<dynamic> list;
    if (raw is List) {
      list = raw;
    } else if (raw is Map) {
      if (raw['data'] is List) {
        list = raw['data'] as List;
      } else if (raw['data'] is Map) {
        final inner = raw['data'] as Map;
        list = inner['data'] is List
            ? inner['data'] as List
            : inner['docs'] is List
            ? inner['docs'] as List
            : inner['results'] is List
            ? inner['results'] as List
            : inner['ordenes'] is List
            ? inner['ordenes'] as List
            : const [];
      } else if (raw['docs'] is List) {
        list = raw['docs'] as List;
      } else if (raw['results'] is List) {
        list = raw['results'] as List;
      } else if (raw['ordenes'] is List) {
        list = raw['ordenes'] as List;
      } else {
        list = const [];
      }
    } else {
      list = const [];
    }
    return list.whereType<Map>().cast<Map<String, dynamic>>().toList();
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
