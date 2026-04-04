import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../domain/entities/orden_referencia_entity.dart';

class ReferenciasCard extends StatelessWidget {
  final List<OrdenReferenciaEntity> referencias;
  const ReferenciasCard({super.key, required this.referencias});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8),
            blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.palette_rounded,
                  color: AppColors.primary, size: 17)),
            const SizedBox(width: 10),
            const Text('Referencias',
                style: TextStyle(color: AppColors.textPrimary,
                    fontSize: 14, fontWeight: FontWeight.w700)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.chipBackground,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('${referencias.length} ref.',
                  style: const TextStyle(color: AppColors.textSecondary,
                      fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 14),
          ...referencias.map((r) => _RefRow(ref: r)),
        ],
      ),
    );
  }
}

class _RefRow extends StatelessWidget {
  final OrdenReferenciaEntity ref;
  const _RefRow({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(children: [
        Container(width: 22, height: 22,
          decoration: BoxDecoration(
            color: ref.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black.withAlpha(15), width: 1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Ref. ${ref.codigo}',
              style: const TextStyle(color: AppColors.textPrimary,
                  fontSize: 13, fontWeight: FontWeight.w600)),
          Text(ref.colorName,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20)),
          child: Text('${ref.cantidad} uds',
              style: const TextStyle(color: AppColors.primary,
                  fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}
