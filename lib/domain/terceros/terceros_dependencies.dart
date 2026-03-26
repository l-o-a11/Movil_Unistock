import 'features/data/datasources/tercero_local_datasource.dart';
import 'features/data/repositories/tercero_repository_impl.dart';
import 'features/domain/usecases/get_terceros_usecase.dart';
import 'features/domain/usecases/get_tercero_detail_usecase.dart';
import 'features/presentation/providers/terceros_provider.dart';
import 'features/presentation/providers/tercero_detail_provider.dart';

/// Inyección de dependencias del módulo Terceros.
class TercerosDependencies {
  TercerosDependencies._();

  static TerceroRepositoryImpl _buildRepository() =>
      TerceroRepositoryImpl(localDataSource: TerceroLocalDataSourceImpl());

  static TercerosProvider createTercerosProvider() =>
      TercerosProvider(getTercerosUseCase: GetTercerosUseCase(_buildRepository()));

  static TerceroDetailProvider createTerceroDetailProvider() =>
      TerceroDetailProvider(
          getTerceroDetailUseCase: GetTerceroDetailUseCase(_buildRepository()));
}
