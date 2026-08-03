import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../domain/entities/orden_detail_entity.dart';

/// Tarjeta de acción de avance de la orden.
///
/// Espejo del bloque "Flujo de Proceso" en ProductionDetailsPage.jsx:
/// - Gerente: control total — botón "Siguiente →" activo que avanza la
///   orden al siguiente estado (previa confirmación).
/// - Empleado: vista de solo lectura + único botón habilitado, que aquí
///   funciona como su "avanzar" — confirma que terminó su etapa
///   ("Confirmar finalización ✓" / "✓ Confirmado" una vez confirmada).
///   El Gerente es quien decide después cuándo avanzar la orden.
/// - Administrador / cualquier otro rol: observador — botón deshabilitado.
class FlujoProcesoCard extends StatelessWidget {
  final OrdenDetailEntity detail;
  final bool isGerente;
  final bool isEmpleado;
  final bool isActionLoading;
  final String? actionError;
  final Future<void> Function(String nuevoEstado) onAvanzar;
  final Future<void> Function() onConfirmarEtapa;

  const FlujoProcesoCard({
    super.key,
    required this.detail,
    required this.isGerente,
    required this.isEmpleado,
    required this.isActionLoading,
    required this.onAvanzar,
    required this.onConfirmarEtapa,
    this.actionError,
  });

  @override
  Widget build(BuildContext context) {
    // Igual que en el web: nada que mostrar si la orden fue anulada o si
    // ya llegó al último estado del flujo.
    if (detail.isAnulada) return const SizedBox.shrink();
    final nextEstado = detail.nextEstado;
    if (nextEstado == null) return const SizedBox.shrink();

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
          _buildAction(context, nextEstado),
        ],
      ),
    );
  }

  Widget _buildAction(BuildContext context, String nextEstado) {
    if (isActionLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary),
      );
    }

    if (isGerente) {
      return _PrimaryButton(
        label: 'Siguiente →',
        onPressed: () => _confirmarYAvanzar(context, nextEstado),
      );
    }

    if (isEmpleado) {
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

    // Administrador u otro rol: observador.
    return const _StaticPill(
      label: 'Siguiente →',
      background: AppColors.chipBackground,
      foreground: AppColors.textHint,
    );
  }

  Future<void> _confirmarYAvanzar(BuildContext context, String nextEstado) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Avanzar orden'),
        content: Text('¿Confirmas el avance al estado "$nextEstado"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await onAvanzar(nextEstado);
    }
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
        style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
