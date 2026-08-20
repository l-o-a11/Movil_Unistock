import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Tarjeta de métrica estilo "Estado general de producción": ícono arriba,
/// etiqueta debajo (con ancho completo, hasta 2 líneas) y el valor en
/// grande y en negrita al final, alineado a la izquierda.
class DashboardCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String value;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.sp(context, 10),
        vertical: AppTheme.sp(context, 12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEF2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppTheme.sp(context, 26),
            height: AppTheme.sp(context, 26),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: AppTheme.sp(context, 14)),
          ),
          SizedBox(height: AppTheme.sp(context, 8)),
          Text(
            title,
            style: TextStyle(
              fontSize: AppTheme.fs(context, 11),
              fontWeight: FontWeight.w600,
              color: AppTheme.titleColor.withOpacity(0.72),
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppTheme.sp(context, 10)),
          Text(
            value,
            style: TextStyle(
              fontSize: AppTheme.fs(context, 24),
              fontWeight: FontWeight.w800,
              color: AppTheme.titleColor,
              letterSpacing: -0.6,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
