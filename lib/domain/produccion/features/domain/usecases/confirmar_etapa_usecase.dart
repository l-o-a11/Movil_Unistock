import '../entities/orden_detail_entity.dart';
import '../repositories/orden_repository.dart';

/// Caso de uso: el empleado asignado confirma que terminó la etapa actual
/// de la orden. No cambia el estado — el Gerente decide cuándo avanzar.
class ConfirmarEtapaUseCase {
  final OrdenRepository repository;

  const ConfirmarEtapaUseCase(this.repository);

  Future<OrdenDetailEntity?> call(String id) {
    return repository.confirmarEtapa(id);
  }
}
