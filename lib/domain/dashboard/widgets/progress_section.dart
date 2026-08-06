import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../presentation/providers/dashboard_provider.dart';
import '../theme/app_theme.dart';

/// Tarjeta "Insumos": mismo estilo de barra fina que SummaryCard.
/// Usa los campos reales que expone el backend (insumosSinStock,
/// insumosTotal, stockTotal) — el mock de referencia mostraba 3 etapas
/// (Adquisición/Almacén/Producción) que el backend actual no calcula,
/// así que se mantienen las 3 métricas reales que ya existían.
class ProgressSection extends StatelessWidget {
  const ProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final stats = provider.stats;
    final hPad = AppTheme.sp(context, 12);
    final vPad = AppTheme.sp(context, 12);

    final maxVal = [
      stats.insumosSinStock,
      stats.insumosTotal,
      1,
    ].reduce((a, b) => a > b ? a : b);

    final items = [
      _ProgressData('Sin stock', stats.insumosSinStock, maxVal, AppTheme.pink),
      _ProgressData(
        'Total insumos',
        stats.insumosTotal,
        maxVal,
        AppTheme.green,
      ),
      _ProgressData(
        'Unidades',
        stats.stockTotal.clamp(0, maxVal * 10),
        maxVal * 10,
        AppTheme.purple,
      ),
    ];

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
              Icon(
                Icons.shopping_cart_outlined,
                size: 13,
                color: AppTheme.pink,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  'Insumos',
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
            for (var i = 0; i < items.length; i++) ...[
              _InsumoBar(data: items[i]),
              if (i != items.length - 1)
                SizedBox(height: AppTheme.sp(context, 8)),
            ],
        ],
      ),
    );
  }
}

class _InsumoBar extends StatelessWidget {
  final _ProgressData data;
  const _InsumoBar({required this.data});

  @override
  Widget build(BuildContext context) {
    final progress = data.maxValue > 0
        ? (data.value / data.maxValue).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data.label,
              style: TextStyle(
                fontSize: AppTheme.fs(context, 10),
                color: AppTheme.mutedColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${data.value}',
              style: TextStyle(
                fontSize: AppTheme.fs(context, 12),
                fontWeight: FontWeight.w700,
                color: data.color,
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
            border: Border.all(color: data.color, width: 1.2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: data.color,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressData {
  final String label;
  final int value;
  final int maxValue;
  final Color color;
  const _ProgressData(this.label, this.value, this.maxValue, this.color);
}
