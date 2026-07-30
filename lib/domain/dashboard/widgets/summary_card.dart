import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../presentation/providers/dashboard_provider.dart';
import '../theme/app_theme.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final stats    = provider.stats;
    final hPad     = AppTheme.sp(context, 16);
    final vPad     = AppTheme.sp(context, 14);

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
                width: 8, height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.purple, shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  'Resumen Global',
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
          SizedBox(height: AppTheme.sp(context, 12)),
          _SummaryRow(
            icon: Icons.check_circle_rounded,
            label: 'Procesos activos',
            value: provider.isLoading ? '…' : '${stats.onTrack}',
            color: AppTheme.green,
          ),
          SizedBox(height: AppTheme.sp(context, 8)),
          _SummaryRow(
            icon: Icons.warning_amber_rounded,
            label: 'Alertas de retraso',
            value: provider.isLoading ? '…' : '${stats.delayed}',
            color: AppTheme.pink,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppTheme.scale(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.sp(context, 10),
        vertical:   AppTheme.sp(context, 10),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18 * s),
          SizedBox(width: AppTheme.sp(context, 8)),
          Expanded(
            child: Text(label,
              style: TextStyle(
                fontSize: AppTheme.fs(context, 11),
                fontWeight: FontWeight.w500,
                color: AppTheme.textColor,
              ),
              softWrap: true, maxLines: 2,
            ),
          ),
          Text(value,
            style: TextStyle(
              fontSize: AppTheme.fs(context, 18),
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
