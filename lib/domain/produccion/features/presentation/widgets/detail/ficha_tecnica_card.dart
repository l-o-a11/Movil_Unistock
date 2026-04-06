import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../domain/entities/ficha_costo_entity.dart';

/// Tarjeta completa de ficha técnica (versión standalone no expandible).
class FichaTecnicaCard extends StatelessWidget {
  final FichaCostoEntity ficha;
  const FichaTecnicaCard({super.key, required this.ficha});

  String _fmt(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 32, height: 32,
            decoration: BoxDecoration(color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.description_rounded,
                color: AppColors.primary, size: 17)),
          const SizedBox(width: 10),
          const Expanded(child: Text('Ficha técnica',
              style: TextStyle(color: AppColors.textPrimary,
                  fontSize: 14, fontWeight: FontWeight.w700))),
          _StatusBadge(completado: ficha.completado),
        ]),
        const SizedBox(height: 14),
        Text(ficha.nombre,
            style: const TextStyle(color: AppColors.textPrimary,
                fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(ficha.version,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Por unidad',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 4),
              Text('\$${_fmt(ficha.costoPorUnidad)}',
                  style: const TextStyle(color: AppColors.primary,
                      fontSize: 16, fontWeight: FontWeight.w800)),
            ])),
            Container(width: 1, height: 36,
                color: AppColors.primary.withAlpha(40),
                margin: const EdgeInsets.symmetric(horizontal: 12)),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('Total pedido',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  textAlign: TextAlign.end),
              const SizedBox(height: 4),
              Text('\$${_fmt(ficha.costoTotal)}',
                  style: const TextStyle(color: AppColors.primary,
                      fontSize: 16, fontWeight: FontWeight.w800)),
            ])),
          ]),
        ),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool completado;
  const _StatusBadge({required this.completado});
  @override
  Widget build(BuildContext context) {
    final bg = completado ? const Color(0xFFE8F9EE) : const Color(0xFFFFF3E0);
    final fg = completado ? const Color(0xFF34C759) : const Color(0xFFFF9500);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(completado ? 'Completado' : 'Pendiente',
          style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
