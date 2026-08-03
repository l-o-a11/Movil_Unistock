import 'features/data/repositories/orden_repository_impl.dart';
import 'features/data/services/produccion_api_service.dart';
import 'features/domain/usecases/get_ordenes_usecase.dart';
import 'features/domain/usecases/get_orden_detail_usecase.dart';
import 'features/domain/usecases/avanzar_estado_usecase.dart';
import 'features/domain/usecases/confirmar_etapa_usecase.dart';
import 'features/presentation/providers/produccion_provider.dart';
import 'features/presentation/providers/orden_detail_provider.dart';
import '../terceros/terceros_dependencies.dart';
export '../terceros/terceros_dependencies.dart';

/// Inyección de dependencias del módulo Producción.
///
/// Cadena real:
///   Provider → UseCase → Repository → ApiService → API REST
///   (fallback automático al mock si no hay conexión)
class AppDependencies {
  AppDependencies._();

  // ── Producción ─────────────────────────────────────────────────────────────

  static OrdenRepositoryImpl _buildOrdenRepository() =>
      OrdenRepositoryImpl(localDataSource: ProduccionApiService());

  static ProduccionProvider createProduccionProvider() => ProduccionProvider(
    getOrdenesUseCase: GetOrdenesUseCase(_buildOrdenRepository()),
  );

  static OrdenDetailProvider createOrdenDetailProvider() {
    final repository = _buildOrdenRepository();
    return OrdenDetailProvider(
      getOrdenDetailUseCase: GetOrdenDetailUseCase(repository),
      avanzarEstadoUseCase: AvanzarEstadoUseCase(repository),
      confirmarEtapaUseCase: ConfirmarEtapaUseCase(repository),
    );
  }

  // ── Terceros (re-expuesto para conveniencia) ───────────────────────────────

  static createTercerosProvider() =>
      TercerosDependencies.createTercerosProvider();

  static createTerceroDetailProvider() =>
      TercerosDependencies.createTerceroDetailProvider();
}
