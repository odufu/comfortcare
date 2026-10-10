import '../../domain/entities/consultation_message.dart';
import '../../domain/entities/health_vitals.dart';
import '../../domain/repositories/clinical_repository.dart';
import '../datasources/clinical_remote_datasource.dart';

class ClinicalRepositoryImpl implements ClinicalRepository {
  final ClinicalRemoteDataSource _remoteDataSource;

  ClinicalRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ConsultationMessageEntity>> getConsultationHistory({
    String? userName,
    bool forceNewSession = true,
  }) {
    return _remoteDataSource.getConsultationHistory(
      userName: userName,
      forceNewSession: forceNewSession,
    );
  }

  @override
  Future<List<ConsultationMessageEntity>> startNewSession({String? userName}) {
    return _remoteDataSource.startNewSession(userName: userName);
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

  @override
  Future<void> clearHistory() {
    return _remoteDataSource.clearHistory();
  }
}
