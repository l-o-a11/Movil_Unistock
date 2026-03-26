/// Información de corte/producción asociada a un tercero.
class TerceroProduccionEntity {
  final String corte;
  final DateTime fecha;
  final String ordenId;

  const TerceroProduccionEntity({
    required this.corte,
    required this.fecha,
    required this.ordenId,
  });
}
