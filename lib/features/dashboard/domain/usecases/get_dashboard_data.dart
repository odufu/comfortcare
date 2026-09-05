import '../entities/category.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardDataUseCase {
  final DashboardRepository _repository;

  GetDashboardDataUseCase(this._repository);

  Future<List<CategoryEntity>> getCategories() {
    return _repository.getCategories();
  }

  Future<Map<String, dynamic>> getHubTelemetry() {
    return _repository.getHubTelemetry();
  }
}
