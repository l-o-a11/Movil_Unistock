import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../domain/entities/orden_entity.dart';

/// Tarjeta de orden con expansión/colapso.
/// Al tocar el header se despliegan los detalles del cliente.
/// Al tocar la tarjeta cuando expandida navega al detalle completo.
class OrdenCard extends StatelessWidget {
  final OrdenEntity orden;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final int animIndex;

  const OrdenCard({
    super.key,
    required this.orden,
    required this.isExpanded,
    required this.onToggle,
    required this.onTap,
    this.animIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 280 + animIndex * 55),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 14), child: child),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 230),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withAlpha((0.35 * 255).round()),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(8),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header (toggle expand) ──────────────────────────────
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          'ORDEN #${orden.numero}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${orden.unidades} Unidades',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ]),
                    ),
                    _EstadoBadge(estado: orden.estado),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 230),
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.chipBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),

              // ── Detalle expandido ────────────────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                child: isExpanded ? _ExpandedContent(orden: orden, onTap: onTap) : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Contenido expandido ───────────────────────────────────────────────────────

class _ExpandedContent extends StatelessWidget {
  final OrdenEntity orden;
  final VoidCallback onTap;
  const _ExpandedContent({required this.orden, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.8)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Cliente + Entrega
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _Field(label: 'CLIENTE', value: orden.cliente ?? '—')),
            if (orden.fechaEntrega != null)
              _Field(label: 'ENTREGA', value: fmt.format(orden.fechaEntrega!)),
          ]),
          const SizedBox(height: 10),

          // Ref corte / Ref
          if (orden.refCorte != null || orden.ref != null)
            _Field(
              label: 'REF-CORTE / REF',
              value: '${orden.refCorte ?? '—'} / ${orden.ref ?? '—'}',
            ),
          const SizedBox(height: 10),

          // Fecha estado
          if (orden.fechaEstado != null)
            _Field(label: 'FECHA ESTADO', value: fmt.format(orden.fechaEstado!)),

          // Eye icon
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Icon(
              Icons.remove_red_eye_outlined,
              size: 20,
              color: AppColors.primary.withAlpha(180),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label, value;
  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5)),
      const SizedBox(height: 3),
      Text(value,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
    ]);
  }
}

// ── Badge de estado ───────────────────────────────────────────────────────────

class _EstadoBadge extends StatelessWidget {
  final OrdenEstado estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    final isEnProduccion = estado == OrdenEstado.enProduccion;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isEnProduccion ? AppColors.primaryLight : AppColors.pendingLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isEnProduccion ? 'En producción' : 'Pendiente',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isEnProduccion ? AppColors.primary : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}
