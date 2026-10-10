import '../entities/consultation_message.dart';
import '../entities/health_vitals.dart';
import '../repositories/clinical_repository.dart';

class ManageClinicalUseCase {
  final ClinicalRepository _repository;

  ManageClinicalUseCase(this._repository);

  Future<List<ConsultationMessageEntity>> getHistory({
    String? userName,
    bool forceNewSession = true,
  }) =>
      _repository.getConsultationHistory(
        userName: userName,
        forceNewSession: forceNewSession,
      );

  Future<List<ConsultationMessageEntity>> startNewSession({String? userName}) =>
      _repository.startNewSession(userName: userName);

  Future<ConsultationMessageEntity> sendMessage(String text) =>
      _repository.sendMessage(text);

  Future<HealthVitalsEntity> getLatestVitals() =>
      _repository.getLatestVitals();

  Future<void> logVitals(HealthVitalsEntity vitals) =>
      _repository.logVitals(vitals);

  Future<void> clearHistory() => _repository.clearHistory();
}
