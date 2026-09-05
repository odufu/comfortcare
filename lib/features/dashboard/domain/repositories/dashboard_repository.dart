import '../entities/category.dart';

abstract class DashboardRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<Map<String, dynamic>> getHubTelemetry();
}
