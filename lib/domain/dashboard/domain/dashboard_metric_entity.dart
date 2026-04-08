import 'package:flutter/material.dart';

/// Entidad de métrica del dashboard.
class DashboardMetricEntity {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int value;

  const DashboardMetricEntity({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.value,
  });
}
