/// Una entrada en el historial de estados de una orden.
class HistorialEntryEntity {
  final String etapa;
  final DateTime fecha;
  final String responsable;

  const HistorialEntryEntity({
    required this.etapa,
    required this.fecha,
    required this.responsable,
  });
}
