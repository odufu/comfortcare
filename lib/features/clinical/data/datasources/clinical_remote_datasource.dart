import 'package:uuid/uuid.dart';
import '../../../products/data/models/product_model.dart';
import '../../domain/entities/consultation_message.dart';
import '../../domain/entities/health_vitals.dart';

abstract class ClinicalRemoteDataSource {
  Future<List<ConsultationMessageEntity>> getConsultationHistory();
  Future<ConsultationMessageEntity> sendMessage(String text);
  Future<HealthVitalsEntity> getLatestVitals();
  Future<void> logVitals(HealthVitalsEntity vitals);
}

class ClinicalRemoteDataSourceImpl implements ClinicalRemoteDataSource {
  final _uuid = const Uuid();

  static final List<ConsultationMessageEntity> _initialMessages = [
    ConsultationMessageEntity(
      id: 'msg-01',
      text:
          "Good afternoon. I've had intense headache, chills, fever of 38.6°C, and fatigue since last night. What should I take?",
      isFromUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ConsultationMessageEntity(
      id: 'msg-02',
      text:
          "Hello, based on your acute febrile symptoms and prevalence in the Abuja area, this indicates uncomplicated malaria accompanied by febrile pain. I have generated a personalized recovery protocol formulated for fast symptom clearance.",
      isFromUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      priority: TriagePriority.high,
      clinicalNotes:
          'Reviewed against PCN malaria management guidelines & temperature record (38.6°C).',
      recommendedProducts: const [
        ProductModel(
          id: 'prod-coartem-80-480',
          name: 'Coartem 80/480mg',
          brand: 'Novartis',
          genericName: 'Artemether / Lumefantrine (6 Tabs)',
          packSize: '6 Tablets Pack',
          price: 3850.0,
          wholesalePrice: 3150.0,
          category: 'Malaria Meds',
          description: 'Primary ACT anti-malarial treatment.',
          dosageInstructions: 'Take 1 tablet twice daily for 3 days.',
          activeIngredients: 'Artemether 80mg, Lumefantrine 480mg',
          nafdacNumber: 'NAFDAC Reg. A4-0245',
          imageUrl:
              'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
        ),
        ProductModel(
          id: 'prod-panadol-extra',
          name: 'Panadol Extra Tablets',
          brand: 'GSK',
          genericName: 'Paracetamol 500mg + Caffeine 65mg',
          packSize: '10 Blister Packs (20 Tabs)',
          price: 1850.0,
          wholesalePrice: 1450.0,
          category: 'Vitamins & Zinc',
          description: 'Antipyretic and analgesic symptom control.',
          dosageInstructions: 'Take 1-2 tablets every 6 hours.',
          activeIngredients: 'Paracetamol 500mg, Caffeine 65mg',
          nafdacNumber: 'NAFDAC Reg. 04-0312',
          imageUrl:
              'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
        ),
      ],
    ),
  ];

  static HealthVitalsEntity _currentVitals = HealthVitalsEntity(
    systolic: 124,
    diastolic: 82,
    heartRate: 72,
    bloodGlucose: 96.0,
    temperature: 36.8,
    loggedAt: DateTime.now(),
  );

  @override
  Future<List<ConsultationMessageEntity>> getConsultationHistory() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _initialMessages;
  }

  @override
  Future<ConsultationMessageEntity> sendMessage(String text) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final isEmergency = text.toLowerCase().contains('chest pain') ||
        text.toLowerCase().contains('breathing') ||
        text.toLowerCase().contains('unconscious');

    if (isEmergency) {
      return ConsultationMessageEntity(
        id: 'msg-${_uuid.v4().substring(0, 6)}',
        text:
            "CRITICAL MEDICAL ALERT: The symptoms described may require emergency in-person medical care. Please immediately visit the nearest emergency facility in Abuja (e.g. National Hospital Abuja or Garki Hospital Area 8) or call Abuja emergency hotline 112.",
        isFromUser: false,
        timestamp: DateTime.now(),
        priority: TriagePriority.critical,
        clinicalNotes: 'Triggered Emergency Triage Protocol.',
      );
    }

    return ConsultationMessageEntity(
      id: 'msg-${_uuid.v4().substring(0, 6)}',
      text:
          "Thank you for sharing your health update. Your symptoms have been logged in your clinical docket. Our on-call Abuja supervising pharmacist is available for verification. Would you like to review recommended formulary treatments?",
      isFromUser: false,
      timestamp: DateTime.now(),
      priority: TriagePriority.normal,
      clinicalNotes: 'Supervised under PCN Abuja clinical guidelines.',
    );
  }

  @override
  Future<HealthVitalsEntity> getLatestVitals() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentVitals;
  }

  @override
  Future<void> logVitals(HealthVitalsEntity vitals) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentVitals = vitals;
  }
}
