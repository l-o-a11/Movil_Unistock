import 'features/data/datasources/orden_local_datasource.dart';
import 'features/data/repositories/orden_repository_impl.dart';
import 'features/domain/usecases/get_ordenes_usecase.dart';
import 'features/presentation/providers/produccion_provider.dart';

/// Inyección de dependencias manual (sin paquetes externos).
class AppDependencies {
  AppDependencies._();

  static ProduccionProvider createProduccionProvider() {
    final dataSource = OrdenLocalDataSourceImpl();
    final repository = OrdenRepositoryImpl(localDataSource: dataSource);
    final useCase = GetOrdenesUseCase(repository);
    return ProduccionProvider(getOrdenesUseCase: useCase);
  }
}
