import 'package:equatable/equatable.dart';
import '../../domain/entities/health_vitals.dart';

abstract class ClinicalEvent extends Equatable {
  const ClinicalEvent();

  @override
  List<Object?> get props => [];
}

class LoadConsultationHistory extends ClinicalEvent {
  final String? userName;
  final bool forceNewSession;

  const LoadConsultationHistory({
    this.userName,
    this.forceNewSession = false,
  });

  @override
  List<Object?> get props => [userName, forceNewSession];
}

class ClearConsultationSessionEvent extends ClinicalEvent {}

class StartNewSessionEvent extends ClinicalEvent {
  final String? userName;

  const StartNewSessionEvent({this.userName});

  @override
  List<Object?> get props => [userName];
}

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
