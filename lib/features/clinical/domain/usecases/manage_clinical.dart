import '../entities/consultation_message.dart';
import '../entities/health_vitals.dart';
import '../repositories/clinical_repository.dart';

class ManageClinicalUseCase {
  final ClinicalRepository _repository;

  ManageClinicalUseCase(this._repository);

  Future<List<ConsultationMessageEntity>> getHistory() =>
      _repository.getConsultationHistory();

  Future<ConsultationMessageEntity> sendMessage(String text) =>
      _repository.sendMessage(text);

  Future<HealthVitalsEntity> getLatestVitals() =>
      _repository.getLatestVitals();

  Future<void> logVitals(HealthVitalsEntity vitals) =>
      _repository.logVitals(vitals);
}
