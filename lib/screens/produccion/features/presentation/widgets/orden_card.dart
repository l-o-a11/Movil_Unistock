import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../domain/entities/orden_entity.dart';
import '../pages/orden_detail_page.dart';
import '../providers/orden_detail_provider.dart';
import '../../../app_dependencies.dart';

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

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => ChangeNotifierProvider<OrdenDetailProvider>(
          create: (_) => AppDependencies.createOrdenDetailProvider(),
          child: OrdenDetailPage(orden: orden),
        ),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 360),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetail(context),
      child: AnimatedContainer(
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
            children: [
              _buildHeader(context),
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: isExpanded
                    ? _buildExpandedContent()
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                child: _InfoField(label: 'CLIENTE', value: orden.cliente ?? '—'),
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.remove_red_eye_outlined,
                size: 18,
                color: AppColors.primary.withAlpha(153),
              ),
              const SizedBox(width: 4),
              Text(
                'Ver detalle',
                style: TextStyle(
                  color: AppColors.primary.withAlpha(200),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
    final Color bgColor =
        isEnProduccion ? AppColors.primaryLight : AppColors.pendingLight;
    final Color textColor =
        isEnProduccion ? AppColors.primary : const Color(0xFF6B7280);
    final String label =
        isEnProduccion ? 'En producción' : 'Pendiente';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
