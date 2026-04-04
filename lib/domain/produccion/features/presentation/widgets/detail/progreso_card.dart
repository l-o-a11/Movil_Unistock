import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../domain/entities/orden_detail_entity.dart';

class ProgresoCard extends StatelessWidget {
  final OrdenDetailEntity detail;
  const ProgresoCard({super.key, required this.detail});

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    const m = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${d.day} ${m[d.month]} ${d.year}';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('O.#${detail.numero}',
                    style: const TextStyle(color: AppColors.textPrimary,
                        fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(detail.cliente ?? '—',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ]),
              _EstadoChip(estado: detail.estadoLabel,
                  isActive: detail.isEnProduccion),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            _InfoItem(icon: Icons.straighten_rounded,
                label: 'Ref.', value: detail.ref ?? '—'),
            const SizedBox(width: 20),
            _InfoItem(icon: Icons.content_cut_rounded,
                label: 'Ref. corte', value: detail.refCorte ?? '—'),
            const SizedBox(width: 20),
            _InfoItem(icon: Icons.inventory_2_rounded,
                label: 'Unidades', value: '${detail.unidades}'),
          ]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progreso general',
                  style: TextStyle(color: AppColors.textSecondary,
                      fontSize: 12, fontWeight: FontWeight.w500)),
              Text('${detail.progresoPercent}%',
                  style: const TextStyle(color: AppColors.primary,
                      fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: detail.progreso,
              backgroundColor: AppColors.chipBackground,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 14),
          Row(children: [
            _DateItem(label: 'Fecha estado', value: _fmtDate(detail.fechaEstado)),
            const SizedBox(width: 20),
            _DateItem(label: 'Fecha entrega', value: _fmtDate(detail.fechaEntrega)),
          ]),
        ],
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  final String estado;
  final bool isActive;
  const _EstadoChip({required this.estado, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final bg = isActive ? AppColors.primaryLight : AppColors.chipBackground;
    final fg = isActive ? AppColors.primary : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(estado,
          style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 11, color: AppColors.textHint),
        const SizedBox(width: 3),
        Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
      ]),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(color: AppColors.textPrimary,
          fontSize: 13, fontWeight: FontWeight.w600)),
    ]);
  }
}

class _DateItem extends StatelessWidget {
  final String label;
  final String value;
  const _DateItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(color: AppColors.textPrimary,
          fontSize: 12, fontWeight: FontWeight.w600)),
    ]);
  }
}
