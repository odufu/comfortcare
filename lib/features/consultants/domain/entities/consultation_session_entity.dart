import 'package:equatable/equatable.dart';

class ConsultationSessionEntity extends Equatable {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorAvatar;
  final String doctorSpecialty;
  final String patientId;
  final String patientName;
  final DateTime scheduledAt;
  final String chiefComplaint;
  final String status; // 'waiting', 'in_progress', 'completed', 'cancelled'
  final String callType; // 'video', 'audio'
  final int durationSeconds;
  final String? clinicalNotes;
  final double fee;
  final double? patientRating;
  final String? patientReview;

  const ConsultationSessionEntity({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorAvatar,
    required this.doctorSpecialty,
    required this.patientId,
    required this.patientName,
    required this.scheduledAt,
    required this.chiefComplaint,
    this.status = 'waiting',
    this.callType = 'video',
    this.durationSeconds = 0,
    this.clinicalNotes,
    required this.fee,
    this.patientRating,
    this.patientReview,
  });

  ConsultationSessionEntity copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    String? doctorAvatar,
    String? doctorSpecialty,
    String? patientId,
    String? patientName,
    DateTime? scheduledAt,
    String? chiefComplaint,
    String? status,
    String? callType,
    int? durationSeconds,
    String? clinicalNotes,
    double? fee,
    double? patientRating,
    String? patientReview,
  }) {
    return ConsultationSessionEntity(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorAvatar: doctorAvatar ?? this.doctorAvatar,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      status: status ?? this.status,
      callType: callType ?? this.callType,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
      fee: fee ?? this.fee,
      patientRating: patientRating ?? this.patientRating,
      patientReview: patientReview ?? this.patientReview,
    );
  }

  @override
  List<Object?> get props => [
        id,
        doctorId,
        doctorName,
        doctorAvatar,
        doctorSpecialty,
        patientId,
        patientName,
        scheduledAt,
        chiefComplaint,
        status,
        callType,
        durationSeconds,
        clinicalNotes,
        fee,
        patientRating,
        patientReview,
      ];
}
