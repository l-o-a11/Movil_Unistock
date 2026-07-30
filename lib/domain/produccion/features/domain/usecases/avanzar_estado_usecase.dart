import '../entities/orden_detail_entity.dart';
import '../repositories/orden_repository.dart';

/// Caso de uso: avanza una orden de producción al siguiente estado.
/// Solo debe invocarse desde la UI cuando el rol del usuario es Gerente
/// (ver `useSedeScope` / `puedeAvanzar` en ProductionDetailsPage.jsx).
class AvanzarEstadoUseCase {
  final OrdenRepository repository;

  const AvanzarEstadoUseCase(this.repository);

  Future<OrdenDetailEntity?> call(String id, String nuevoEstado) {
    return repository.avanzarEstado(id, nuevoEstado);
  }
}
