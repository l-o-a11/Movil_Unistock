import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../domain/entities/orden_entity.dart';

class OrdenCard extends StatelessWidget {
  final OrdenEntity orden;
  final bool isExpanded;
  final VoidCallback onToggle;

  const OrdenCard({
    super.key,
    required this.orden,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isExpanded ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withAlpha((0.4 * 255).round()),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha((0.08 * 255).round()),
            blurRadius: isExpanded ? 12 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_buildHeader(), if (isExpanded) _buildExpandedContent()],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  const SizedBox(height: 6),
                  Text(
                    '${orden.unidades} Unidades',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _EstadoBadge(estado: orden.estado),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
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
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    final fmt = DateFormat('dd/MM/yyyy');

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoField(
                  label: 'CLIENTE',
                  value: orden.cliente ?? '—',
                ),
              ),
              if (orden.fechaEntrega != null)
                _InfoField(
                  label: 'ENTREGA',
                  value: fmt.format(orden.fechaEntrega!),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (orden.refCorte != null || orden.ref != null)
            _InfoField(
              label: 'REF_CORTE / REF',
              value: '${orden.refCorte ?? '—'} / ${orden.ref ?? '—'}',
            ),
          const SizedBox(height: 12),
          if (orden.fechaEstado != null)
            _InfoField(
              label: 'FECHA ESTADO',
              value: fmt.format(orden.fechaEstado!),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.remove_red_eye_outlined,
              size: 20,
              color: AppColors.primary.withAlpha((0.6 * 255).round()),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;

  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
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
}

class _EstadoBadge extends StatelessWidget {
  final OrdenEstado estado;

  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    final bool isEnProduccion = estado == OrdenEstado.enProduccion;
    final Color bgColor = isEnProduccion
        ? AppColors.primaryLight
        : AppColors.pendingLight;
    final Color textColor = isEnProduccion
        ? AppColors.primary
        : const Color(0xFFD48000);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado == OrdenEstado.enProduccion ? 'En producción' : 'Pendiente',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
