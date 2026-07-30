import 'package:flutter/material.dart';
import 'compra.dart';

class CompraCard extends StatelessWidget {
  final Compra compra;
  final VoidCallback onDetailTap;

  const CompraCard({
    super.key,
    required this.compra,
    required this.onDetailTap,
  });

  static const _pink = Color(0xFFFF4FA3);
  static const _text = Color(0xFF1C1C1E);
  static const _grey = Color(0xFF8E8E93);
  static const _green = Color(0xFF34C759);
  static const _red = Color(0xFFFF3B30);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDetailTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFD6E7)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF4DA6).withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _pink.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.receipt_long, color: _pink, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Factura: ${compra.numeroFactura}',
                    style: const TextStyle(
                      color: _text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    compra.proveedorNombre ?? 'Proveedor sin nombre',
                    style: const TextStyle(color: _grey, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Chip(label: compra.fecha, color: _pink),
                      const SizedBox(width: 6),
                      _Chip(
                        label: '\$${compra.total.toStringAsFixed(2)}',
                        color: _pink,
                      ),
                      const SizedBox(width: 6),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: compra.anulada ? _red : _green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            compra.anulada ? 'Anulada' : 'Activo',
                            style: TextStyle(
                              color: compra.anulada ? _red : _green,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFCCCCCC),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
