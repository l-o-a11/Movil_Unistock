import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../presentation/providers/dashboard_provider.dart';
import '../theme/app_theme.dart';

class ProgressSection extends StatelessWidget {
  const ProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final stats = provider.stats;
    final hPad = AppTheme.sp(context, 16);
    final vPad = AppTheme.sp(context, 14);

    // maxValue dinámico: el mayor de los valores (mínimo 1 para no dividir entre 0)
    final maxVal = [stats.insumosTotal, 1].reduce((a, b) => a > b ? a : b);

    final items = [
      _ProgressData('Almacén', stats.insumosTotal, maxVal, AppTheme.green),
      _ProgressData(
        'Stock',
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
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.pink,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  'Control de Insumos',
                  style: TextStyle(
                    fontSize: AppTheme.fs(context, 13),
                    fontWeight: FontWeight.w700,
                    color: AppTheme.titleColor,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.sp(context, 14)),
          if (provider.isLoading)
            const Center(
              child: SizedBox(
                width: 20,
                height: 100,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            ...items.map((item) => _InsumoBar(data: item)),
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

    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.sp(context, 12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  data.label,
                  style: TextStyle(
                    fontSize: AppTheme.fs(context, 12),
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${data.value}',
                    style: TextStyle(
                      fontSize: AppTheme.fs(context, 13),
                      fontWeight: FontWeight.w700,
                      color: data.color,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 7,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 7,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [data.color.withOpacity(0.7), data.color],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: data.color.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
