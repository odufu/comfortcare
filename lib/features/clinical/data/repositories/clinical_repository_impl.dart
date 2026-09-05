import '../../domain/entities/consultation_message.dart';
import '../../domain/entities/health_vitals.dart';
import '../../domain/repositories/clinical_repository.dart';
import '../datasources/clinical_remote_datasource.dart';

class ClinicalRepositoryImpl implements ClinicalRepository {
  final ClinicalRemoteDataSource _remoteDataSource;

  ClinicalRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ConsultationMessageEntity>> getConsultationHistory() {
    return _remoteDataSource.getConsultationHistory();
  }

  @override
  Future<ConsultationMessageEntity> sendMessage(String text) {
    return _remoteDataSource.sendMessage(text);
  }

  @override
  Future<HealthVitalsEntity> getLatestVitals() {
    return _remoteDataSource.getLatestVitals();
  }

  @override
  Future<void> logVitals(HealthVitalsEntity vitals) {
    return _remoteDataSource.logVitals(vitals);
  }
}
