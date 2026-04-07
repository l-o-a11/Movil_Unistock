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

  @override
  Widget build(BuildContext context) {
    final statusColor = insumo.activo
        ? const Color(0xFF4CAF50)
        : const Color(0xFF9E9E9E);
    final statusText = insumo.activo ? 'ACTIVO' : 'INACTIVO';
    final stockStr = insumo.stock % 1 == 0
        ? '${insumo.stock.toInt()} ${insumo.unidad}'
        : '${insumo.stock} ${insumo.unidad}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF4DA6), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Número y estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'N°${insumo.numero}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Nombre
          const Text(
            'NOMBRE',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFFAAAAAA),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            insumo.nombre,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 10),

          // Categoría y Stock en fila
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CATEGORÍA',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFFAAAAAA),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      insumo.categoria,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STOCK',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFFAAAAAA),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stockStr,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Botón detalle
          GestureDetector(
            onTap: onDetailTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
                color: Colors.white,
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Color(0xFFAAAAAA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}