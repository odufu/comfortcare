import 'package:uuid/uuid.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../consultants/data/datasources/consultants_remote_datasource.dart';
import '../../../consultants/domain/entities/doctor_entity.dart';
import '../../../products/data/datasources/products_remote_datasource.dart';
import '../../../products/data/models/product_model.dart';
import '../../domain/entities/consultation_message.dart';
import '../../domain/entities/health_vitals.dart';

abstract class ClinicalRemoteDataSource {
  Future<List<ConsultationMessageEntity>> getConsultationHistory({
    String? userName,
    bool forceNewSession = true,
  });
  Future<ConsultationMessageEntity> sendMessage(String text);
  Future<HealthVitalsEntity> getLatestVitals();
  Future<void> logVitals(HealthVitalsEntity vitals);
  Future<List<ConsultationMessageEntity>> startNewSession({String? userName});
  Future<void> clearHistory();
}

class ClinicalRemoteDataSourceImpl implements ClinicalRemoteDataSource {
  final _uuid = const Uuid();

  // Multi-turn consultation history capped to 7 days retention and max 50 message size
  static final List<ConsultationMessageEntity> _historyStore = [];

  static void _pruneHistory() {
    final now = DateTime.now();
    _historyStore.removeWhere((msg) => now.difference(msg.timestamp).inDays > 7);
    if (_historyStore.length > 50) {
      _historyStore.removeRange(0, _historyStore.length - 50);
    }
  }

  ConsultationMessageEntity _createInitialGreeting(String? userName) {
    final name = (userName != null && userName.trim().isNotEmpty)
        ? ' ${userName.trim()}'
        : '';
    return ConsultationMessageEntity(
      id: 'msg-welcome-${_uuid.v4().substring(0, 6)}',
      text:
          "Hello$name! I am Dr. Comfort, your AI Clinical Pharmacist at ComfortCare Abuja. How may I assist you with your health today?",
      isFromUser: false,
      timestamp: DateTime.now(),
      priority: TriagePriority.normal,
      clinicalNotes: null,
      vitalsSnapshot: null,
      recommendedProducts: const [],
      recommendedDoctor: null,
    );
  }

  static HealthVitalsEntity _currentVitals = HealthVitalsEntity(
    systolic: 124,
    diastolic: 82,
    heartRate: 72,
    bloodGlucose: 96.0,
    temperature: 36.8,
    loggedAt: DateTime.now(),
  );

  @override
  Future<List<ConsultationMessageEntity>> getConsultationHistory({
    String? userName,
    bool forceNewSession = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _pruneHistory();
    // Maintain cached context within session until user logs out or requests fresh session
    if (forceNewSession || _historyStore.isEmpty) {
      _historyStore.clear();
      _historyStore.add(_createInitialGreeting(userName));
    }
    return List.unmodifiable(_historyStore);
  }

  @override
  Future<List<ConsultationMessageEntity>> startNewSession({String? userName}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _historyStore.clear();
    _historyStore.add(_createInitialGreeting(userName));
    return List.unmodifiable(_historyStore);
  }

  @override
  Future<void> clearHistory() async {
    _historyStore.clear();
  }

  @override
  Future<ConsultationMessageEntity> sendMessage(String text) async {
    await Future.delayed(const Duration(milliseconds: 650));

    // Record user message in capped history store
    final userMsg = ConsultationMessageEntity(
      id: 'msg-usr-${_uuid.v4().substring(0, 6)}',
      text: text,
      isFromUser: true,
      timestamp: DateTime.now(),
    );
    _historyStore.add(userMsg);
    _pruneHistory();

    final reply = await _generateReply(text);
    _historyStore.add(reply);
    _pruneHistory();
    return reply;
  }

  Future<ConsultationMessageEntity> _generateReply(String text) async {
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

    // 1. Try real live AI response from GeminiService (Gemini 2.5 Flash) with conversation history context
    try {
      final priorTurns = _historyStore
          .take(_historyStore.length - 1)
          .map((m) => {
                'role': m.isFromUser ? 'user' : 'model',
                'text': m.text,
              })
          .toList();

      final aiResponse = await GeminiService.generateClinicalResponse(
        prompt: text,
        productCatalog: ProductsRemoteDataSourceImpl.inMemoryProducts,
        conversationHistory: priorTurns,
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
          vitalsSnapshot: (lower.contains('bp') || lower.contains('pressure') || lower.contains('vital') || lower.contains('telemetry'))
              ? _currentVitals
              : null,
          recommendedProducts: _pickRelevantProducts(lower, aiResponse: aiResponse),
          recommendedDoctor: _pickRelevantDoctor(lower, aiResponse: aiResponse),
        );
      }
    } catch (_) {
      // Gracefully fall through to smart offline heuristic protocols
    }

    // 2. Social & Greeting protocol
    final isGreeting = lower == 'hello' ||
        lower == 'hi' ||
        lower == 'hey' ||
        lower.startsWith('good morning') ||
        lower.startsWith('good afternoon') ||
        lower.startsWith('good evening') ||
        lower.contains('greetings') ||
        lower.contains('how are you');

    if (isGreeting && !lower.contains('pain') && !lower.contains('fever') && !lower.contains('malaria')) {
      return ConsultationMessageEntity(
        id: 'msg-${_uuid.v4().substring(0, 6)}',
        text:
            "Hello! I am Dr. Comfort, your official Lead AI Clinical Pharmacist at ComfortCare Pharmaceuticals Ltd in Abuja.\n\nHow can I support your health today? You can share any symptoms you are experiencing, ask about dosage, compare prices, or inquire about medications in our Abuja pharmacy inventory.",
        isFromUser: false,
        timestamp: DateTime.now(),
        priority: TriagePriority.normal,
        clinicalNotes: 'AI Pharmacist Introduction & Telehealth Intake.',
        vitalsSnapshot: null,
        recommendedProducts: const [],
        recommendedDoctor: null,
      );
    }

    // 3. Simple polite conversational protocol
    final isSimplePolite = lower == 'thank you' ||
        lower == 'thanks' ||
        lower == 'thank you so much' ||
        lower == 'ok' ||
        lower == 'okay' ||
        lower == 'alright' ||
        lower == 'got it' ||
        lower == 'goodbye' ||
        lower == 'bye';

    if (isSimplePolite) {
      return ConsultationMessageEntity(
        id: 'msg-${_uuid.v4().substring(0, 6)}',
        text:
            "You are very welcome! If you notice any changes in your symptoms, need dosage clarifications, or wish to connect with one of our licensed on-call specialists, feel free to ask anytime. Wishing you excellent health!",
        isFromUser: false,
        timestamp: DateTime.now(),
        priority: TriagePriority.normal,
        clinicalNotes: 'Polite Consultation Wrap-Up.',
        vitalsSnapshot: null,
        recommendedProducts: const [],
        recommendedDoctor: null,
      );
    }

    // 4. Name & Identity protocol
    if (lower.contains('your name') || lower.contains('who are you') || lower.contains('what is your name')) {
      return ConsultationMessageEntity(
        id: 'msg-${_uuid.v4().substring(0, 6)}',
        text:
            "I am Dr. Comfort, your dedicated ComfortCare AI Clinical Pharmacist and Telehealth Assistant based in Abuja, Nigeria.\n\nI am clinically calibrated to evaluate symptoms, recommend PCN-standard medications from our inventory, provide dosage instructions, check drug interactions, and help find cost-effective or equivalent alternatives.",
        isFromUser: false,
        timestamp: DateTime.now(),
        priority: TriagePriority.normal,
        clinicalNotes: 'Dr. Comfort Clinical Identity & Practice Scope Verified.',
        vitalsSnapshot: null,
        recommendedProducts: const [],
        recommendedDoctor: null,
      );
    }

    // 5. Bone Fracture Recovery, Leg Mobility & Physical/Psychological Therapy Protocol
    final isFractureOrMobility = lower.contains('fracture') ||
        lower.contains('frature') ||
        (lower.contains('leg') &&
            (lower.contains('fluid') ||
                lower.contains('fluidly') ||
                lower.contains('stiff') ||
                lower.contains('mov') ||
                lower.contains('walk'))) ||
        ((lower.contains('therapist') ||
                lower.contains('terapist') ||
                lower.contains('physio') ||
                lower.contains('psycho')) &&
            (lower.contains('injur') ||
                lower.contains('bone') ||
                lower.contains('leg') ||
                lower.contains('recover') ||
                lower.contains('stiff')));

    if (isFractureOrMobility) {
      final catalog = ProductsRemoteDataSourceImpl.inMemoryProducts;
      final fractureAccompaniedProducts = catalog.where((p) {
        final id = p.id;
        return id == 'prod-osteocare-vitabiotics' ||
            id == 'prod-deep-heat-rub' ||
            id == 'prod-neurobion-forte' ||
            id == 'prod-emzor-paracetamol';
      }).toList();

      final isPsychoRequested = lower.contains('psycho') || lower.contains('mental') || lower.contains('counsel');
      final availableSpecialist = _pickRelevantDoctor(lower);

      return ConsultationMessageEntity(
        id: 'msg-${_uuid.v4().substring(0, 6)}',
        text:
            "Following a bone fracture, experiencing leg stiffness and difficulty moving fluidly involves both physical mechanics and psychological adaptation:\n\n"
            "• **Basics of Psychotherapy in Fracture Recovery**:\n"
            "Physical trauma from an injury or fracture often triggers subconscious fear of movement (**kinesiophobia**), pain catastrophizing, and mental hesitation when trying to bear weight. Psychotherapy (specifically cognitive-behavioral pain psychology and mindfulness-based pacing) helps you by:\n"
            "  1. Calming trauma-induced anxiety and retuning your central pain sensitivity.\n"
            "  2. De-activating subconscious 'muscle guarding'—where your brain tenses muscles defensively, preventing fluid motion.\n"
            "  3. Rebuilding cognitive confidence so you can engage smoothly in walking drills.\n\n"
            "• **The Complementary Role of Physiotherapy**:\n"
            "While psychotherapy restores mental confidence, **Physiotherapy** restores physical joint kinematics. After weeks in a cast or splint, knee/ankle capsules lose compliance and quadriceps atrophy. A physiotherapist guides you through passive joint mobilization, progressive weight-bearing, and gait retraining so your leg regains its fluid, natural stride.\n\n"
            "• **Recommended On-Call Specialist**:\n"
            "I have matched you with **${availableSpecialist?.name ?? 'Dr. Osas Ighodaro (PT, DPT)'}**, our **${availableSpecialist?.title ?? 'Consultant Orthopedic Physiotherapist'}**, who is **Available Now** for an instant audio or video consultation. ${isPsychoRequested ? 'You can also consult **Dr. Fatima Al-Hassan (PhD)**, our Consultant Clinical Psychotherapist, who is also Available Now for injury coping.' : ''}\n\n"
            "• **Accompanied Medications & Recovery Products**:\n"
            "To support biological bone union and relieve stiffness during rehabilitation, I have recommended:\n"
            "  1. **Osteocare Calcium + Vitamin D3 & Zinc** (₦4,800) – Promotes bone remineralization & structural consolidation.\n"
            "  2. **Deep Heat Fast Relief Rub** (₦2,950) – Loosens tight, stiff muscles before therapy exercises.\n"
            "  3. **Neurobion Forte** (₦3,400) – High-potency Neurotropic B-vitamins for neuromuscular coordination & nerve firing.\n"
            "  4. **Emzor Paracetamol 500mg** (₦1,200) – Safe, gastric-sparing pain relief post-exercise.",
        isFromUser: false,
        timestamp: DateTime.now(),
        priority: TriagePriority.normal,
        clinicalNotes: 'Fracture Mobility & Multidisciplinary Rehabilitation Protocol • ComfortCare Orthopedic Desk.',
        vitalsSnapshot: null,
        recommendedProducts: fractureAccompaniedProducts,
        recommendedDoctor: availableSpecialist,
      );
    }

    // 6. Headache & Acute Pain Relief Protocol (Dual Medics + Consultant Support)
    final isHeadacheOrMigraine = lower.contains('headache') ||
        lower.contains('migraine') ||
        lower.contains('head ache');

    if (isHeadacheOrMigraine) {
      final catalog = ProductsRemoteDataSourceImpl.inMemoryProducts;
      final headacheProducts = [
        catalog.firstWhere((p) => p.id == 'prod-panadol-extra'),
        catalog.firstWhere((p) => p.id == 'prod-emzor-paracetamol'),
      ];
      final requestedConsultant = lower.contains('consultant') ||
          lower.contains('doctor') ||
          lower.contains('talk to') ||
          lower.contains('specialist') ||
          lower.contains('physician');
      final doctorMatch = requestedConsultant ? _pickRelevantDoctor(lower) : null;

      return ConsultationMessageEntity(
        id: 'msg-${_uuid.v4().substring(0, 6)}',
        text:
            "Good day! For fast and reliable relief from your headache, I recommend the following medications from our inventory:\n\n"
            "• **Panadol Extra Tablets** (₦1,850): Contains Paracetamol 500mg and Caffeine 65mg. The caffeine accelerates paracetamol gastric absorption and potentiates the analgesic effect by ~40%, offering faster relief for tension headaches and migraines. Take 1–2 tablets every 4–6 hours as needed (do not exceed 8 tablets in 24 hours).\n"
            "• **Emzor Paracetamol 500mg** (₦1,200): Gentle, reliable paracetamol caplets for general fever and mild-to-moderate headache. Take 2 tablets every 8 hours after food with water.\n\n"
            "${doctorMatch != null ? "For clinical evaluation of your headache symptoms, I have matched you with **${doctorMatch.name}**, our **${doctorMatch.title}**. He is **Available Now** for an instant audio or video consultation.\n\n" : ""}"
            "Please rest in a quiet, dimly lit room and stay well-hydrated. If your headache is extraordinarily sudden and severe, or accompanied by neck stiffness, high fever, or vision blur, seek immediate hospital emergency care.",
        isFromUser: false,
        timestamp: DateTime.now(),
        priority: TriagePriority.normal,
        clinicalNotes: 'Headache Analgesic Protocol & Clinical Triage Applied • PCN Formulary.',
        vitalsSnapshot: null,
        recommendedProducts: headacheProducts,
        recommendedDoctor: doctorMatch,
      );
    }

    // 4. Price comparison ("Which among these drugs is the cheapest?")
    if (lower.contains('cheapest') ||
        lower.contains('cheaper') ||
        lower.contains('lowest price') ||
        lower.contains('most affordable') ||
        (lower.contains('cheap') && lower.contains('drug'))) {
      return ConsultationMessageEntity(
        id: 'msg-${_uuid.v4().substring(0, 6)}',
        text:
            "Here is the cost breakdown from our current ComfortCare Abuja inventory:\n\n"
            "• **Emzor Paracetamol 500mg** (₦1,200) – Our most affordable medication, providing 100 caplets for fever, headache, and pain relief.\n"
            "• **ORS Hydration + Zinc** (₦1,400) – Essential fluid & electrolyte recovery.\n"
            "• **CareStart Malaria RDT** (₦1,800) – Low-cost rapid diagnostic testing.\n"
            "• **Panadol Extra** (₦1,850) – Fast-acting enhanced analgesic.\n"
            "• **Amoxil 500mg** (₦3,600) – First-line broad-spectrum antibiotic.\n"
            "• **Coartem 80/480mg** (₦4,200) – WHO gold-standard ACT anti-malarial course.\n\n"
            "For healthcare facilities and wholesale buyers, bulk carton pricing offers up to 20% additional savings.",
        isFromUser: false,
        timestamp: DateTime.now(),
        priority: TriagePriority.normal,
        clinicalNotes: 'Pharmaceutical Price Comparison Protocol • ComfortCare Abuja Formulary.',
        vitalsSnapshot: _currentVitals,
        recommendedProducts: _pickRelevantProducts('cheapest paracetamol ors coartem'),
      );
    }

    // 5. Clinical efficacy ("Which of these drugs works best?")
    if (lower.contains('works best') ||
        lower.contains('which works best') ||
        lower.contains('best drug') ||
        lower.contains('most effective')) {
      return ConsultationMessageEntity(
        id: 'msg-${_uuid.v4().substring(0, 6)}',
        text:
            "Clinical Efficacy & Pharmacological Evaluation:\n\n"
            "• **For Malaria**: **Coartem 80/480mg** (Artemether + Lumefantrine) is the PCN & WHO gold standard first-line ACT with >97% parasite clearance rate within 72 hours.\n"
            "• **For Rapid Pain Relief**: **Panadol Extra** (Paracetamol + Caffeine) works faster than standard paracetamol because caffeine accelerates gastric absorption and potentiates analgesic effect by ~40%.\n"
            "• **For Resistant Bacterial Infections**: **Augmentin 625mg** (Amoxicillin + Clavulanate) is superior to standard amoxicillin alone because clavulanic acid blocks bacterial beta-lactamase resistance.\n\n"
            "The choice of what works best depends on your specific diagnosis. We always recommend confirming with our pharmacist or taking a rapid diagnostic test first.",
        isFromUser: false,
        timestamp: DateTime.now(),
        priority: TriagePriority.normal,
        clinicalNotes: 'Clinical Pharmacodynamics & Efficacy Guideline Applied.',
        vitalsSnapshot: _currentVitals,
        recommendedProducts: _pickRelevantProducts('coartem panadol augmentin'),
      );
    }

    // 6. Unstocked brand inquiries & Equivalent substitute recommendations
    final unstockedQueries = [
      'amatem',
      'lonart',
      'cataflam',
      'boska',
      'ampiclox',
      'fleming',
      'curam',
      'felden',
      'feldene',
      'tylenol',
      'humulin',
      'lantus',
      'lokmal',
      'p-alaxin',
    ];

    final matchedUnstocked = unstockedQueries.firstWhere(
      (brand) => lower.contains(brand),
      orElse: () => '',
    );

    if (matchedUnstocked.isNotEmpty) {
      final catalog = ProductsRemoteDataSourceImpl.inMemoryProducts;
      final matchingCatalog = catalog.where((p) {
        return p.equivalentDrugs.toLowerCase().contains(matchedUnstocked) ||
            p.indications.toLowerCase().contains(matchedUnstocked) ||
            p.name.toLowerCase().contains(matchedUnstocked);
      }).toList();

      final substitute = matchingCatalog.isNotEmpty ? matchingCatalog.first : catalog.first;
      final brandCapitalized = matchedUnstocked[0].toUpperCase() + matchedUnstocked.substring(1);

      return ConsultationMessageEntity(
        id: 'msg-${_uuid.v4().substring(0, 6)}',
        text:
            "We do not currently have **$brandCapitalized** in stock, but we have **${substitute.name}** (₦${substitute.price.toInt()}) by ${substitute.brand}.\n\n"
            "• **Therapeutic Purpose**: ${substitute.indications}\n"
            "• **Equivalent Clinical Action**: Contains matching active ingredients (${substitute.activeIngredients}) and provides the same therapeutic effect.\n"
            "• **Dosage**: ${substitute.dosageInstructions}",
        isFromUser: false,
        timestamp: DateTime.now(),
        priority: TriagePriority.normal,
        clinicalNotes: 'Formulary Drug Substitution Protocol: Equivalent molecule matched.',
        vitalsSnapshot: _currentVitals,
        recommendedProducts: [substitute],
      );
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

    final products = _pickRelevantProducts(lower);
    final doctor = _pickRelevantDoctor(lower);
    final hasClinicalSymptoms = lower.contains('pain') ||
        lower.contains('ache') ||
        lower.contains('fever') ||
        lower.contains('malaria') ||
        lower.contains('cough') ||
        lower.contains('infection') ||
        lower.contains('bleed') ||
        lower.contains('vomit') ||
        lower.contains('swelling') ||
        lower.contains('fracture') ||
        lower.contains('frature') ||
        lower.contains('injury') ||
        lower.contains('wound') ||
        lower.contains('stomach') ||
        lower.contains('diarrhea') ||
        lower.contains('diabetes') ||
        lower.contains('burn') ||
        lower.contains('cold') ||
        lower.contains('dizzy') ||
        lower.contains('headache') ||
        lower.contains('stiff') ||
        lower.contains('fluid') ||
        lower.contains('leg');

    if (!hasClinicalSymptoms && products.isEmpty && doctor == null) {
      return ConsultationMessageEntity(
        id: 'msg-${_uuid.v4().substring(0, 6)}',
        text:
            "I am Dr. Comfort, your AI Clinical Pharmacist at ComfortCare Pharmaceuticals Abuja. How may I assist you today? You can share any symptoms you are experiencing, ask about medications, or request a consultation with one of our on-call specialists.",
        isFromUser: false,
        timestamp: DateTime.now(),
        priority: TriagePriority.normal,
        clinicalNotes: 'General Telehealth Inquiry Intake.',
        vitalsSnapshot: null,
        recommendedProducts: const [],
        recommendedDoctor: null,
      );
    }

    return ConsultationMessageEntity(
      id: 'msg-${_uuid.v4().substring(0, 6)}',
      text:
          "Thank you for sharing your health inquiry regarding '$text'. I have evaluated your inquiry against our clinical pharmacology database and regional health standards. Here is your personalized guidance.",
      isFromUser: false,
      timestamp: DateTime.now(),
      priority: TriagePriority.normal,
      vitalsSnapshot: (lower.contains('bp') || lower.contains('pressure') || lower.contains('vital'))
          ? _currentVitals
          : null,
      recommendedProducts: products,
      recommendedDoctor: doctor,
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

  List<ProductModel> _pickRelevantProducts(String query, {String? aiResponse}) {
    final lower = query.toLowerCase().trim();

    // 1. Pure social queries or greetings without symptoms shouldn't return product cards
    final isPureGreetingOrSocial = (lower == 'hello' ||
        lower == 'hi' ||
        lower == 'hey' ||
        lower == 'good morning' ||
        lower == 'good afternoon' ||
        lower == 'good evening' ||
        lower == 'greetings' ||
        lower == 'thank you' ||
        lower == 'thanks' ||
        lower == 'ok' ||
        lower == 'okay' ||
        lower == 'alright' ||
        lower == 'got it' ||
        lower == 'goodbye' ||
        lower == 'bye' ||
        lower.contains('what is your name') ||
        lower.contains('who are you') ||
        lower.contains('how are you')) &&
        !lower.contains('headache') &&
        !lower.contains('pain') &&
        !lower.contains('fever') &&
        !lower.contains('malaria') &&
        !lower.contains('medics') &&
        !lower.contains('medicine');

    if (isPureGreetingOrSocial) {
      return const [];
    }

    final catalog = ProductsRemoteDataSourceImpl.inMemoryProducts;

    // 2. If Gemini provided an aiResponse, extract catalog products specifically recommended in the text!
    if (aiResponse != null && aiResponse.trim().isNotEmpty) {
      final aiLower = aiResponse.toLowerCase();
      final mentioned = <ProductModel>[];

      for (final prod in catalog) {
        final id = prod.id;
        bool isMentioned = false;

        if (id == 'prod-panadol-extra') {
          isMentioned = aiLower.contains('panadol extra') || aiLower.contains('panadol');
        } else if (id == 'prod-emzor-paracetamol') {
          isMentioned = aiLower.contains('emzor paracetamol') ||
              aiLower.contains('paracetamol 500mg') ||
              (aiLower.contains('emzor') && aiLower.contains('paracetamol'));
        } else if (id == 'prod-coartem-80-480') {
          isMentioned = aiLower.contains('coartem');
        } else if (id == 'prod-carestart-rdt') {
          isMentioned = aiLower.contains('carestart') || aiLower.contains('malaria rdt');
        } else if (id == 'prod-ors-zinc') {
          isMentioned = aiLower.contains('ors hydration') || aiLower.contains('oral rehydration');
        } else if (id == 'prod-osteocare-vitabiotics') {
          isMentioned = aiLower.contains('osteocare');
        } else if (id == 'prod-deep-heat-rub') {
          isMentioned = aiLower.contains('deep heat');
        } else if (id == 'prod-neurobion-forte') {
          isMentioned = aiLower.contains('neurobion');
        } else if (id == 'prod-amoxil-500') {
          isMentioned = aiLower.contains('amoxil');
        } else if (id == 'prod-augmentin-625') {
          isMentioned = aiLower.contains('augmentin');
        } else if (id == 'prod-omron-m2') {
          isMentioned = aiLower.contains('omron') || aiLower.contains('blood pressure monitor');
        } else if (id == 'prod-insulin-mixtard') {
          isMentioned = aiLower.contains('mixtard') || aiLower.contains('insulin');
        } else {
          isMentioned = aiLower.contains(prod.name.toLowerCase());
        }

        if (isMentioned) {
          mentioned.add(prod);
        }
      }

      if (mentioned.isNotEmpty) {
        return mentioned;
      }
    }

    // 3. Bone fracture recovery, leg stiffness, and physical rehabilitation accompanied products
    final isFractureRecovery = lower.contains('fracture') ||
        lower.contains('frature') ||
        (lower.contains('leg') &&
            (lower.contains('fluid') ||
                lower.contains('fluidly') ||
                lower.contains('stiff') ||
                lower.contains('walk') ||
                lower.contains('mov'))) ||
        ((lower.contains('therapist') ||
                lower.contains('terapist') ||
                lower.contains('physio')) &&
            (lower.contains('leg') ||
                lower.contains('bone') ||
                lower.contains('injur') ||
                lower.contains('stiff')));

    if (isFractureRecovery) {
      return catalog.where((p) {
        final id = p.id;
        return id == 'prod-osteocare-vitabiotics' ||
            id == 'prod-deep-heat-rub' ||
            id == 'prod-neurobion-forte' ||
            id == 'prod-emzor-paracetamol';
      }).toList();
    }

    // 4. Stop-words filter to prevent spurious matches (like "and", "need", "quick")
    const stopWords = {
      'the', 'and', 'for', 'are', 'you', 'was', 'with', 'have', 'having', 'has', 'had',
      'that', 'this', 'need', 'needs', 'needed', 'want', 'wants', 'tell', 'talk', 'give',
      'quick', 'fast', 'slow', 'some', 'any', 'can', 'could', 'should', 'would', 'will',
      'about', 'from', 'into', 'what', 'which', 'when', 'where', 'who', 'how', 'why',
      'all', 'both', 'each', 'more', 'most', 'other', 'such', 'than', 'too', 'very',
      'just', 'also', 'reliefe', 'relief', 'medics', 'medic', 'medicine', 'medicines',
      'drug', 'drugs', 'please', 'help', 'feel', 'feeling', 'like', 'consultant', 'doctor',
      'specialist', 'physician', 'joel', 'lee', 'hello', 'there',
    };

    final scored = <MapEntry<ProductModel, int>>[];
    final terms = lower
        .split(RegExp(r'[\s,?.!]+'))
        .where((t) => t.length > 2 && !stopWords.contains(t))
        .toList();

    for (final prod in catalog) {
      int score = 0;
      final nameLower = prod.name.toLowerCase();
      final indicationsLower = prod.indications.toLowerCase();
      final equivalentsLower = prod.equivalentDrugs.toLowerCase();
      final categoryLower = prod.category.toLowerCase();
      final descLower = prod.description.toLowerCase();
      final genericLower = prod.genericName.toLowerCase();

      // Direct full query substring match
      if (indicationsLower.contains(lower) && lower.length > 3) score += 12;
      if (equivalentsLower.contains(lower) && lower.length > 3) score += 12;
      if (nameLower.contains(lower) && lower.length > 3) score += 12;

      // Token matches
      for (final term in terms) {
        if (nameLower.contains(term)) score += 8;
        if (indicationsLower.contains(term)) score += 6;
        if (equivalentsLower.contains(term)) score += 5;
        if (categoryLower.contains(term)) score += 3;
        if (genericLower.contains(term)) score += 3;
        if (descLower.contains(term)) score += 2;
      }

      // Semantic keyword boosts
      if ((lower.contains('malaria') || lower.contains('mosquito') || lower.contains('chills') || lower.contains('amatem') || lower.contains('lonart')) &&
          (nameLower.contains('coartem') || nameLower.contains('carestart'))) {
        score += 10;
      }
      if ((lower.contains('headache') || lower.contains('migraine') || lower.contains('head ache') || lower.contains('fever') || lower.contains('body pain') || lower.contains('cataflam') || lower.contains('panadol')) &&
          (nameLower.contains('paracetamol') || nameLower.contains('panadol'))) {
        score += 15;
      }
      if ((lower.contains('bone') || lower.contains('calcium') || lower.contains('osteoporosis') || lower.contains('fracture')) &&
          nameLower.contains('osteocare')) {
        score += 15;
      }
      if ((lower.contains('rub') || lower.contains('heat') || lower.contains('stiff') || lower.contains('sprain') || lower.contains('muscle pain')) &&
          nameLower.contains('deep heat')) {
        score += 15;
      }
      if ((lower.contains('nerve') || lower.contains('neuro') || lower.contains('b-complex') || lower.contains('tingling') || lower.contains('numbness')) &&
          nameLower.contains('neurobion')) {
        score += 15;
      }
      if ((lower.contains('cheapest') || lower.contains('cheap') || lower.contains('affordable')) &&
          (prod.price <= 2000.0)) {
        score += 6;
      }
      if ((lower.contains('works best') || lower.contains('best') || lower.contains('effective')) &&
          (nameLower.contains('coartem') || nameLower.contains('augmentin') || nameLower.contains('panadol'))) {
        score += 6;
      }
      if ((lower.contains('sugar') || lower.contains('diabetes') || lower.contains('insulin')) &&
          nameLower.contains('insulin')) {
        score += 10;
      }
      if ((lower.contains('bp') || lower.contains('pressure') || lower.contains('hypertension')) &&
          nameLower.contains('omron')) {
        score += 10;
      }
      if ((lower.contains('infection') || lower.contains('cough') || lower.contains('antibiotic') || lower.contains('augmentin') || lower.contains('amoxil')) &&
          (nameLower.contains('augmentin') || nameLower.contains('amoxil'))) {
        score += 8;
      }

      if (score >= 6) {
        scored.add(MapEntry(prod, score));
      }
    }

    scored.sort((a, b) => b.value.compareTo(a.value));

    if (scored.isNotEmpty) {
      return scored.take(4).map((e) => e.key).toList();
    }

    // Do NOT return fallback medications by default if no clinical indication was matched
    return const [];
  }

  DoctorEntity? _pickRelevantDoctor(String query, {String? aiResponse}) {
    final lower = query.toLowerCase().trim();

    // 1. Never recommend doctor on pure social greetings, politeness, or general app queries
    // unless the query explicitly asks for a doctor / consultant
    final isSimpleOrSocial = (lower == 'hello' ||
        lower == 'hi' ||
        lower == 'hey' ||
        lower == 'good morning' ||
        lower == 'good afternoon' ||
        lower == 'good evening' ||
        lower == 'greetings' ||
        lower == 'thank you' ||
        lower == 'thanks' ||
        lower == 'ok' ||
        lower == 'okay' ||
        lower == 'alright' ||
        lower == 'got it' ||
        lower == 'goodbye' ||
        lower == 'bye' ||
        lower.contains('what is your name') ||
        lower.contains('who are you') ||
        lower.contains('how are you') ||
        (lower.contains('cheapest') &&
            !lower.contains('pain') &&
            !lower.contains('fever') &&
            !lower.contains('fracture'))) &&
        !lower.contains('doctor') &&
        !lower.contains('consultant') &&
        !lower.contains('specialist') &&
        !lower.contains('talk to') &&
        !lower.contains('physician');

    if (isSimpleOrSocial) {
      return null;
    }

    final doctors = ConsultantsRemoteDataSourceImpl.inMemoryDoctors;

    // 2. If Gemini provided an aiResponse, check if it explicitly mentions any in-memory doctor!
    if (aiResponse != null && aiResponse.trim().isNotEmpty) {
      final aiLower = aiResponse.toLowerCase();
      for (final doc in doctors) {
        final docNameLower = doc.name.toLowerCase();
        if (aiLower.contains(docNameLower) ||
            (docNameLower.contains('chinedu') && aiLower.contains('chinedu')) ||
            (docNameLower.contains('bello') && aiLower.contains('bello')) ||
            (docNameLower.contains('usman') && aiLower.contains('usman')) ||
            (docNameLower.contains('okafor') && aiLower.contains('okafor')) ||
            (docNameLower.contains('danjuma') && aiLower.contains('danjuma')) ||
            (docNameLower.contains('nwosu') && aiLower.contains('nwosu')) ||
            (docNameLower.contains('ighodaro') && aiLower.contains('ighodaro')) ||
            (docNameLower.contains('al-hassan') && (aiLower.contains('fatima') || aiLower.contains('al-hassan'))) ||
            (docNameLower.contains('adewale') && aiLower.contains('adewale'))) {
          return doc;
        }
      }
    }

    // 3. Clinical Psychology & Psychotherapy (Mental coping, trauma, anxiety, depression)
    if (lower.contains('psycho') ||
        lower.contains('psychology') ||
        lower.contains('psychotherapist') ||
        lower.contains('mental') ||
        lower.contains('trauma') ||
        lower.contains('anxiety') ||
        lower.contains('counsel') ||
        lower.contains('kinesiophobia') ||
        lower.contains('cbt')) {
      final match = doctors.firstWhere((d) => d.id == 'doc-fatima-al-hassan' && d.isAvailable,
          orElse: () => doctors.firstWhere((d) => d.id == 'doc-fatima-al-hassan'));
      return match;
    }

    // 4. Physiotherapy & Physical Rehabilitation (Fracture recovery, gait, leg mobility, stiffness)
    if (lower.contains('physio') ||
        lower.contains('physical therap') ||
        lower.contains('mobility') ||
        lower.contains('fluidly') ||
        lower.contains('fluid') ||
        lower.contains('gait') ||
        lower.contains('rehab') ||
        lower.contains('stiff') ||
        lower.contains('fracture') ||
        lower.contains('frature') ||
        (lower.contains('terapist') || lower.contains('therapist')) ||
        (lower.contains('leg') && (lower.contains('walk') || lower.contains('mov') || lower.contains('injur')))) {
      final match = doctors.firstWhere((d) => d.id == 'doc-osas-ighodaro' && d.isAvailable,
          orElse: () => doctors.firstWhere((d) => d.id == 'doc-osas-ighodaro'));
      return match;
    }

    // 5. Orthopedic & Trauma Surgery (X-rays, cast, bone breaks, surgical review)
    if (lower.contains('orthopedic') ||
        lower.contains('orthopaedic') ||
        lower.contains('surgeon') ||
        lower.contains('bone break') ||
        lower.contains('cast') ||
        lower.contains('x-ray') ||
        lower.contains('radiograph')) {
      final match = doctors.firstWhere((d) => d.id == 'doc-kelechi-nwosu' && d.isAvailable,
          orElse: () => doctors.firstWhere((d) => d.id == 'doc-kelechi-nwosu'));
      return match;
    }

    // 6. Cardiovascular & Internal Medicine (Hypertension, chest pain, BP)
    if (lower.contains('bp') ||
        lower.contains('pressure') ||
        lower.contains('chest') ||
        lower.contains('heart') ||
        lower.contains('hypertension') ||
        lower.contains('palpitation')) {
      return doctors.firstWhere((d) => d.id == 'doc-amina-bello' && d.isAvailable,
          orElse: () => doctors.firstWhere((d) => d.id == 'doc-amina-bello'));
    }

    // 7. Pediatrics & Child Health
    if (lower.contains('child') ||
        lower.contains('baby') ||
        lower.contains('kid') ||
        lower.contains('infant') ||
        lower.contains('toddler') ||
        lower.contains('pediatric')) {
      return doctors.firstWhere((d) => d.id == 'doc-zainab-usman' && d.isAvailable,
          orElse: () => doctors.firstWhere((d) => d.id == 'doc-zainab-usman'));
    }

    // 8. Endocrinology & Diabetes
    if (lower.contains('diabetes') ||
        lower.contains('sugar') ||
        lower.contains('insulin')) {
      return doctors.firstWhere((d) => d.id == 'doc-emeka-okafor');
    }

    // 9. Obstetrics & Maternal Health
    if (lower.contains('pregnant') ||
        lower.contains('pregnancy') ||
        lower.contains('period') ||
        lower.contains('antenatal') ||
        lower.contains('woman') ||
        lower.contains('female') ||
        lower.contains('maternal')) {
      return doctors.firstWhere((d) => d.id == 'doc-halima-danjuma' && d.isAvailable,
          orElse: () => doctors.firstWhere((d) => d.id == 'doc-halima-danjuma'));
    }

    // 10. Clinical Pharmacology & Medication Review
    if (lower.contains('interaction') ||
        lower.contains('side effect') ||
        lower.contains('polypharmacy') ||
        lower.contains('dosage') ||
        lower.contains('swap') ||
        lower.contains('contraindication')) {
      return doctors.firstWhere((d) => d.id == 'doc-pharm-tunde-adewale' && d.isAvailable,
          orElse: () => doctors.firstWhere((d) => d.id == 'doc-pharm-tunde-adewale'));
    }

    // 11. Acute General Medicine, Headache, Migraine, Fever, Malaria, Infectious Diseases
    if (lower.contains('headache') ||
        lower.contains('migraine') ||
        lower.contains('head ache') ||
        lower.contains('malaria') ||
        lower.contains('fever') ||
        lower.contains('chills') ||
        lower.contains('typhoid') ||
        lower.contains('cough') ||
        lower.contains('infection') ||
        lower.contains('antibiotic')) {
      return doctors.firstWhere((d) => d.id == 'doc-chinedu-eze' && d.isAvailable,
          orElse: () => doctors.firstWhere((d) => d.id == 'doc-chinedu-eze'));
    }

    // 12. Explicit request for consultant / doctor / specialist / someone to talk to
    if (lower.contains('consultant') ||
        lower.contains('doctor') ||
        lower.contains('physician') ||
        lower.contains('specialist') ||
        (lower.contains('talk to') && !lower.contains('bot'))) {
      return doctors.firstWhere((d) => d.id == 'doc-chinedu-eze' && d.isAvailable,
          orElse: () => doctors.firstWhere((d) => d.id == 'doc-chinedu-eze'));
    }

    // If query does not require an on-call medical specialist, do NOT recommend one:
    return null;
  }
}
