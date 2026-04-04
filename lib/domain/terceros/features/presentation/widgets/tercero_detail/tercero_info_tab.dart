import 'package:flutter/material.dart';

import '../../../../../produccion/core/constants/app_colors.dart';
import '../../../domain/entities/tercero_detail_entity.dart';

/// Tab "Información general" del detalle de un tercero.
class TerceroInfoTab extends StatelessWidget {
  final TerceroDetailEntity detail;
  const TerceroInfoTab({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        _InfoCard(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _InfoField(label: 'NIT', value: detail.nit)),
            Expanded(child: _InfoField(label: 'DIRECCIÓN', value: detail.direccion)),
          ]),
          const SizedBox(height: 16),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _InfoField(label: 'TELÉFONO', value: detail.telefono)),
            Expanded(child: _EstadoField(isActivo: detail.isActivo)),
          ]),
        ]),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label, value;
  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.7)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
    ]);
  }
}

class _EstadoField extends StatelessWidget {
  final bool isActivo;
  const _EstadoField({required this.isActivo});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('ESTADO', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.7)),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isActivo ? const Color(0xFFE8F9EE) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isActivo ? 'Activo' : 'Inactivo',
          style: TextStyle(color: isActivo ? const Color(0xFF34C759) : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    ]);
  }
}
