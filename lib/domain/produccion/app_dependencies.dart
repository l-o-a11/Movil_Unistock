import 'features/data/datasources/orden_local_datasource.dart';
import 'features/data/repositories/orden_repository_impl.dart';
import 'features/domain/usecases/get_ordenes_usecase.dart';
import 'features/domain/usecases/get_orden_detail_usecase.dart';
import 'features/presentation/providers/produccion_provider.dart';
import 'features/presentation/providers/orden_detail_provider.dart';
// Terceros: delega a su propio módulo
import '../terceros/terceros_dependencies.dart';
export '../terceros/terceros_dependencies.dart';

/// Inyección de dependencias del módulo Producción.
/// Las dependencias de Terceros se delegan a [TercerosDependencies].
class AppDependencies {
  AppDependencies._();

  // ── Producción ─────────────────────────────────────────────────────────────

  static OrdenRepositoryImpl _buildOrdenRepository() =>
      OrdenRepositoryImpl(localDataSource: OrdenLocalDataSourceImpl());

  static ProduccionProvider createProduccionProvider() =>
      ProduccionProvider(getOrdenesUseCase: GetOrdenesUseCase(_buildOrdenRepository()));

  static OrdenDetailProvider createOrdenDetailProvider() =>
      OrdenDetailProvider(getOrdenDetailUseCase: GetOrdenDetailUseCase(_buildOrdenRepository()));

  // ── Terceros (re-expuesto para conveniencia) ───────────────────────────────

  static createTercerosProvider() => TercerosDependencies.createTercerosProvider();
  static createTerceroDetailProvider() => TercerosDependencies.createTerceroDetailProvider();
}
