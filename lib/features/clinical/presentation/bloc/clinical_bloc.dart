import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/consultation_message.dart';
import '../../domain/usecases/manage_clinical.dart';
import 'clinical_event.dart';
import 'clinical_state.dart';

class ClinicalBloc extends Bloc<ClinicalEvent, ClinicalState> {
  final ManageClinicalUseCase _manageClinicalUseCase;
  final _uuid = const Uuid();

  ClinicalBloc({required ManageClinicalUseCase manageClinicalUseCase})
      : _manageClinicalUseCase = manageClinicalUseCase,
        super(const ClinicalState()) {
    on<LoadConsultationHistory>(_onLoadConsultationHistory);
    on<SendConsultationMessage>(_onSendConsultationMessage);
    on<LoadHealthVitals>(_onLoadHealthVitals);
    on<LogHealthVitalsEvent>(_onLogHealthVitals);
  }

  Future<void> _onLoadConsultationHistory(
      LoadConsultationHistory event, Emitter<ClinicalState> emit) async {
    emit(state.copyWith(status: ClinicalStatus.loading));
    try {
      final messages = await _manageClinicalUseCase.getHistory();
      final vitals = await _manageClinicalUseCase.getLatestVitals();
      emit(state.copyWith(
        status: ClinicalStatus.loaded,
        messages: messages,
        vitals: vitals,
      ));
    } catch (e) {
      emit(state.copyWith(status: ClinicalStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onSendConsultationMessage(
      SendConsultationMessage event, Emitter<ClinicalState> emit) async {
    final userMsg = ConsultationMessageEntity(
      id: 'msg-${_uuid.v4().substring(0, 6)}',
      text: event.message,
      isFromUser: true,
      timestamp: DateTime.now(),
    );

    final updated = List<ConsultationMessageEntity>.from(state.messages)..add(userMsg);
    emit(state.copyWith(messages: updated, isThinking: true));

    try {
      final reply = await _manageClinicalUseCase.sendMessage(event.message);
      final finalMessages = List<ConsultationMessageEntity>.from(state.messages)..add(reply);
      emit(state.copyWith(
        status: ClinicalStatus.messageSent,
        messages: finalMessages,
        vitals: reply.vitalsSnapshot ?? state.vitals,
        isThinking: false,
      ));
    } catch (e) {
      emit(state.copyWith(isThinking: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadHealthVitals(
      LoadHealthVitals event, Emitter<ClinicalState> emit) async {
    try {
      final vitals = await _manageClinicalUseCase.getLatestVitals();
      emit(state.copyWith(vitals: vitals));
    } catch (_) {}
  }

  Future<void> _onLogHealthVitals(
      LogHealthVitalsEvent event, Emitter<ClinicalState> emit) async {
    try {
      await _manageClinicalUseCase.logVitals(event.vitals);
      emit(state.copyWith(vitals: event.vitals));
    } catch (_) {}
  }
}
