import 'package:equatable/equatable.dart';
import '../../domain/entities/health_vitals.dart';

abstract class ClinicalEvent extends Equatable {
  const ClinicalEvent();

  @override
  List<Object?> get props => [];
}

class LoadConsultationHistory extends ClinicalEvent {}

class SendConsultationMessage extends ClinicalEvent {
  final String message;

  const SendConsultationMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class LoadHealthVitals extends ClinicalEvent {}

class LogHealthVitalsEvent extends ClinicalEvent {
  final HealthVitalsEntity vitals;

  const LogHealthVitalsEvent(this.vitals);

  @override
  List<Object?> get props => [vitals];
}
