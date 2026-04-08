import 'package:flutter/material.dart';

import '../../data/dashboard_data_source.dart';
import '../../domain/dashboard_chart_point_entity.dart';
import '../../domain/dashboard_metric_entity.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardDataSource _dataSource;

  List<DashboardMetricEntity> metrics = [];
  List<DashboardChartPointEntity> chartPoints = [];
  bool isLoading = false;

  DashboardProvider({DashboardDataSource? dataSource})
      : _dataSource = dataSource ?? DashboardDataSource() {
    load();
  }

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    metrics = await _dataSource.getMetrics();
    chartPoints = await _dataSource.getChartPoints();

    isLoading = false;
    notifyListeners();
  }
}
