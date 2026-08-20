import 'package:flutter/material.dart';

import '../../data/dashboard_data_source.dart';
import '../../domain/dashboard_chart_point_entity.dart';
import '../../domain/dashboard_metric_entity.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardDataSource _dataSource;

  DashboardStats stats = DashboardStats.empty();
  List<DashboardMetricEntity> metrics = [];
  List<DashboardChartPointEntity> chartPoints = [];
  bool isLoading = false;

  DashboardPeriod _period = DashboardPeriod.semana;
  DashboardPeriod get period => _period;

  DashboardProvider({DashboardDataSource? dataSource})
    : _dataSource = dataSource ?? DashboardDataSource() {
    load();
  }

  Future<void> setPeriod(DashboardPeriod p) async {
    if (_period == p) return;
    _period = p;
    await load();
  }

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    stats = await _dataSource.getStats(period: _period);

    metrics = [
      DashboardMetricEntity(
        title: 'ACTUALES',
        subtitle: 'prod.',
        icon: Icons.bolt_rounded,
        color: const Color(0xFF7C4DFF),
        value: stats.activas,
      ),
      DashboardMetricEntity(
        title: 'COMPLETADAS',
        subtitle: period.label.toLowerCase(),
        icon: Icons.check_rounded,
        color: const Color(0xFF00C853),
        value: stats.completadasMes,
      ),
      DashboardMetricEntity(
        title: 'POR INICIAR',
        subtitle: 'pendientes',
        icon: Icons.schedule_rounded,
        color: const Color(0xFFFF4FA3),
        value: stats.porIniciar,
      ),
    ];

    chartPoints = stats.procesoCounts.entries
        .map((e) => DashboardChartPointEntity(label: e.key, value: e.value))
        .toList();

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
