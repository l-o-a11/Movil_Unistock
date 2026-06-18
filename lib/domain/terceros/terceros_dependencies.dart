import 'features/data/repositories/tercero_repository_impl.dart';
import 'features/data/services/terceros_api_service.dart';
import 'features/domain/usecases/get_terceros_usecase.dart';
import 'features/domain/usecases/get_tercero_detail_usecase.dart';
import 'features/presentation/providers/terceros_provider.dart';
import 'features/presentation/providers/tercero_detail_provider.dart';

/// Inyección de dependencias del módulo Terceros.
///
/// Cadena real:
///   Provider → UseCase → Repository → ApiService → API REST
///   (fallback automático al mock si no hay conexión)
class TercerosDependencies {
  TercerosDependencies._();

  static TerceroRepositoryImpl _buildRepository() =>
      TerceroRepositoryImpl(apiService: TercerosApiService());

  static TercerosProvider createTercerosProvider() => TercerosProvider(
        getTercerosUseCase: GetTercerosUseCase(_buildRepository()),
      );

  static TerceroDetailProvider createTerceroDetailProvider() =>
      TerceroDetailProvider(
        getTerceroDetailUseCase: GetTerceroDetailUseCase(_buildRepository()),
      );
}
