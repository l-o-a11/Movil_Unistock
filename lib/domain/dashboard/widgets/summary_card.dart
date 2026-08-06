import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../presentation/providers/dashboard_provider.dart';
import '../theme/app_theme.dart';

/// Tarjeta "Resumen": 3 filas con barra fina bajo cada estadística,
/// estilo del mock de referencia.
class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final stats = provider.stats;
    final hPad = AppTheme.sp(context, 12);
    final vPad = AppTheme.sp(context, 12);

    final activos = stats.onTrack;
    final alertas = stats.delayed;
    final totalActivos = activos + alertas;
    final promDias = int.tryParse(
      RegExp(r'\d+').firstMatch(stats.avgTime)?.group(0) ?? '',
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, size: 13, color: AppTheme.pink),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  'Resumen',
                  style: TextStyle(
                    fontSize: AppTheme.fs(context, 12),
                    fontWeight: FontWeight.w700,
                    color: AppTheme.titleColor,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.sp(context, 10)),
          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else ...[
            _SummaryRow(
              label: 'Activos',
              value: '$activos',
              color: AppTheme.green,
              progress: totalActivos > 0 ? activos / totalActivos : 0,
              showUpIcon: true,
            ),
            SizedBox(height: AppTheme.sp(context, 8)),
            _SummaryRow(
              label: 'Alertas',
              value: '$alertas',
              color: AppTheme.pink,
              progress: totalActivos > 0 ? alertas / totalActivos : 0,
            ),
            SizedBox(height: AppTheme.sp(context, 8)),
            _SummaryRow(
              label: 'Prom. días',
              value: stats.avgTime,
              color: AppTheme.purple,
              progress: promDias != null ? (promDias / 15).clamp(0.0, 1.0) : 0,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double progress;
  final bool showUpIcon;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    required this.progress,
    this.showUpIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: AppTheme.fs(context, 10),
                color: AppTheme.mutedColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showUpIcon) ...[
                  Icon(Icons.arrow_upward_rounded, size: 9, color: color),
                  const SizedBox(width: 2),
                ],
                Text(
                  value,
                  style: TextStyle(
                    fontSize: AppTheme.fs(context, 12),
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 1.2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
