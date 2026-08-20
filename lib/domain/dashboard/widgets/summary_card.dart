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
          else
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SummaryRow(
                    label: 'Producciones',
                    sub: 'Con retraso',
                    value: '$alertas',
                    color: AppTheme.pink,
                    progress: totalActivos > 0 ? alertas / totalActivos : 0,
                  ),
                  _SummaryRow(
                    label: 'Sin novedades',
                    sub: 'Todo en orden',
                    value: '$activos',
                    color: AppTheme.green,
                    progress: totalActivos > 0 ? activos / totalActivos : 0,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String sub;
  final String value;
  final Color color;
  final double progress;

  const _SummaryRow({
    required this.label,
    required this.sub,
    required this.value,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: AppTheme.fs(context, 9),
                    color: AppTheme.mutedColor,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppTheme.fs(context, 11),
                    color: AppTheme.titleColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: AppTheme.fs(context, 18),
                fontWeight: FontWeight.w800,
                color: color,
              ),
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
