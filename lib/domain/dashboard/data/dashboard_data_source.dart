import 'package:flutter/material.dart';

import '../domain/dashboard_chart_point_entity.dart';
import '../domain/dashboard_metric_entity.dart';

/// Data source local de dashboard.
class DashboardDataSource {
  Future<List<DashboardMetricEntity>> getMetrics() async {
    await Future.delayed(const Duration(milliseconds: 180));
    return const [
      DashboardMetricEntity(
        title: 'Producción',
        subtitle: 'Ordenes activas',
        icon: Icons.bar_chart_rounded,
        color: Color(0xFF7C4DFF),
        value: 18,
      ),
      DashboardMetricEntity(
        title: 'Resumen',
        subtitle: 'Resumen rápido',
        icon: Icons.insights_rounded,
        color: Color(0xFFFF4FA3),
        value: 72,
      ),
      DashboardMetricEntity(
        title: 'Insumos',
        subtitle: 'Stock disponible',
        icon: Icons.inventory_2_outlined,
        color: Color(0xFF00C853),
        value: 44,
      ),
      DashboardMetricEntity(
        title: 'Reportes',
        subtitle: 'Nuevos reportes',
        icon: Icons.article_outlined,
        color: Color(0xFFFFAB00),
        value: 6,
      ),
    ];
  }

  Future<List<DashboardChartPointEntity>> getChartPoints() async {
    await Future.delayed(const Duration(milliseconds: 180));
    return const [
      DashboardChartPointEntity(label: 'En espera', value: 48),
      DashboardChartPointEntity(label: 'Habilitación', value: 28),
      DashboardChartPointEntity(label: 'Hoja técnica', value: 16),
      DashboardChartPointEntity(label: 'Corte', value: 18),
      DashboardChartPointEntity(label: 'Diseño', value: 14),
      DashboardChartPointEntity(label: 'En producción', value: 22),
      DashboardChartPointEntity(label: 'Bodega', value: 12),
      DashboardChartPointEntity(label: 'Vehículos', value: 20),
      DashboardChartPointEntity(label: 'Cancelados', value: 8),
      DashboardChartPointEntity(label: 'Compras', value: 4),
      DashboardChartPointEntity(label: 'Recepción', value: 2),
    ];
  }
}
