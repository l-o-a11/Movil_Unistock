import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../domain/entities/orden_entity.dart';

class FilterChipsRow extends StatelessWidget {
  final OrdenEstado? filtroEstado;
  final ValueChanged<OrdenEstado?> onEstadoChanged;
  const FilterChipsRow({
    super.key,
    required this.filtroEstado,
    required this.onEstadoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _Chip(label: 'Todos', active: filtroEstado == null,
              onTap: () => onEstadoChanged(null)),
          const SizedBox(width: 8),
          _Chip(label: 'En producción', active: filtroEstado == OrdenEstado.enProduccion,
              onTap: () => onEstadoChanged(OrdenEstado.enProduccion)),
          const SizedBox(width: 8),
          _Chip(label: 'Pendiente', active: filtroEstado == OrdenEstado.pendiente,
              onTap: () => onEstadoChanged(OrdenEstado.pendiente)),
          const SizedBox(width: 8),
          _Chip(label: 'Completado', active: filtroEstado == OrdenEstado.completado,
              onTap: () => onEstadoChanged(OrdenEstado.completado)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? AppColors.primary : AppColors.cardBorder),
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
      ),
    );
  }
}
