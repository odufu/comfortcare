import 'package:equatable/equatable.dart';

class ConsultantReviewEntity extends Equatable {
  final String id;
  final String doctorId;
  final String patientName;
  final double rating; // 1.0 to 5.0
  final String comment;
  final DateTime createdAt;
  final String consultationType; // 'Video Call', 'Audio Call'

  const ConsultantReviewEntity({
    required this.id,
    required this.doctorId,
    required this.patientName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.consultationType = 'Video Call',
  });

  @override
  List<Object?> get props => [
        id,
        doctorId,
        patientName,
        rating,
        comment,
        createdAt,
        consultationType,
      ];
}
