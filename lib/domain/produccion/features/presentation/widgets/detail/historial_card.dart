import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../domain/entities/historial_entry_entity.dart';

/// Tarjeta de historial con línea de tiempo vertical y animación stagger.
class HistorialCard extends StatelessWidget {
  final List<HistorialEntryEntity> historial;
  final VoidCallback? onVerTodo;

  const HistorialCard({
    super.key,
    required this.historial,
    this.onVerTodo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Historial',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: onVerTodo,
                child: const Text(
                  'Ver todo',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          // "Estado" chip
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Estado',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Empty state
          if (historial.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Sin eventos registrados.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            )
          else
            // Timeline entries
            ...historial.asMap().entries.map((e) {
              final entry = e.value;
              final isLast = e.key == historial.length - 1;

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration:
                    Duration(milliseconds: 340 + e.key * 75),
                curve: Curves.easeOutCubic,
                builder: (_, v, child) =>
                    Opacity(opacity: v, child: child),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dot + vertical line
                      Column(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin:
                                const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 1.5,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 3),
                                color: AppColors.primary
                                    .withAlpha(55),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Content
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: isLast ? 0 : 14),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              // Etapa + fecha
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.etapa,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd/MM/yyyy')
                                          .format(entry.fecha),
                                      style: const TextStyle(
                                        color:
                                            AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Responsable
                              Text(
                                entry.responsable,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
