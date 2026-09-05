import 'package:equatable/equatable.dart';
import '../../domain/entities/consultation_message.dart';
import '../../domain/entities/health_vitals.dart';

enum ClinicalStatus { initial, loading, loaded, messageSent, error }

class ClinicalState extends Equatable {
  final ClinicalStatus status;
  final List<ConsultationMessageEntity> messages;
  final HealthVitalsEntity? vitals;
  final bool isThinking;
  final String? errorMessage;

  const ClinicalState({
    this.status = ClinicalStatus.initial,
    this.messages = const [],
    this.vitals,
    this.isThinking = false,
    this.errorMessage,
  });

  ClinicalState copyWith({
    ClinicalStatus? status,
    List<ConsultationMessageEntity>? messages,
    HealthVitalsEntity? vitals,
    bool? isThinking,
    String? errorMessage,
  }) {
    return ClinicalState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      vitals: vitals ?? this.vitals,
      isThinking: isThinking ?? this.isThinking,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, messages, vitals, isThinking, errorMessage];
}
