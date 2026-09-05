import '../../domain/entities/category.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<CategoryEntity>> getCategories() async {
    return _remoteDataSource.getCategories();
  }

  @override
  Future<Map<String, dynamic>> getHubTelemetry() async {
    return _remoteDataSource.getHubTelemetry();
  }
}
