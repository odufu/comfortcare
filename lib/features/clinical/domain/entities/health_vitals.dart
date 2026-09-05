import 'package:equatable/equatable.dart';

class HealthVitalsEntity extends Equatable {
  final int systolic;
  final int diastolic;
  final int heartRate;
  final double bloodGlucose;
  final double temperature;
  final DateTime loggedAt;

  const HealthVitalsEntity({
    this.systolic = 124,
    this.diastolic = 82,
    this.heartRate = 72,
    this.bloodGlucose = 96.0,
    this.temperature = 36.8,
    required this.loggedAt,
  });

  String get bpStatus => (systolic < 120 && diastolic < 80)
      ? 'Optimal'
      : (systolic <= 129 && diastolic < 80)
          ? 'Normal'
          : 'Elevated';

  String get glucoseStatus => bloodGlucose < 100 ? 'Normal Fasting' : 'Elevated';

  @override
  List<Object?> get props => [
        systolic,
        diastolic,
        heartRate,
        bloodGlucose,
        temperature,
        loggedAt,
      ];
}
