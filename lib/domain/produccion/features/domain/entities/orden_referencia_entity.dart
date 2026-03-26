import 'package:flutter/material.dart';

/// Representa una referencia (talla/color) dentro de una orden de producción.
class OrdenReferenciaEntity {
  final String codigo;
  final int cantidad;
  final Color color;
  final String colorName;

  const OrdenReferenciaEntity({
    required this.codigo,
    required this.cantidad,
    required this.color,
    required this.colorName,
  });
}
