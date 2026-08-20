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

    final items = [
      _ProgressData(
        label: 'Almacenamiento',
        sub: 'Total de insumos',
        value: stats.insumosTotal,
        color: AppTheme.purple,
      ),
      _ProgressData(
        label: 'Stock',
        sub: 'Unidades totales',
        value: stats.stockTotal,
        color: AppTheme.green,
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
    return Container(
      height: 62,
      padding: EdgeInsets.symmetric(horizontal: AppTheme.sp(context, 12)),
      decoration: BoxDecoration(
        color: data.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: data.color.withOpacity(0.25), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.label,
                style: TextStyle(
                  fontSize: AppTheme.fs(context, 11),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.titleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.sub,
                style: TextStyle(
                  fontSize: AppTheme.fs(context, 9),
                  color: AppTheme.mutedColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            '${data.value}',
            style: TextStyle(
              fontSize: AppTheme.fs(context, 16),
              fontWeight: FontWeight.w800,
              color: data.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressData {
  final String label;
  final String sub;
  final int value;
  final Color color;
  const _ProgressData({
    required this.label,
    required this.sub,
    required this.value,
    required this.color,
  });
}
