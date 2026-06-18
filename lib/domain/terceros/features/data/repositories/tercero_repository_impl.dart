import '../../domain/entities/tercero_entity.dart';
import '../../domain/entities/tercero_detail_entity.dart';
import '../../domain/repositories/tercero_repository.dart';
import '../services/terceros_api_service.dart';

/// Implementación de [TerceroRepository].
/// Delega al [TercerosApiService] que consume la API real
/// y cae en el datasource local (mock) solo si no hay conexión.
class TerceroRepositoryImpl implements TerceroRepository {
  final TercerosApiService _apiService;

  TerceroRepositoryImpl({TercerosApiService? apiService})
      : _apiService = apiService ?? TercerosApiService();

  @override
  Future<List<TerceroEntity>> getTerceros({String? query}) =>
      _apiService.getTerceros(query: query);

  @override
  Future<TerceroDetailEntity?> getTerceroDetail(String id) =>
      _apiService.getTerceroDetail(id);
}
