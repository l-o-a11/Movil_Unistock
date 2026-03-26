import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../produccion/core/constants/app_colors.dart';
import '../../../domain/entities/tercero_produccion_entity.dart';

/// Tab "Producciones" del detalle de un tercero.
class TerceroProduccionesTab extends StatelessWidget {
  final List<TerceroProduccionEntity> producciones;
  const TerceroProduccionesTab({super.key, required this.producciones});

  @override
  Widget build(BuildContext context) {
    if (producciones.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.inbox_outlined, size: 52, color: AppColors.iconInactive.withAlpha(120)),
          const SizedBox(height: 12),
          const Text('Sin producciones asociadas', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ]),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 3))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Información de Corte', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
              child: const Row(children: [
                Expanded(child: Text('CORTE', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5))),
                Text('FECHA', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              ]),
            ),
            const SizedBox(height: 4),
            ...producciones.asMap().entries.map((e) {
              final prod = e.value;
              final isLast = e.key == producciones.length - 1;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 320 + e.key * 80),
                curve: Curves.easeOutCubic,
                builder: (_, v, child) => Opacity(opacity: v, child: child),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: isLast ? Colors.transparent : AppColors.divider, width: 0.8)),
                  ),
                  child: Row(children: [
                    Expanded(child: Text(prod.corte, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700))),
                    Text(DateFormat('dd/MM/yyyy').format(prod.fecha), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  ]),
                ),
              );
            }),
          ]),
        ),
      ],
    );
  }
}
