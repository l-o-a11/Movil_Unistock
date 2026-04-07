class Insumo {
  final int id;
  final int numero;
  final String nombre;
  final String categoria;
  final double stock;
  final String unidad;
  final bool activo;

  const Insumo({
    required this.id,
    required this.numero,
    required this.nombre,
    required this.categoria,
    required this.stock,
    required this.unidad,
    required this.activo,
  });

  factory Insumo.fromJson(Map<String, dynamic> json) => Insumo(
        id:        json['id'],
        numero:    json['numero'],
        nombre:    json['nombre'],
        categoria: json['categoria'],
        stock:     (json['stock'] as num).toDouble(),
        unidad:    json['unidad'],
        activo:    json['activo'],
      );
}