import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Fila de un proceso: punto de color + etiqueta + valor, con una barra
/// "outline" (borde de color, relleno interno) en vez de la barra sólida
/// anterior — igual al estilo del mock de referencia.
class ProcessItem extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color barColor;

  const ProcessItem({
    super.key,
    required this.label,
    required this.value,
    required this.maxValue,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = maxValue > 0
        ? (value / maxValue).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTheme.sp(context, 6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: barColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: AppTheme.sp(context, 7)),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: AppTheme.fs(context, 12),
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: AppTheme.fs(context, 12),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.titleColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.sp(context, 5)),
          Container(
            height: 12,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: barColor, width: 1.3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
