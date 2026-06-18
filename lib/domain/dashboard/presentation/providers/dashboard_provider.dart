import 'dart:async';
import 'package:flutter/material.dart';

import '../../data/dashboard_data_source.dart';
import '../../domain/dashboard_chart_point_entity.dart';
import '../../domain/dashboard_metric_entity.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardDataSource _dataSource;

  DashboardStats stats           = DashboardStats.empty();
  List<DashboardMetricEntity>    metrics     = [];
  List<DashboardChartPointEntity> chartPoints = [];
  bool isLoading = false;

  Timer? _timer;

  DashboardProvider({DashboardDataSource? dataSource})
      : _dataSource = dataSource ?? DashboardDataSource() {
    load();
    // Refresca cada 30 s — suficiente para producción, sin saturar la pantalla
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => load());
  }

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    // Una sola llamada a la API que calcula todos los KPIs
    stats = await _dataSource.getStats();

    // Construir métricas desde el stats ya calculado (sin re-llamar API)
    metrics = [
      DashboardMetricEntity(
        title: 'ACTUALES',   subtitle: 'prod.',
        icon: Icons.bolt_rounded,
        color: const Color(0xFF7C4DFF), value: stats.activas,
      ),
      DashboardMetricEntity(
        title: 'COMPLETADAS', subtitle: 'este mes',
        icon: Icons.check_rounded,
        color: const Color(0xFF00C853), value: stats.completadasMes,
      ),
      DashboardMetricEntity(
        title: 'POR INICIAR', subtitle: 'pendientes',
        icon: Icons.schedule_rounded,
        color: const Color(0xFFFF4FA3), value: stats.porIniciar,
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
    _timer?.cancel();
    super.dispose();
  }
}
