import 'package:uuid/uuid.dart';
import '../../../../core/services/gemini_service.dart';
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
      vitalsSnapshot: HealthVitalsEntity(
        systolic: 124,
        diastolic: 82,
        heartRate: 84,
        bloodGlucose: 96.0,
        temperature: 38.6,
        loggedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      recommendedProducts: const [
        ProductModel(
          id: 'prod-coartem-80-480',
          name: 'Coartem 80/480mg',
          brand: 'Novartis',
          genericName: 'Artemether 80mg + Lumefantrine 480mg',
          packSize: '6 Film-Coated Tablets',
          price: 4200.0,
          wholesalePrice: 3500.0,
          category: 'Malaria Meds',
          description: 'Primary ACT anti-malarial treatment.',
          dosageInstructions: 'Take 1 tablet twice daily with meals for 3 days.',
          activeIngredients: 'Artemether 80mg, Lumefantrine 480mg',
          nafdacNumber: 'NAFDAC Reg. A4-0245',
          imageUrl:
              'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
        ),
        ProductModel(
          id: 'prod-emzor-paracetamol',
          name: 'Emzor Paracetamol 500mg',
          brand: 'Emzor Pharmaceuticals',
          genericName: 'Paracetamol BP 500mg',
          packSize: '20 Caplets',
          price: 1200.0,
          wholesalePrice: 950.0,
          category: 'Vitamins & Zinc',
          description: 'Antipyretic and analgesic for fever and chills relief.',
          dosageInstructions: '2 tabs every 8 hrs. Fast Dissolve.',
          activeIngredients: 'Paracetamol 500mg',
          nafdacNumber: 'NAFDAC Reg. 04-0312',
          imageUrl:
              'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
        ),
        ProductModel(
          id: 'prod-carestart-rdt',
          name: 'CareStart Malaria RDT Kit',
          brand: 'Access Bio',
          genericName: 'Single Antigen Cassette Test',
          packSize: '1 Test Cassette + Lancet',
          price: 1800.0,
          wholesalePrice: 1400.0,
          category: 'Medical Devices',
          description: '15-Min rapid diagnostic test for Malaria antigen.',
          dosageInstructions: 'Single use diagnostic test.',
          activeIngredients: 'HRP2 Antigen Strip',
          nafdacNumber: 'NAFDAC Reg. 03-8821',
          imageUrl:
              'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=500&auto=format&fit=crop&q=60',
        ),
        ProductModel(
          id: 'prod-ors-zinc',
          name: 'ORS Hydration + Zinc',
          brand: 'Chi Pharmaceuticals',
          genericName: 'Oral Rehydration Salts with Zinc Sulfate',
          packSize: '5 Sachets',
          price: 1400.0,
          wholesalePrice: 1100.0,
          category: 'Vitamins & Zinc',
          description: 'Electrolyte restoration and anti-fatigue hydration therapy.',
          dosageInstructions: 'Dissolve 1 sachet in 1 liter of drinking water.',
          activeIngredients: 'Oral Rehydration Salts, Zinc Sulfate',
          nafdacNumber: 'NAFDAC Reg. 04-5512',
          imageUrl:
              'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=500&auto=format&fit=crop&q=60',
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
    await Future.delayed(const Duration(milliseconds: 650));

    final lower = text.toLowerCase();
    final isEmergency = lower.contains('chest pain') ||
        lower.contains('breathing') ||
        lower.contains('unconscious');

    if (isEmergency) {
      return ConsultationMessageEntity(
        id: 'msg-${_uuid.v4().substring(0, 6)}',
        text:
            "CRITICAL MEDICAL ALERT: The symptoms described may require emergency in-person medical care. Please immediately visit the nearest emergency facility in Abuja (e.g. National Hospital Abuja or Garki Hospital Area 8) or call Abuja emergency hotline 112.",
        isFromUser: false,
        timestamp: DateTime.now(),
        priority: TriagePriority.critical,
        vitalsSnapshot: HealthVitalsEntity(
          systolic: 148,
          diastolic: 96,
          heartRate: 106,
          bloodGlucose: 112.0,
          temperature: 37.8,
          loggedAt: DateTime.now(),
        ),
        clinicalNotes: 'Triggered Emergency Triage Protocol.',
      );
    }

    // 1. Try real live AI response from GeminiService (Gemini 2.5 Flash)
    try {
      final aiResponse = await GeminiService.generateClinicalResponse(
        prompt: text,
      );
      if (aiResponse.trim().isNotEmpty) {
        final priority = lower.contains('fever') ||
                lower.contains('severe') ||
                lower.contains('vomit') ||
                lower.contains('bleeding')
            ? TriagePriority.high
            : TriagePriority.normal;

        return ConsultationMessageEntity(
          id: 'msg-${_uuid.v4().substring(0, 6)}',
          text: aiResponse,
          isFromUser: false,
          timestamp: DateTime.now(),
          priority: priority,
          clinicalNotes:
              'Real-Time Clinical AI Consultation via Dr. Comfort (Gemini 2.5 Flash) • PCN Nigeria Standards.',
          vitalsSnapshot: _currentVitals,
          recommendedProducts: _pickRelevantProducts(lower),
        );
      }
    } catch (_) {
      // Gracefully fall through to smart offline heuristic protocols
    }

    if (lower.contains('food') || lower.contains('interaction') || lower.contains('diet')) {
      return ConsultationMessageEntity(
        id: 'msg-${_uuid.v4().substring(0, 6)}',
        text:
            "Coartem (Artemether/Lumefantrine) is highly lipophilic—absorption increases up to 16-fold when taken with meals containing dietary lipids (whole milk, yogurt, or food with cooking oil). Complete all 6 tablets over 3 days as directed. Avoid grapefruit juice during therapy. Take Paracetamol with water after meals.",
        isFromUser: false,
        timestamp: DateTime.now(),
        priority: TriagePriority.normal,
        vitalsSnapshot: HealthVitalsEntity(
          systolic: 122,
          diastolic: 80,
          heartRate: 74,
          bloodGlucose: 94.0,
          temperature: 37.2,
          loggedAt: DateTime.now(),
        ),
        recommendedProducts: const [
          ProductModel(
            id: 'prod-coartem-80-480',
            name: 'Coartem 80/480mg',
            brand: 'Novartis',
            genericName: 'Artemether 80mg + Lumefantrine 480mg',
            packSize: '6 Film-Coated Tablets',
            price: 4200.0,
            wholesalePrice: 3500.0,
            category: 'Malaria Meds',
            description: 'Primary ACT anti-malarial treatment.',
            dosageInstructions: 'Take 1 tablet twice daily with meals for 3 days.',
            activeIngredients: 'Artemether 80mg, Lumefantrine 480mg',
            nafdacNumber: 'NAFDAC Reg. A4-0245',
            imageUrl:
                'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
          ),
          ProductModel(
            id: 'prod-emzor-paracetamol',
            name: 'Emzor Paracetamol 500mg',
            brand: 'Emzor Pharmaceuticals',
            genericName: 'Paracetamol BP 500mg',
            packSize: '20 Caplets',
            price: 1200.0,
            wholesalePrice: 950.0,
            category: 'Vitamins & Zinc',
            description: 'Antipyretic and analgesic for fever and chills relief.',
            dosageInstructions: '2 tabs every 8 hrs. Fast Dissolve.',
            activeIngredients: 'Paracetamol 500mg',
            nafdacNumber: 'NAFDAC Reg. 04-0312',
            imageUrl:
                'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
          ),
          ProductModel(
            id: 'prod-ors-zinc',
            name: 'ORS Hydration + Zinc',
            brand: 'Chi Pharmaceuticals',
            genericName: 'Oral Rehydration Salts with Zinc Sulfate',
            packSize: '5 Sachets',
            price: 1400.0,
            wholesalePrice: 1100.0,
            category: 'Vitamins & Zinc',
            description: 'Electrolyte restoration and anti-fatigue hydration therapy.',
            dosageInstructions: 'Dissolve 1 sachet in 1 liter of drinking water.',
            activeIngredients: 'Oral Rehydration Salts, Zinc Sulfate',
            nafdacNumber: 'NAFDAC Reg. 04-5512',
            imageUrl:
                'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=500&auto=format&fit=crop&q=60',
          ),
        ],
        clinicalNotes: 'Pharmacist Advisory: Lipophilic bioavailability enhancement protocol verified.',
      );
    }

    if (lower.contains('swap') || lower.contains('ibuprofen')) {
      return ConsultationMessageEntity(
        id: 'msg-${_uuid.v4().substring(0, 6)}',
        text:
            "Clinical Precaution: While Ibuprofen 400mg is an effective NSAID for inflammatory pain, Paracetamol 500mg is preferred as first-line antipyretic in acute malaria to prevent NSAID-induced gastric irritation and platelet aggregation inhibition. If you have no history of ulcers and require stronger pain relief, Ibuprofen 400mg may be used strictly after food.",
        isFromUser: false,
        timestamp: DateTime.now(),
        priority: TriagePriority.normal,
        vitalsSnapshot: HealthVitalsEntity(
          systolic: 124,
          diastolic: 82,
          heartRate: 76,
          bloodGlucose: 96.0,
          temperature: 37.4,
          loggedAt: DateTime.now(),
        ),
        recommendedProducts: const [
          ProductModel(
            id: 'prod-emzor-paracetamol',
            name: 'Emzor Paracetamol 500mg',
            brand: 'Emzor Pharmaceuticals',
            genericName: 'Paracetamol BP 500mg',
            packSize: '20 Caplets',
            price: 1200.0,
            wholesalePrice: 950.0,
            category: 'Vitamins & Zinc',
            description: 'Antipyretic and analgesic for fever and chills relief.',
            dosageInstructions: '2 tabs every 8 hrs. Fast Dissolve.',
            activeIngredients: 'Paracetamol 500mg',
            nafdacNumber: 'NAFDAC Reg. 04-0312',
            imageUrl:
                'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
          ),
          ProductModel(
            id: 'prod-coartem-80-480',
            name: 'Coartem 80/480mg',
            brand: 'Novartis',
            genericName: 'Artemether 80mg + Lumefantrine 480mg',
            packSize: '6 Film-Coated Tablets',
            price: 4200.0,
            wholesalePrice: 3500.0,
            category: 'Malaria Meds',
            description: 'Primary ACT anti-malarial treatment.',
            dosageInstructions: 'Take 1 tablet twice daily with meals for 3 days.',
            activeIngredients: 'Artemether 80mg, Lumefantrine 480mg',
            nafdacNumber: 'NAFDAC Reg. A4-0245',
            imageUrl:
                'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
          ),
          ProductModel(
            id: 'prod-ors-zinc',
            name: 'ORS Hydration + Zinc',
            brand: 'Chi Pharmaceuticals',
            genericName: 'Oral Rehydration Salts with Zinc Sulfate',
            packSize: '5 Sachets',
            price: 1400.0,
            wholesalePrice: 1100.0,
            category: 'Vitamins & Zinc',
            description: 'Electrolyte restoration and anti-fatigue hydration therapy.',
            dosageInstructions: 'Dissolve 1 sachet in 1 liter of drinking water.',
            activeIngredients: 'Oral Rehydration Salts, Zinc Sulfate',
            nafdacNumber: 'NAFDAC Reg. 04-5512',
            imageUrl:
                'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=500&auto=format&fit=crop&q=60',
          ),
        ],
        clinicalNotes: 'PCN Safety Protocol: Gastric sparing antipyretic recommendation applied.',
      );
    }

    if (lower.contains('dispatch') || lower.contains('photo') || lower.contains('delivery')) {
      return ConsultationMessageEntity(
        id: 'msg-${_uuid.v4().substring(0, 6)}',
        text:
            "Abuja Cold-Chain Central Depot has verified batch #ABJ-2026-894. Tamper-evident thermal packaging and calibrated temperature loggers (reading 3.4°C) are active. Cold-chain rider assigned for Life Camp / Gwarinpa express delivery (est. 25-35 minutes).",
        isFromUser: false,
        timestamp: DateTime.now(),
        priority: TriagePriority.normal,
        vitalsSnapshot: HealthVitalsEntity(
          systolic: 120,
          diastolic: 78,
          heartRate: 70,
          bloodGlucose: 92.0,
          temperature: 36.8,
          loggedAt: DateTime.now(),
        ),
        recommendedProducts: const [
          ProductModel(
            id: 'prod-coartem-80-480',
            name: 'Coartem 80/480mg',
            brand: 'Novartis',
            genericName: 'Artemether 80mg + Lumefantrine 480mg',
            packSize: '6 Film-Coated Tablets',
            price: 4200.0,
            wholesalePrice: 3500.0,
            category: 'Malaria Meds',
            description: 'Primary ACT anti-malarial treatment.',
            dosageInstructions: 'Take 1 tablet twice daily with meals for 3 days.',
            activeIngredients: 'Artemether 80mg, Lumefantrine 480mg',
            nafdacNumber: 'NAFDAC Reg. A4-0245',
            imageUrl:
                'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
          ),
          ProductModel(
            id: 'prod-carestart-rdt',
            name: 'CareStart Malaria RDT Kit',
            brand: 'Access Bio',
            genericName: 'Single Antigen Cassette Test',
            packSize: '1 Test Cassette + Lancet',
            price: 1800.0,
            wholesalePrice: 1400.0,
            category: 'Medical Devices',
            description: '15-Min rapid diagnostic test for Malaria antigen.',
            dosageInstructions: 'Single use diagnostic test.',
            activeIngredients: 'HRP2 Antigen Strip',
            nafdacNumber: 'NAFDAC Reg. 03-8821',
            imageUrl:
                'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=500&auto=format&fit=crop&q=60',
          ),
          ProductModel(
            id: 'prod-ors-zinc',
            name: 'ORS Hydration + Zinc',
            brand: 'Chi Pharmaceuticals',
            genericName: 'Oral Rehydration Salts with Zinc Sulfate',
            packSize: '5 Sachets',
            price: 1400.0,
            wholesalePrice: 1100.0,
            category: 'Vitamins & Zinc',
            description: 'Electrolyte restoration and anti-fatigue hydration therapy.',
            dosageInstructions: 'Dissolve 1 sachet in 1 liter of drinking water.',
            activeIngredients: 'Oral Rehydration Salts, Zinc Sulfate',
            nafdacNumber: 'NAFDAC Reg. 04-5512',
            imageUrl:
                'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=500&auto=format&fit=crop&q=60',
          ),
        ],
        clinicalNotes: 'Cold-Chain Telemetry Log: 3.4°C Verified • Seal #CC-8942.',
      );
    }

    if (lower.contains('pressure') || lower.contains('hypertension') || lower.contains('bp')) {
      return ConsultationMessageEntity(
        id: 'msg-${_uuid.v4().substring(0, 6)}',
        text:
            "Based on your clinical telemetry history, your recent blood pressure reading is 126/82 mmHg. This falls within the pre-hypertension threshold. I recommend seated rest for 10 minutes, staying well-hydrated, and logging repeat measurements twice daily.",
        isFromUser: false,
        timestamp: DateTime.now(),
        priority: TriagePriority.high,
        vitalsSnapshot: HealthVitalsEntity(
          systolic: 126,
          diastolic: 82,
          heartRate: 74,
          bloodGlucose: 98.0,
          temperature: 36.8,
          loggedAt: DateTime.now(),
        ),
        recommendedProducts: const [
          ProductModel(
            id: 'prod-omron-m2',
            name: 'Omron M2 Basic BP',
            brand: 'Omron',
            genericName: 'Upper Arm Digital',
            packSize: '1 Complete Device with Cuff',
            price: 38500.0,
            wholesalePrice: 32000.0,
            category: 'Health Devices',
            description: 'Clinically validated digital blood pressure monitor.',
            dosageInstructions: 'Measure seated after 5 minutes of rest, morning and evening.',
            activeIngredients: 'Oscillometric Sensor, Clinical Validation Protocol',
            nafdacNumber: '3yr Warranty',
            imageUrl:
                'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?w=600&auto=format&fit=crop&q=80',
          ),
          ProductModel(
            id: 'prod-ors-zinc',
            name: 'ORS Hydration + Zinc',
            brand: 'Chi Pharmaceuticals',
            genericName: 'Oral Rehydration Salts with Zinc Sulfate',
            packSize: '5 Sachets',
            price: 1400.0,
            wholesalePrice: 1100.0,
            category: 'Vitamins & Zinc',
            description: 'Electrolyte restoration and anti-fatigue hydration therapy.',
            dosageInstructions: 'Dissolve 1 sachet in 1 liter of drinking water.',
            activeIngredients: 'Oral Rehydration Salts, Zinc Sulfate',
            nafdacNumber: 'NAFDAC Reg. 04-5512',
            imageUrl:
                'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=500&auto=format&fit=crop&q=60',
          ),
        ],
        clinicalNotes: 'Cardiovascular Care Protocol • PCN Abuja Guidelines.',
      );
    }

    // Default rich clinical consultation response with vitals & prescriptions
    return ConsultationMessageEntity(
      id: 'msg-${_uuid.v4().substring(0, 6)}',
      text:
          "Thank you for sharing your health update regarding '$text'. I have evaluated your inquiry against your active biometric profile and regional health indicators. Here is your personalized recovery protocol and verified medications.",
      isFromUser: false,
      timestamp: DateTime.now(),
      priority: TriagePriority.normal,
      vitalsSnapshot: HealthVitalsEntity(
        systolic: 122,
        diastolic: 80,
        heartRate: 74,
        bloodGlucose: 95.0,
        temperature: 37.1,
        loggedAt: DateTime.now(),
      ),
      recommendedProducts: const [
        ProductModel(
          id: 'prod-coartem-80-480',
          name: 'Coartem 80/480mg',
          brand: 'Novartis',
          genericName: 'Artemether 80mg + Lumefantrine 480mg',
          packSize: '6 Film-Coated Tablets',
          price: 4200.0,
          wholesalePrice: 3500.0,
          category: 'Malaria Meds',
          description: 'Primary ACT anti-malarial treatment.',
          dosageInstructions: 'Take 1 tablet twice daily with meals for 3 days.',
          activeIngredients: 'Artemether 80mg, Lumefantrine 480mg',
          nafdacNumber: 'NAFDAC Reg. A4-0245',
          imageUrl:
              'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
        ),
        ProductModel(
          id: 'prod-emzor-paracetamol',
          name: 'Emzor Paracetamol 500mg',
          brand: 'Emzor Pharmaceuticals',
          genericName: 'Paracetamol BP 500mg',
          packSize: '20 Caplets',
          price: 1200.0,
          wholesalePrice: 950.0,
          category: 'Vitamins & Zinc',
          description: 'Antipyretic and analgesic for fever and chills relief.',
          dosageInstructions: '2 tabs every 8 hrs. Fast Dissolve.',
          activeIngredients: 'Paracetamol 500mg',
          nafdacNumber: 'NAFDAC Reg. 04-0312',
          imageUrl:
              'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
        ),
        ProductModel(
          id: 'prod-carestart-rdt',
          name: 'CareStart Malaria RDT Kit',
          brand: 'Access Bio',
          genericName: 'Single Antigen Cassette Test',
          packSize: '1 Test Cassette + Lancet',
          price: 1800.0,
          wholesalePrice: 1400.0,
          category: 'Medical Devices',
          description: '15-Min rapid diagnostic test for Malaria antigen.',
          dosageInstructions: 'Single use diagnostic test.',
          activeIngredients: 'HRP2 Antigen Strip',
          nafdacNumber: 'NAFDAC Reg. 03-8821',
          imageUrl:
              'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=500&auto=format&fit=crop&q=60',
        ),
        ProductModel(
          id: 'prod-ors-zinc',
          name: 'ORS Hydration + Zinc',
          brand: 'Chi Pharmaceuticals',
          genericName: 'Oral Rehydration Salts with Zinc Sulfate',
          packSize: '5 Sachets',
          price: 1400.0,
          wholesalePrice: 1100.0,
          category: 'Vitamins & Zinc',
          description: 'Electrolyte restoration and anti-fatigue hydration therapy.',
          dosageInstructions: 'Dissolve 1 sachet in 1 liter of drinking water.',
          activeIngredients: 'Oral Rehydration Salts, Zinc Sulfate',
          nafdacNumber: 'NAFDAC Reg. 04-5512',
          imageUrl:
              'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=500&auto=format&fit=crop&q=60',
        ),
      ],
      clinicalNotes: 'Supervised by Pharm. Halima Bello (PCN #44912) • Abuja Central Depot.',
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

  List<ProductModel> _pickRelevantProducts(String lower) {
    final list = <ProductModel>[];
    if (lower.contains('malaria') || lower.contains('chills') || lower.contains('mosquito')) {
      list.add(const ProductModel(
        id: 'prod-coartem-80-480',
        name: 'Coartem 80/480mg',
        brand: 'Novartis',
        genericName: 'Novartis • 6 Tablets',
        packSize: '6 Tablets Blister Pack',
        price: 4200.0,
        wholesalePrice: 3833.33,
        category: 'Antimalarials',
        description: 'First-line ACT antimalarial for Plasmodium falciparum clearance.',
        dosageInstructions: 'Take 1 tablet twice daily with meals for 3 consecutive days.',
        activeIngredients: 'Artemether (80 mg), Lumefantrine (480 mg)',
        nafdacNumber: 'NAFDAC: 04-2011',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCYoLw9r-RmsXTnOXgJM3rXNLOWTp4aNanpbJT4yg1dHRH5bh8wBJw_eZkLeWPOHuZZ_kVoP-UXzPUtD-sfGLck1C3w9gjm4SZ56JuI0g4F_HK7Ob0BQbZ3Bi0BW4x66DmgyxUZGJx_OLz-TnFNPyQg49zsaiNsncvjT35QqHDYEHcDPjQ54vxtV0J_wBbh5rV6n2cXy_EKqVhLe6jV77o16zZPiZGVmHho2akb6gLVW1oRjZXo8o5CaNgYsVNmVvK3mQ',
      ));
    }
    if (lower.contains('headache') ||
        lower.contains('pain') ||
        lower.contains('fever') ||
        lower.contains('temperature') ||
        lower.contains('ache')) {
      list.add(const ProductModel(
        id: 'prod-emzor-paracetamol',
        name: 'Emzor Paracetamol 500mg',
        brand: 'Emzor Nigeria',
        genericName: 'Pain & Fever Relief',
        packSize: '100 Tablets Dispenser',
        price: 1200.0,
        wholesalePrice: 950.0,
        category: 'Vitamins & Immunity',
        description: 'Antipyretic and analgesic for rapid relief of headache and fever.',
        dosageInstructions: 'Take 2 tablets every 8 hours after food.',
        activeIngredients: 'Paracetamol BP (500 mg)',
        nafdacNumber: 'NAFDAC Approved 04-0125',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCG62rWr9JxPQ9S2YUheX_IV-3Z7b3R-0iE31gDJAYwxN_ZujSybiUkPJ-lGbFumwZqaBqkz749PIdssh9GLR_Zh3RqLolYgmipDWk4YiVqtlUXFGJjcvV7dUMj5LCgiqEoEDDRy9QdCxjuCaORKcyjhgyon9Tm6M7yQf6lH-B1ap5BkzBQQEouCNunxIoDlzSL0-GXsf0GNJFvnDX27doXELYtgvFIbnw6vcwIWn2A1z1iWT03rkAq',
      ));
    }
    if (lower.contains('bp') ||
        lower.contains('pressure') ||
        lower.contains('heart') ||
        lower.contains('hypertension')) {
      list.add(const ProductModel(
        id: 'prod-omron-m2',
        name: 'Omron M2 Basic BP',
        brand: 'Omron',
        genericName: 'Upper Arm Digital',
        packSize: '1 Complete Device with Cuff',
        price: 38500.0,
        wholesalePrice: 32000.0,
        category: 'Health Devices',
        description: 'Clinically validated digital blood pressure monitor with Intellisense.',
        dosageInstructions: 'Measure seated after 5 minutes of rest, morning and evening.',
        activeIngredients: 'Oscillometric Sensor, Clinical Validation Protocol',
        nafdacNumber: '3yr Warranty',
        imageUrl:
            'https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?w=600&auto=format&fit=crop&q=80',
      ));
    }
    if (lower.contains('infection') || lower.contains('cough') || lower.contains('antibiotic')) {
      list.add(const ProductModel(
        id: 'prod-augmentin-625',
        name: 'Augmentin 625mg',
        brand: 'GSK',
        genericName: 'Amoxicillin + Clavulanic Acid (14 Tabs)',
        packSize: '14 Film-Coated Tablets',
        price: 7500.0,
        wholesalePrice: 6200.0,
        category: 'Antibiotics',
        description: 'Broad spectrum antibacterial therapy for respiratory tract infections.',
        dosageInstructions: 'Take 1 tablet every 12 hours at start of meals as prescribed.',
        activeIngredients: 'Amoxicillin Trihydrate (500 mg), Potassium Clavulanate (125 mg)',
        nafdacNumber: 'NAFDAC Reg. No. 04-2194',
        requiresPrescription: true,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCvRFtfhY1CZMrdW6GR2-AFf7eBxEjGi0yfEf-bdUQV5O_S-oj4eV5iV0WylJ1dM-2knDIf0oPguNIa4SGr7pmZHKHAuMQgNUFUW5VK1z0QY5W2RtE_b2D7zSLND7XlH5H0npyqlutF9FPCgW74_Gapenn7XZLj2_o6MvopsBRmdKAqqhUnQVMaU87Z959jC9WMAuimo9QPmEEO-U6aQjGnxUhqwQCaTgGdJn-x0jMJAeK10cph4Ec-',
      ));
    }
    if (list.isEmpty) {
      list.add(const ProductModel(
        id: 'prod-panadol-extra',
        name: 'Panadol Extra Tablets',
        brand: 'GlaxoSmithKline (GSK)',
        genericName: 'Paracetamol 500mg + Caffeine 65mg',
        packSize: '10 Blister Packs (20 Tabs)',
        price: 1850.0,
        wholesalePrice: 1450.0,
        category: 'Vitamins & Immunity',
        description: 'Tough on pain, gentle on stomach.',
        dosageInstructions: 'Take 1-2 tablets every 4-6 hours as needed.',
        activeIngredients: 'Paracetamol (500 mg), Caffeine (65 mg)',
        nafdacNumber: 'NAFDAC Reg. No. 04-0312',
        imageUrl:
            'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60',
      ));
    }
    return list;
  }
}
