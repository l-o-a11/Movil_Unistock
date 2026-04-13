import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProgressSection extends StatelessWidget {
  const ProgressSection({super.key});

  static const _items = [
    _ProgressData('Adquisición', 120, 120, AppTheme.pink),
    _ProgressData('Almacén',     115, 120, AppTheme.green),
    _ProgressData('Producción',  105, 120, AppTheme.purple),
  ];

  @override
  Widget build(BuildContext context) {
    final hPad = AppTheme.sp(context, 16);
    final vPad = AppTheme.sp(context, 14);

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
          ..._items.map((item) => _InsumoBar(data: item)),
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
    final progress = (data.value / data.maxValue).clamp(0.0, 1.0);
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.sp(context, 12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.label,
                style: TextStyle(
                  fontSize: AppTheme.fs(context, 12),
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textColor,
                ),
                softWrap: true,
                maxLines: 2,
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
                      colors: [
                        data.color.withOpacity(0.7),
                        data.color,
                      ],
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
