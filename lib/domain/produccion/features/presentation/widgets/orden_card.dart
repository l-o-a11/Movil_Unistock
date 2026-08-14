import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../domain/entities/orden_entity.dart';

// Colores por estado exacto del backend (igual que STATUS_MAP del web)
final _statusColors = <String, Color>{
  'Diseño': const Color(0xFF7C3AED),
  'Ficha Técnica': const Color(0xFF0369A1),
  'Corte': const Color(0xFF1D4ED8),
  'En corte': const Color(0xFF1D4ED8),
  'Compras': const Color(0xFFB45309),
  'Producción': const Color(0xFFBE185D),
  'En producción': const Color(0xFFBE185D),
  'Empaque': const Color(0xFF15803D),
  'Enviado': const Color(0xFF166534),
  'Anulada': const Color(0xFFDC2626),
  'Tráfico entre sedes': const Color(0xFF6B7280),
  'Mercadeo': const Color(0xFF6B7280),
};

Color _colorForEstado(String estado) =>
    _statusColors[estado] ?? AppColors.primary;

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
    final estadoColor = _colorForEstado(orden.estado);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 280 + animIndex * 55),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 14),
          child: child,
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 230),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.cardBorder,
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: estadoColor.withAlpha(8),
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
              // ── Header ──────────────────────────────────────────────
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                              orden.unidades > 0
                                  ? '${orden.unidades} unidades'
                                  : orden.cliente ?? 'Sin cliente',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _EstadoBadge(estado: orden.estado),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 230),
                        child: Container(
                          width: 28,
                          height: 28,
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
                    ],
                  ),
                ),
              ),

              // ── Detalle expandido ────────────────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                child: isExpanded
                    ? _ExpandedContent(orden: orden, onTap: onTap)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Contenido expandido ────────────────────────────────────────────────────────
class _ExpandedContent extends StatelessWidget {
  final OrdenEntity orden;
  final VoidCallback onTap;
  const _ExpandedContent({required this.orden, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    // Referencia: producto > ref > refCorte > —   (igual que el web)
    final refDisplay = (orden.producto?.isNotEmpty == true)
        ? orden.producto!
        : (orden.ref?.isNotEmpty == true)
        ? orden.ref!
        : orden.refCorte ?? '—';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.8)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Field(label: 'CLIENTE', value: orden.cliente ?? '—'),
                ),
                if (orden.fechaEntrega != null)
                  _Field(
                    label: 'ENTREGA',
                    value: fmt.format(orden.fechaEntrega!),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _Field(label: 'PRODUCTO / REF', value: refDisplay),
            if (orden.color?.isNotEmpty == true) ...[
              const SizedBox(height: 10),
              _Field(label: 'COLOR', value: orden.color!),
            ],
            if (orden.fechaEstado != null) ...[
              const SizedBox(height: 10),
              _Field(
                label: 'ACTUALIZACIÓN',
                value: fmt.format(orden.fechaEstado!),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.remove_red_eye_outlined,
                  size: 20,
                  color: AppColors.primary.withAlpha(180),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label, value;
  const _Field({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    ],
  );
}

// ── Badge de estado ────────────────────────────────────────────────────────────
class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});
  @override
  Widget build(BuildContext context) {
    final color = _colorForEstado(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        estado,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
