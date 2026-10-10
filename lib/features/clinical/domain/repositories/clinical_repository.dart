import '../entities/consultation_message.dart';
import '../entities/health_vitals.dart';

abstract class ClinicalRepository {
  Future<List<ConsultationMessageEntity>> getConsultationHistory({
    String? userName,
    bool forceNewSession = true,
  });
  Future<ConsultationMessageEntity> sendMessage(String text);
  Future<HealthVitalsEntity> getLatestVitals();
  Future<void> logVitals(HealthVitalsEntity vitals);
  Future<List<ConsultationMessageEntity>> startNewSession({String? userName});
  Future<void> clearHistory();
}
