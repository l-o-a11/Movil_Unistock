import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../domain/entities/orden_detail_entity.dart';

/// Tarjeta de acción de confirmación de etapa.
///
/// Solo el empleado puede interactuar: confirma que terminó su etapa actual
/// ("Confirmar finalización ✓" / "✓ Confirmado" una vez confirmada).
/// Gerente/Administrador/otros roles: la tarjeta no se muestra (el avance
/// de estado se gestiona desde el web).
class FlujoProcesoCard extends StatelessWidget {
  final OrdenDetailEntity detail;
  final bool isEmpleado;
  final bool isActionLoading;
  final Future<void> Function() onConfirmarEtapa;

  const FlujoProcesoCard({
    super.key,
    required this.detail,
    this.isEmpleado = false,
    this.isActionLoading = false,
    required this.onConfirmarEtapa,
  });

  @override
  Widget build(BuildContext context) {
    // Solo mostrar para empleados con orden en estado activo
    if (!isEmpleado) return const SizedBox.shrink();
    if (detail.isAnulada) return const SizedBox.shrink();
    if (detail.nextEstado == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Flujo de proceso',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          _buildAction(),
        ],
      ),
    );
  }

  Widget _buildAction() {
    if (isActionLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: AppColors.primary,
        ),
      );
    }

    if (detail.etapaConfirmada) {
      return const _StaticPill(
        label: '✓ Confirmado',
        background: Color(0xFFDCFCE7),
        foreground: Color(0xFF16A34A),
      );
    }

    return _PrimaryButton(
      label: 'Confirmar finalización ✓',
      color: const Color(0xFF16A34A),
      onPressed: () => onConfirmarEtapa(),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}

class _StaticPill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  const _StaticPill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
