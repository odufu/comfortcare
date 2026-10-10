import 'package:equatable/equatable.dart';
import '../../../consultants/domain/entities/doctor_entity.dart';
import '../../../products/domain/entities/product.dart';
import 'health_vitals.dart';

enum TriagePriority { normal, high, critical }

class ConsultationMessageEntity extends Equatable {
  final String id;
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  final TriagePriority priority;
  final List<ProductEntity>? recommendedProducts;
  final DoctorEntity? recommendedDoctor;
  final HealthVitalsEntity? vitalsSnapshot;
  final String? clinicalNotes;

  const ConsultationMessageEntity({
    required this.id,
    required this.text,
    required this.isFromUser,
    required this.timestamp,
    this.priority = TriagePriority.normal,
    this.recommendedProducts,
    this.recommendedDoctor,
    this.vitalsSnapshot,
    this.clinicalNotes,
  });

  @override
  List<Object?> get props => [
        id,
        text,
        isFromUser,
        timestamp,
        priority,
        recommendedProducts,
        recommendedDoctor,
        vitalsSnapshot,
        clinicalNotes,
      ];
}

