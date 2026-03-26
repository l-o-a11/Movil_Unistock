import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../domain/entities/orden_entity.dart';

class FilterChipsRow extends StatelessWidget {
  final OrdenEstado? filtroEstado;
  final VoidCallback onEstadoTap;
  final VoidCallback onTercerosTap;
  final VoidCallback onCalendarioTap;

  const FilterChipsRow({
    super.key,
    required this.filtroEstado,
    required this.onEstadoTap,
    required this.onTercerosTap,
    required this.onCalendarioTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChip(
          label:
              'Estado:${filtroEstado == null ? 'Todos' : _estadoLabel(filtroEstado!)}',
          onTap: onEstadoTap,
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Terceros:Todos',
          onTap: onTercerosTap,
        ),
        const SizedBox(width: 8),
        _IconChip(
          icon: Icons.calendar_month_outlined,
          onTap: onCalendarioTap,
        ),
      ],
    );
  }

  String _estadoLabel(OrdenEstado estado) {
    switch (estado) {
      case OrdenEstado.enProduccion:
        return 'En producción';
      case OrdenEstado.pendiente:
        return 'Pendiente';
      case OrdenEstado.completado:
        return 'Completado';
      case OrdenEstado.cancelado:
        return 'Cancelado';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.chipBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.chipText,
          ),
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconChip({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: AppColors.chipBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.chipText),
      ),
    );
  }
}
