import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../features/domain/entities/orden_entity.dart';

// ── Modelo interno de tercero ────────────────────────────────────────────────
class _TerceroData {
  final String nombre;
  final String contacto;
  final String telefono;
  final String proceso;
  final int unidadesAsignadas;
  final DateTime fechaEntregaTercero;
  final double costoUnitario;
  final String estado; // 'en_proceso', 'entregado', 'pendiente'

  const _TerceroData({
    required this.nombre,
    required this.contacto,
    required this.telefono,
    required this.proceso,
    required this.unidadesAsignadas,
    required this.fechaEntregaTercero,
    required this.costoUnitario,
    required this.estado,
  });
}

// Mock de terceros por orden
final _mockTerceros = <String, _TerceroData>{
  '1': _TerceroData(
    nombre: 'Confecciones Moda Nova',
    contacto: 'Luisa Fernanda Pérez',
    telefono: '+57 314 820 4411',
    proceso: 'Confección y ensamble',
    unidadesAsignadas: 300,
    fechaEntregaTercero: DateTime(2025, 4, 10),
    costoUnitario: 12500,
    estado: 'en_proceso',
  ),
  '2': _TerceroData(
    nombre: 'Bordados El Hilo de Oro',
    contacto: 'Ricardo Molina',
    telefono: '+57 300 551 9922',
    proceso: 'Bordado y decoración',
    unidadesAsignadas: 50,
    fechaEntregaTercero: DateTime(2025, 4, 14),
    costoUnitario: 8800,
    estado: 'pendiente',
  ),
};

/// Tarjeta de producción con terceros.
/// Si la orden tiene tipo [OrdenTipo.terceros] muestra datos reales del tercero.
class ProduccionTercerosCard extends StatefulWidget {
  final VoidCallback? onTap;
  final String? ordenId;
  final OrdenTipo? tipo;

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
    final esTerceros = widget.tipo == OrdenTipo.terceros;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: esTerceros && tercero != null
                ? () => setState(() => _expanded = !_expanded)
                : widget.onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.precision_manufacturing_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Producción con terceros',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          esTerceros && tercero != null
                              ? tercero.nombre
                              : esTerceros
                                  ? 'Sin tercero asignado'
                                  : 'Producción interna',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (esTerceros && tercero != null) ...[
                    _EstadoBadge(estado: tercero.estado),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                            color: AppColors.chipBackground,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 20, color: AppColors.textSecondary),
                      ),
                    ),
                  ] else
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.iconInactive,
                      size: 14,
                    ),
                ],
              ),
            ),
          ),
          if (esTerceros && tercero != null)
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              child: _expanded ? _TerceroDetalle(tercero: tercero) : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

class _TerceroDetalle extends StatelessWidget {
  final _TerceroData tercero;
  const _TerceroDetalle({required this.tercero});

  String _fmtNum(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _fmtDate(DateTime d) {
    const meses = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${d.day} ${meses[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider))),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Costo por unidad',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text('\$${_fmtNum(tercero.costoUnitario)}',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                Container(
                    width: 1,
                    height: 40,
                    color: AppColors.primary.withAlpha(40),
                    margin: const EdgeInsets.symmetric(horizontal: 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total a pagar',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
                          textAlign: TextAlign.end),
                      const SizedBox(height: 4),
                      Text(
                          '\$${_fmtNum(tercero.costoUnitario * tercero.unidadesAsignadas)}',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(label: 'Empresa', value: tercero.nombre),
          _InfoRow(label: 'Contacto', value: tercero.contacto),
          _InfoRow(label: 'Teléfono', value: tercero.telefono),
          _InfoRow(label: 'Proceso', value: tercero.proceso),
          _InfoRow(label: 'Unidades', value: '${tercero.unidadesAsignadas} uds'),
          _InfoRow(label: 'Entrega tercero', value: _fmtDate(tercero.fechaEntregaTercero)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.call_rounded, size: 16),
              label: const Text('Contactar tercero'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    switch (estado) {
      case 'en_proceso':
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1E88E5);
        label = 'En proceso';
        break;
      case 'entregado':
        bg = const Color(0xFFE8F9EE);
        fg = const Color(0xFF34C759);
        label = 'Entregado';
        break;
      default:
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFFF9500);
        label = 'Pendiente';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: fg, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
