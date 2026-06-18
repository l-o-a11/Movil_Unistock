import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../features/domain/entities/orden_entity.dart';

// Modelo interno de tercero (mock mientras la API no lo devuelva embebido)
class _TerceroData {
  final String nombre, contacto, telefono, proceso, estado;
  final int unidadesAsignadas;
  final DateTime fechaEntregaTercero;
  final double costoUnitario;
  const _TerceroData({
    required this.nombre, required this.contacto, required this.telefono,
    required this.proceso, required this.unidadesAsignadas,
    required this.fechaEntregaTercero, required this.costoUnitario,
    required this.estado,
  });
}

final _mockTerceros = <String, _TerceroData>{
  '1': _TerceroData(
    nombre: 'Confecciones Moda Nova', contacto: 'Luisa Fernanda Pérez',
    telefono: '+57 314 820 4411', proceso: 'Confección y ensamble',
    unidadesAsignadas: 300, fechaEntregaTercero: DateTime(2025, 4, 10),
    costoUnitario: 12500, estado: 'en_proceso'),
  '2': _TerceroData(
    nombre: 'Bordados El Hilo de Oro', contacto: 'Ricardo Molina',
    telefono: '+57 300 551 9922', proceso: 'Bordado y decoración',
    unidadesAsignadas: 50, fechaEntregaTercero: DateTime(2025, 4, 14),
    costoUnitario: 8800, estado: 'pendiente'),
};

/// Tarjeta de producción con terceros.
/// Usa [OrdenEntity.isTerceros] (String) en lugar del enum [OrdenTipo].
class ProduccionTercerosCard extends StatefulWidget {
  final VoidCallback? onTap;
  final String? ordenId;
  final String? tipo; // "produccion" | "terceros" — String exacto del backend

  const ProduccionTercerosCard({
    super.key,
    this.onTap,
    this.ordenId,
    this.tipo,
  });

  @override
  State<ProduccionTercerosCard> createState() => _ProduccionTercerosCardState();
}

class _ProduccionTercerosCardState extends State<ProduccionTercerosCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tercero = widget.ordenId != null ? _mockTerceros[widget.ordenId] : null;
    // Comparación de String en vez de enum
    final esTerceros = widget.tipo == 'terceros';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: esTerceros && tercero != null
                ? () => setState(() => _expanded = !_expanded)
                : widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: esTerceros ? AppColors.primaryLight : AppColors.chipBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    esTerceros ? Icons.people_alt_rounded : Icons.factory_rounded,
                    color: esTerceros ? AppColors.primary : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    esTerceros ? 'Producción con Tercero' : 'Producción interna',
                    style: const TextStyle(color: AppColors.textPrimary,
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    esTerceros && tercero != null
                        ? tercero.nombre
                        : esTerceros
                            ? 'Sin tercero asignado'
                            : 'Producción en planta propia',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ])),
                if (esTerceros && tercero != null)
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary),
                  ),
              ]),
            ),
          ),
          if (esTerceros && tercero != null && _expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Divider(height: 1),
                const SizedBox(height: 12),
                _Row('Contacto',  tercero.contacto),
                _Row('Teléfono',  tercero.telefono),
                _Row('Proceso',   tercero.proceso),
                _Row('Unidades',  '${tercero.unidadesAsignadas}'),
                _Row('Costo/ud',  '\$${tercero.costoUnitario.toStringAsFixed(0)}'),
              ]),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      Text(value,  style: const TextStyle(color: AppColors.textPrimary,
          fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );
}
