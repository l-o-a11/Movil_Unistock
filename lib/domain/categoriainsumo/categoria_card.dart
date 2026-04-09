import 'package:flutter/material.dart';
import 'categoria.dart';
import 'categoria_detail.dart';

class CategoriaCard extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onDetailTap;

  const CategoriaCard({
    super.key,
    required this.categoria,
    required this.onDetailTap,
  });

  static const _pink = Color(0xFFE91E8C);
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
          border: Border.all(color: const Color(0xFFEEEEEE)),
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
              child: const Icon(Icons.label_outline, color: _pink, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoria.nombre,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: categoria.isActivo ? _green : _red,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            categoria.isActivo ? 'ACTIVO' : 'INACTIVO',
                            style: TextStyle(
                              color: categoria.isActivo ? _green : _red,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
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
