import 'package:flutter/material.dart';
import 'insumo.dart';

class InsumoCard extends StatelessWidget {
  final Insumo insumo;
  final VoidCallback onDetailTap;

  const InsumoCard({
    super.key,
    required this.insumo,
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
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Ícono / imagen
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _pink.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: insumo.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        insumo.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _defaultIcon(),
                      ),
                    )
                  : _defaultIcon(),
            ),
            const SizedBox(width: 12),
            // Nombre + categoría
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insumo.nombre,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    insumo.categoria,
                    style: const TextStyle(color: _grey, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Chip(
                        label: '${insumo.stock} ${insumo.medida}',
                        color: _pink,
                      ),
                      const SizedBox(width: 6),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: insumo.isActivo ? _green : _red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            insumo.isActivo ? 'Activo' : 'Inactivo',
                            style: TextStyle(
                              color: insumo.isActivo ? _green : _red,
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

  Widget _defaultIcon() =>
      const Icon(Icons.inventory_2_outlined, color: _pink, size: 26);
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
