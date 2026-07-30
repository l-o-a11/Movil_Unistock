import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

// Mismos colores que STATUS_MAP del web
final _statusColors = <String, Color>{
  'Diseño':              const Color(0xFF7C3AED),
  'Ficha Técnica':       const Color(0xFF0369A1),
  'Corte':               const Color(0xFF1D4ED8),
  'Compras':             const Color(0xFFB45309),
  'Producción':          const Color(0xFFBE185D),
  'En producción':       const Color(0xFFBE185D),
  'Empaque':             const Color(0xFF15803D),
  'Enviado':             const Color(0xFF166534),
  'Anulada':             const Color(0xFFDC2626),
  'En corte':            const Color(0xFF1D4ED8),
  'Tráfico entre sedes': const Color(0xFF6B7280),
  'Mercadeo':            const Color(0xFF6B7280),
};

Color _colorForEstado(String estado) =>
    _statusColors[estado] ?? AppColors.primary;

/// Fila de chips de filtro con los estados REALES del backend.
/// Recibe la lista dinámica de estados disponibles.
class FilterChipsRow extends StatelessWidget {
  final String? filtroEstado;
  final List<String> estadosDisponibles;
  final ValueChanged<String?> onEstadoChanged;

  const FilterChipsRow({
    super.key,
    required this.filtroEstado,
    required this.estadosDisponibles,
    required this.onEstadoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _Chip(
            label: 'Activas',
            active: filtroEstado == null,
            color: AppColors.primary,
            onTap: () => onEstadoChanged(null),
          ),
          ...estadosDisponibles.map((estado) {
            final color = _colorForEstado(estado);
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _Chip(
                label: estado,
                active: filtroEstado == estado,
                color: color,
                onTap: () => onEstadoChanged(estado),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? color : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
