import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../domain/dashboard_chart_point_entity.dart';
import '../domain/dashboard_metric_entity.dart';

const String _kBase = 'http://10.0.2.2:3000/api';

// Estados reales del backend → proceso del gráfico de barras (igual que web)
const _estadoAProceso = {
  'En espera':           'En espera',
  'Diseño':              'Diseño',
  'Ficha Técnica':       'Ficha técnica',
  'Ficha tecnica':       'Ficha técnica',
  'Corte':               'Corte',
  'Producción':          'En producción',
  'En producción':       'En producción',
  'Compras':             'Compras',
  'Empaque':             'Bodega',
  'Enviado':             'Recepción',
  'Anulada':             'Cancelado',
  'Tráfico entre sedes': 'Tráfico entre sedes',
  'Mercadeo':            'Mercadeo',
};

const _barProcesses = [
  'En espera', 'Tráfico entre sedes', 'Ficha técnica', 'Corte', 'Diseño',
  'En producción', 'Bodega', 'Mercadeo', 'Cancelado', 'Compras', 'Recepción',
];

class DashboardDataSource {

  /// Carga TODOS los KPIs en una sola llamada (evita recargas múltiples).
  Future<DashboardStats> getStats() async {
    try {
      // Dos llamadas en paralelo: órdenes e insumos
      final results = await Future.wait([
        _fetchList('$_kBase/produccion/ordenes'),
        _fetchList('$_kBase/insumos'),
      ]);

      final orders  = results[0];
      final insumos = results[1];
      final now     = DateTime.now();

      // ── Actuales: órdenes con estado exacto "Producción" o "En producción"
      // (igual que el web: x.estado === 'Producción')
      final activas = orders.where((o) {
        final e = (o['estado'] ?? '').toString();
        return e == 'Producción' || e == 'En producción';
      }).length;

      // ── Completadas este mes: estado "Enviado" y la fecha del historial
      // en que se marcó Enviado cae en el mes actual
      final completadasMes = orders.where((o) {
        if ((o['estado'] ?? '') != 'Enviado') return false;
        final hist = (o['historial'] as List<dynamic>?) ?? [];
        final entry = hist.cast<Map>().firstWhere(
          (h) => (h['estado'] ?? '') == 'Enviado',
          orElse: () => <String, dynamic>{},
        );
        final fecha = entry['fecha'] ?? o['updatedAt'];
        if (fecha == null) return false;
        final d = DateTime.tryParse(fecha.toString());
        return d != null && d.month == now.month && d.year == now.year;
      }).length;

      // ── Por iniciar: Diseño o Ficha Técnica (igual que el web)
      final porIniciar = orders.where((o) {
        final e = (o['estado'] ?? '').toString();
        return e == 'Diseño' || e == 'Ficha Técnica' || e == 'Ficha tecnica';
      }).length;

      // ── Tiempo promedio: órdenes Enviadas el mes ANTERIOR (igual que web)
      final prevMonth = now.month == 1 ? 12 : now.month - 1;
      final prevYear  = now.month == 1 ? now.year - 1 : now.year;
      final prevDone  = orders.where((o) {
        if ((o['estado'] ?? '') != 'Enviado') return false;
        final hist = (o['historial'] as List<dynamic>?) ?? [];
        final entry = hist.cast<Map>().firstWhere(
          (h) => (h['estado'] ?? '') == 'Enviado',
          orElse: () => <String, dynamic>{},
        );
        final fecha = entry['fecha'] ?? o['updatedAt'];
        if (fecha == null) return false;
        final d = DateTime.tryParse(fecha.toString());
        return d != null && d.month == prevMonth && d.year == prevYear;
      }).toList();

      String avgTime = '—';
      if (prevDone.isNotEmpty) {
        int totalDays = 0;
        int count = 0;
        for (final o in prevDone) {
          final start = DateTime.tryParse(
              (o['fecha_creacion'] ?? o['createdAt'] ?? '').toString());
          final hist = (o['historial'] as List<dynamic>?) ?? [];
          final entry = hist.cast<Map>().firstWhere(
            (h) => (h['estado'] ?? '') == 'Enviado',
            orElse: () => <String, dynamic>{},
          );
          final end = DateTime.tryParse(
              (entry['fecha'] ?? o['updatedAt'] ?? '').toString());
          if (start != null && end != null) {
            totalDays += end.difference(start).inDays.abs();
            count++;
          }
        }
        if (count > 0) avgTime = '${(totalDays / count).round()}d';
      }

      // ── Retrasos: órdenes activas (no Anulada/Enviado) con fecha_entrega vencida
      final todasActivas = orders.where((o) {
        final e = (o['estado'] ?? '').toString();
        return e != 'Anulada' && e != 'Enviado';
      }).toList();

      int delayed = 0, onTrack = 0;
      for (final o in todasActivas) {
        bool isDelayed = false;
        final fe = o['fecha_entrega'];
        if (fe != null) {
          final d = DateTime.tryParse(fe.toString());
          if (d != null && now.isAfter(d)) isDelayed = true;
        }
        isDelayed ? delayed++ : onTrack++;
      }

      // ── Procesos (barras): conteo por estado mapeado
      final Map<String, int> procesoCounts = {
        for (final p in _barProcesses) p: 0,
      };
      for (final o in orders) {
        final proceso = _estadoAProceso[(o['estado'] ?? '').toString()];
        if (proceso != null) {
          procesoCounts[proceso] = (procesoCounts[proceso] ?? 0) + 1;
        }
      }

      // ── Insumos (igual que el web):
      // - adquisicion:    insumos con stock == 0  (pendientes de compra)
      // - almacenamiento: total de insumos activos
      // - stock:          sumatoria de todas las unidades en stock
      final insumosSinStock = insumos
          .where((s) => (s['stock'] ?? s['cantidad'] ?? 0) == 0)
          .length;
      final insumosTotal = insumos.length;
      final stockTotal   = insumos.fold<int>(
        0,
        (sum, s) => sum + ((s['stock'] ?? s['cantidad'] ?? 0) as num).toInt(),
      );

      return DashboardStats(
        activas:         activas,
        completadasMes:  completadasMes,
        porIniciar:      porIniciar,
        avgTime:         avgTime,
        delayed:         delayed,
        onTrack:         onTrack,
        procesoCounts:   procesoCounts,
        insumosSinStock: insumosSinStock,
        insumosTotal:    insumosTotal,
        stockTotal:      stockTotal,
      );
    } catch (e) {
      return DashboardStats.empty();
    }
  }

  // Expuestos para compatibilidad con el provider anterior
  Future<List<DashboardMetricEntity>> getMetrics() async {
    final s = await getStats();
    return [
      DashboardMetricEntity(
        title: 'ACTUALES', subtitle: 'prod.',
        icon: Icons.bolt_rounded,
        color: const Color(0xFF7C4DFF),
        value: s.activas,
      ),
      DashboardMetricEntity(
        title: 'COMPLETADAS', subtitle: 'este mes',
        icon: Icons.check_rounded,
        color: const Color(0xFF00C853),
        value: s.completadasMes,
      ),
      DashboardMetricEntity(
        title: 'POR INICIAR', subtitle: 'pendientes',
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

  // ── HTTP helper ────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> _fetchList(String url) async {
    final response = await http
        .get(Uri.parse(url), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 8));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is List) return body.cast<Map<String, dynamic>>();
      if (body is Map && body['data'] is List) {
        return (body['data'] as List).cast<Map<String, dynamic>>();
      }
    }
    return [];
  }
}

/// Todos los KPIs calculados de una sola carga.
class DashboardStats {
  final int    activas;
  final int    completadasMes;
  final int    porIniciar;
  final String avgTime;
  final int    delayed;
  final int    onTrack;
  final Map<String, int> procesoCounts;
  final int    insumosSinStock;
  final int    insumosTotal;
  final int    stockTotal;

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
    activas: 0, completadasMes: 0, porIniciar: 0,
    avgTime: '—', delayed: 0, onTrack: 0,
    procesoCounts: {for (final p in _barProcesses) p: 0},
    insumosSinStock: 0, insumosTotal: 0, stockTotal: 0,
  );
}
