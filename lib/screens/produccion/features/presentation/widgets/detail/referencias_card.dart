import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../domain/entities/orden_referencia_entity.dart';

/// Tabla de referencias (código, cantidad, color) de una orden.
class ReferenciasCard extends StatelessWidget {
  final List<OrdenReferenciaEntity> referencias;

  const ReferenciasCard({super.key, required this.referencias});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Text(
              'Referencia',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Column labels
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(
                    child: _ColLabel(text: 'Código')),
                Expanded(
                    child: _ColLabel(text: 'Cantidad')),
                _ColLabel(text: 'Color'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Rows with stagger animation
          ...referencias.asMap().entries.map((e) {
            final ref = e.value;
            final isLast = e.key == referencias.length - 1;

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 350 + e.key * 80),
              curve: Curves.easeOutCubic,
              builder: (_, v, child) =>
                  Opacity(opacity: v, child: child),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 28),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isLast
                          ? Colors.transparent
                          : AppColors.divider,
                      width: 0.8,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Código
                    Expanded(
                      child: Text(
                        ref.codigo,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // Cantidad
                    Expanded(
                      child: Text(
                        '${ref.cantidad}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // Color dot + label
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: ref.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ref.colorName,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _ColLabel extends StatelessWidget {
  final String text;
  const _ColLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
