import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Tarjeta compacta de métrica (chip), estilo "4 en fila" con ícono arriba,
/// valor grande al centro y etiqueta abajo — inspirada en el mock de
/// referencia que compartió el equipo.
class DashboardCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String value;
  final String subtitle;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppTheme.scale(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.sp(context, 6),
        vertical: AppTheme.sp(context, 10),
      ),
      decoration: BoxDecoration(
        color: iconBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.35), width: 1.4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 17 * s),
          SizedBox(height: AppTheme.sp(context, 4)),
          Text(
            value,
            style: TextStyle(
              fontSize: AppTheme.fs(context, 16),
              fontWeight: FontWeight.w800,
              color: AppTheme.titleColor,
              height: 1.0,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: AppTheme.sp(context, 2)),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: AppTheme.fs(context, 9),
              color: AppTheme.mutedColor,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
