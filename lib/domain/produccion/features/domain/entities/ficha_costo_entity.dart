/// Información de la ficha técnica y costos de una orden.
class FichaCostoEntity {
  final String nombre;
  final String version;
  final double costoPorUnidad;
  final double costoTotal;
  final bool completado;

  const FichaCostoEntity({
    required this.nombre,
    required this.version,
    required this.costoPorUnidad,
    required this.costoTotal,
    this.completado = true,
  });
}
