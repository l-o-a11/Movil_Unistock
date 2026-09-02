import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/utils/responsive.dart';
import '../domain/compra.dart';

String _fechaFormateada(String fechaIso) {
  final fecha = DateTime.tryParse(fechaIso);
  if (fecha == null) return fechaIso;
  return DateFormat('dd/MM/yyyy').format(fecha);
}

String _moneda(double valor) {
  return '\$${valor.toStringAsFixed(2).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d)(?=[.,]))'), (m) => ',')}';
}

Future<void> showCompraDetail(BuildContext context, Compra compra) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      pageBuilder: (ctx, animation, _) =>
          _CompraDetailSheet(compra: compra, animation: animation),
    ),
  );
}

class _CompraDetailSheet extends StatelessWidget {
  final Compra compra;
  final Animation<double> animation;

  const _CompraDetailSheet({required this.compra, required this.animation});

  static const _pink = Color(0xFFFF4FA3);
  static const _text = Color(0xFF1C1C1E);
  static const _grey = Color(0xFF8E8E93);
  static const _green = Color(0xFF34C759);
  static const _red = Color(0xFFFF3B30);
  static const _tableHeaderBg = Color(0xFFF7F7FA);
  static const _tableBorder = Color(0xFFEDEDF2);

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
        ),
        ResponsiveSheet(
          maxWidth: 560,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                constraints: BoxConstraints(maxHeight: sh * 0.85),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // ── Encabezado ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Detalle de Compra',
                              style: TextStyle(
                                color: _text,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          _EstadoBadge(anulada: compra.anulada),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Color(0xFF555555),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Grilla de datos generales ────────────
                            _DetailField(
                              label: 'Número de factura',
                              value: compra.numeroFactura,
                            ),
                            const SizedBox(height: 18),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _DetailField(
                                    label: 'Fecha',
                                    value: _fechaFormateada(compra.fecha),
                                  ),
                                ),
                                Expanded(
                                  child: _DetailField(
                                    label: 'Costo total',
                                    value: _moneda(compra.total),
                                    valueColor: _pink,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _DetailField(
                                    label: 'Proveedor',
                                    value:
                                        compra.proveedorNombre ??
                                        'Sin resolver',
                                  ),
                                ),
                                Expanded(
                                  child: _DetailField(
                                    label: 'Observaciones',
                                    value: (compra.observaciones ?? '').isEmpty
                                        ? 'Sin observaciones'
                                        : compra.observaciones!,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // ── Tabla de detalle ──────────────────────
                            const Text(
                              'Detalle de compras',
                              style: TextStyle(
                                color: _text,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _DetalleTable(detalles: compra.detalles),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_pink, Color(0xFFFF6EC7)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Cerrar',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Etiqueta + valor (usado en la grilla superior) ─────────────────────
class _DetailField extends StatelessWidget {
  const _DetailField({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12.5),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF1C1C1E),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Badge de estado (Activa / Anulada) ─────────────────────────────────
class _EstadoBadge extends StatelessWidget {
  const _EstadoBadge({required this.anulada});

  final bool anulada;

  @override
  Widget build(BuildContext context) {
    final color = anulada ? const Color(0xFFFF3B30) : const Color(0xFF34C759);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            anulada ? 'Anulada' : 'Activa',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tabla de líneas de detalle ──────────────────────────────────────────
class _DetalleTable extends StatelessWidget {
  const _DetalleTable({required this.detalles});

  final List<dynamic> detalles;

  static const _tableHeaderBg = Color(0xFFF7F7FA);
  static const _tableBorder = Color(0xFFEDEDF2);
  static const _grey = Color(0xFF8E8E93);
  static const _text = Color(0xFF1C1C1E);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _tableBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Encabezado
          Container(
            color: _tableHeaderBg,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: const Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'PRODUCTO/INSUMO',
                    style: TextStyle(
                      color: _grey,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'CANTIDAD',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: _grey,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'COSTO U',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: _grey,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Estado vacío: sin esto, una compra sin detalles se veía como
          // una tabla "rota" (solo encabezado, sin filas ni aviso).
          if (detalles.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: const Text(
                'Esta compra no tiene productos registrados',
                style: TextStyle(color: _grey, fontSize: 13),
              ),
            ),
          // Filas
          for (var i = 0; i < detalles.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: _tableBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      detalles[i].nombreMostrar as String,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${detalles[i].cantidad}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: _text, fontSize: 13),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '\$${(detalles[i].precioUnitario as double).toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: _text, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
