import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../domain/entities/orden_detail_entity.dart';

/// Tarjeta de resumen principal de la orden.
/// Muestra: número, cliente, estado, ref, unidades, sede/tercero,
/// progreso real calculado desde el flujo de estados, y fechas clave.
class ProgresoCard extends StatelessWidget {
  final OrdenDetailEntity detail;
  const ProgresoCard({super.key, required this.detail});

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    const m = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${d.day} ${m[d.month]} ${d.year}';
  }

  bool get _vencida {
    final fe = detail.fechaEntrega;
    if (fe == null) return false;
    return DateTime.now().isAfter(fe);
  }

  @override
  Widget build(BuildContext context) {
    // Progreso calculado del flujo de estados (no el campo raw del backend)
    final pct = detail.progresoPercent;
    final prog = detail.progreso;

    // Sede o tercero principal. No mostrar 'planta propia'.
    final isFinalizado = detail.estadoIndex == kProductionStates.length - 1;
    final tieneTerceros = detail.isTerceros && detail.terceros.isNotEmpty;
    final asignacion = detail.sede != null && isFinalizado
        ? 'Sede: ${detail.sede!}'
        : tieneTerceros && detail.isEnProduccion
        ? 'En terceros: ${detail.terceroNombre ?? 'Sin asignar'}'
        : detail.sede != null
        ? 'Sede: ${detail.sede!}'
        : null;
    final asignacionIcon = detail.sede != null
        ? Icons.location_on_rounded
        : tieneTerceros && detail.isEnProduccion
        ? Icons.people_alt_rounded
        : null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cabecera: número + estado ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'O.#${detail.numero}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail.cliente ?? '—',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              _EstadoChip(
                estado: detail.estado,
                isActive: detail.isEnProduccion,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Info: ref, ref. corte, unidades ───────────────────────────────
          Wrap(
            spacing: 18,
            runSpacing: 10,
            children: [
              _InfoItem(
                icon: Icons.straighten_rounded,
                label: 'Ref.',
                value: detail.ref ?? '—',
              ),
              _InfoItem(
                icon: Icons.content_cut_rounded,
                label: 'Ref. corte',
                value: detail.refCorte ?? '—',
              ),
              _InfoItem(
                icon: Icons.inventory_2_rounded,
                label: 'Unidades',
                value: '${detail.unidades}',
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Sede / tercero ─────────────────────────────────────────────────
          if (asignacion != null && asignacionIcon != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.chipBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(asignacionIcon, size: 15, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      asignacion,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),

          // ── Progreso real basado en el flujo ───────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso general',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$pct%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: prog,
              backgroundColor: AppColors.chipBackground,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 14),

          // ── Fechas ─────────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _DateItem(
                  label: 'Último estado',
                  value: _fmtDate(detail.fechaEstado),
                  icon: Icons.update_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateItem(
                  label: 'Fecha entrega',
                  value: _fmtDate(detail.fechaEntrega),
                  icon: Icons.event_rounded,
                  // Rojo si está vencida, normal si no
                  color: _vencida
                      ? const Color(0xFFEF4444)
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
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
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 11, color: AppColors.textHint),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(color: AppColors.textHint, fontSize: 10),
          ),
        ],
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _DateItem extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _DateItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.chipBackground,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: color == AppColors.textSecondary
                      ? AppColors.textPrimary
                      : color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
