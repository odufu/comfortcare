import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:comfort_care/features/consultants/data/datasources/consultants_remote_datasource.dart';
import 'package:comfort_care/features/consultants/data/models/doctor_model.dart';
import 'package:comfort_care/features/consultants/presentation/pages/consultants_directory_page.dart';
import 'package:comfort_care/features/consultants/presentation/pages/doctor_console_page.dart';
import 'package:comfort_care/features/clinical/data/datasources/clinical_remote_datasource.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _kTransparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
      {void Function()? onDone, Function? onError, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
      onData,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  }
}

final _kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });
  group('Medical Consultancy & Doctor Domain Tests', () {
    final sampleDoctor = DoctorModel(
      id: 'doc-test-01',
      name: 'Dr. Test Specialist',
      title: 'Consultant Cardiologist',
      licenseNumber: 'MDCN-12345-TEST',
      specialty: 'Cardiology & Internal Medicine',
      qualifications: 'MBBS, FMCP',
      hospital: 'National Hospital Abuja',
      avatarUrl: 'https://example.com/avatar.jpg',
      bio: 'Expert cardiologist in hypertension and heart health.',
      consultationFee: 8000.0,
      rating: 4.9,
      reviewCount: 45,
      isAvailable: true,
      supportsVideo: true,
      supportsAudio: true,
      yearsOfExperience: 12,
      specializations: const ['Cardiology', 'Hypertension', 'Chest Pain'],
    );

    test('DoctorModel serializes and deserializes to/from JSON correctly', () {
      final json = sampleDoctor.toJson();
      expect(json['id'], 'doc-test-01');
      expect(json['name'], 'Dr. Test Specialist');
      expect(json['license_number'], 'MDCN-12345-TEST');
      expect(json['consultation_fee'], 8000.0);
      expect(json['specializations'], contains('Hypertension'));

      final fromJson = DoctorModel.fromJson(json);
      expect(fromJson.id, sampleDoctor.id);
      expect(fromJson.name, sampleDoctor.name);
      expect(fromJson.licenseNumber, sampleDoctor.licenseNumber);
      expect(fromJson.consultationFee, sampleDoctor.consultationFee);
      expect(fromJson.rating, sampleDoctor.rating);
    });

    test('DoctorModel fromEntity retains all clinical metadata', () {
      final model = DoctorModel.fromEntity(sampleDoctor);
      expect(model.id, sampleDoctor.id);
      expect(model.specialty, 'Cardiology & Internal Medicine');
      expect(model.hospital, 'National Hospital Abuja');
      expect(model.supportsVideo, isTrue);
      expect(model.supportsAudio, isTrue);
    });
  });

  group('Consultants Remote DataSource & Matching Algorithm Tests', () {
    late ConsultantsRemoteDataSource dataSource;

    setUp(() {
      dataSource = ConsultantsRemoteDataSourceImpl();
    });

    test('getDoctors returns initial seeded Abuja specialists', () async {
      final doctors = await dataSource.getDoctors();
      expect(doctors.isNotEmpty, isTrue);
      expect(doctors.length, greaterThanOrEqualTo(6));
      expect(doctors.any((d) => d.name == 'Dr. Chinedu Eze'), isTrue);
      expect(doctors.any((d) => d.name == 'Dr. Amina Bello'), isTrue);
    });

    test('getDoctors filters accurately by specialty and search query', () async {
      final pediatricians = await dataSource.getDoctors(specialty: 'Pediatrics & Child Health');
      expect(pediatricians.every((d) => d.specialty.contains('Pediatrics')), isTrue);

      final searchResults = await dataSource.getDoctors(query: 'Eze');
      expect(searchResults.length, 1);
      expect(searchResults.first.name, 'Dr. Chinedu Eze');
    });

    test('registerDoctor adds new specialist into directory with valid MDCN number', () async {
      const newDoc = DoctorModel(
        id: 'doc-new-registered',
        name: 'Dr. Kelechi Nwosu',
        title: 'Consultant Neurologist',
        licenseNumber: 'MDCN-99881-NEU',
        specialty: 'Neurology',
        qualifications: 'MBBS, FWACS (Neuro)',
        hospital: 'Cedarcrest Hospitals Abuja',
        avatarUrl: 'https://example.com/kelechi.jpg',
        bio: 'Consultant Neurologist dealing with migraines, stroke recovery, and epilepsy.',
        consultationFee: 9000.0,
        rating: 5.0,
        reviewCount: 0,
        isAvailable: true,
        supportsVideo: true,
        supportsAudio: true,
        specializations: ['Neurology', 'Migraine', 'Stroke'],
        yearsOfExperience: 10,
      );

      final registered = await dataSource.registerDoctor(newDoc);
      expect(registered.id, 'doc-new-registered');
      expect(registered.name, 'Dr. Kelechi Nwosu');

      final found = await dataSource.getDoctorById('doc-new-registered');
      expect(found, isNotNull);
      expect(found?.licenseNumber, 'MDCN-99881-NEU');
    });

    test('rateDoctor recalculates running average and updates review count', () async {
      final initialReviews = (await dataSource.getDoctorReviews('doc-chinedu-eze')).length;

      await dataSource.rateDoctor(
        doctorId: 'doc-chinedu-eze',
        rating: 5.0,
        comment: 'Very attentive doctor! Accurately diagnosed malaria.',
        patientName: 'Test Patient',
      );

      final updatedDoc = await dataSource.getDoctorById('doc-chinedu-eze');
      expect(updatedDoc!.reviewCount, initialReviews + 1);
      expect(updatedDoc.rating, inInclusiveRange(1.0, 5.0));

      final reviews = await dataSource.getDoctorReviews('doc-chinedu-eze');
      expect(reviews.any((r) => r.patientName == 'Test Patient'), isTrue);
    });

    test('updateDoctorAvailability updates on-call status for doctor console', () async {
      await dataSource.updateDoctorAvailability('doc-chinedu-eze', false, 'Offline');
      final offlineDoc = await dataSource.getDoctorById('doc-chinedu-eze');
      expect(offlineDoc?.isAvailable, isFalse);

      await dataSource.updateDoctorAvailability('doc-chinedu-eze', true, 'Available');
      final onlineDoc = await dataSource.getDoctorById('doc-chinedu-eze');
      expect(onlineDoc?.isAvailable, isTrue);
    });

    test('findBestMatchingDoctor matches clinical symptoms to the appropriate specialist', () async {
      // 1. Malaria / Fever symptom -> Dr. Chinedu Eze (Infectious Diseases)
      final malariaMatch = await dataSource.findBestMatchingDoctor('High grade fever, chills, and suspected severe malaria');
      expect(malariaMatch?.specialty.toLowerCase(), contains('infectious'));

      // 2. High Blood Pressure / Chest pain -> Dr. Amina Bello (Cardiology)
      final cardioMatch = await dataSource.findBestMatchingDoctor('My blood pressure is 160/100 and feeling chest tightness');
      expect(cardioMatch?.specialty.toLowerCase(), contains('cardio'));

      // 3. Child fever / Infant -> Dr. Zainab Usman (Pediatrics)
      final pediatricsMatch = await dataSource.findBestMatchingDoctor('My 3 year old toddler has hot body and refused breast milk');
      expect(pediatricsMatch?.specialty.toLowerCase(), contains('pediatric'));

      // 4. Diabetes / High Sugar -> Dr. Emeka Okafor (Endocrinology)
      final diabetesMatch = await dataSource.findBestMatchingDoctor('Fasting blood glucose spike 250 mg/dL need insulin adjustment');
      expect(diabetesMatch?.specialty.toLowerCase(), contains('endocrin'));

      // 5. Fracture recovery / leg not moving fluidly / gait rehabilitation -> Dr. Osas Ighodaro (Physiotherapy)
      final physioMatch = await dataSource.findBestMatchingDoctor('I am recovering from a fracture injury and my legs are not moving fluidly, need gait training');
      expect(physioMatch?.name, contains('Osas Ighodaro'));
      expect(physioMatch?.specialty.toLowerCase(), contains('physiotherapy'));
      expect(physioMatch?.isAvailable, isTrue);

      // 6. Injury trauma / mental coping / fear of movement -> Dr. Fatima Al-Hassan (Psychotherapy)
      final psychoMatch = await dataSource.findBestMatchingDoctor('Suffering from severe trauma, mental distress and fear of walking after my accident');
      expect(psychoMatch?.name, contains('Fatima Al-Hassan'));
      expect(psychoMatch?.specialty.toLowerCase(), contains('psychology'));
      expect(psychoMatch?.isAvailable, isTrue);
    });
  });

  group('AI Clinical Consultation Recommendation & Simple Response Policy Tests', () {
    late ClinicalRemoteDataSource clinicalDataSource;

    setUp(() {
      clinicalDataSource = ClinicalRemoteDataSourceImpl();
    });

    test('Simple greeting or social message returns simple response without unsolicited recommendations', () async {
      final greetingMsg = await clinicalDataSource.sendMessage('Hello');
      expect(greetingMsg.recommendedProducts, isEmpty);
      expect(greetingMsg.recommendedDoctor, isNull);
      expect(greetingMsg.vitalsSnapshot, isNull);

      final politeMsg = await clinicalDataSource.sendMessage('Thank you');
      expect(politeMsg.recommendedProducts, isEmpty);
      expect(politeMsg.recommendedDoctor, isNull);
      expect(politeMsg.vitalsSnapshot, isNull);

      final identityMsg = await clinicalDataSource.sendMessage('What is your name?');
      expect(identityMsg.recommendedProducts, isEmpty);
      expect(identityMsg.recommendedDoctor, isNull);
      expect(identityMsg.vitalsSnapshot, isNull);
    });

    test('Initial entry starts fresh session with user name in greeting and no default cards', () async {
      final initialHistory = await clinicalDataSource.getConsultationHistory(
        userName: 'Joel',
        forceNewSession: true,
      );

      // Verify exactly one clean welcoming message is returned
      expect(initialHistory.length, 1);
      final welcome = initialHistory.first;
      expect(welcome.isFromUser, isFalse);
      expect(welcome.text, contains('Hello Joel!'));
      expect(welcome.text, contains('Dr. Comfort'));
      expect(welcome.recommendedProducts, isEmpty);
      expect(welcome.recommendedDoctor, isNull);
      expect(welcome.vitalsSnapshot, isNull);
    });

    test('Fracture recovery query explains psychotherapy & physiotherapy, suggests available therapist, and accompanied medications', () async {
      final query = 'I am recovering from a fracture injury, and I need psychotherapists, because my legs are not moving fluidly';
      final response = await clinicalDataSource.sendMessage(query);

      // 1. Text must cover psychotherapy basics in fracture context and fluid physical mechanics
      expect(response.text.toLowerCase(), contains('psychotherapy'));
      expect(response.text.toLowerCase(), contains('physiotherapy'));
      expect(response.text.toLowerCase(), contains('kinesiophobia'));

      // 2. Doctor recommended must be available now
      expect(response.recommendedDoctor, isNotNull);
      expect(response.recommendedDoctor!.isAvailable, isTrue);
      expect(response.recommendedDoctor!.availabilityStatus, contains('Available'));

      // 3. Accompanied medications must be provided
      expect(response.recommendedProducts, isNotNull);
      expect(response.recommendedProducts, isNotEmpty);
      final productNames = response.recommendedProducts!.map((p) => p.name.toLowerCase()).toList();
      expect(productNames.any((n) => n.contains('osteocare')), isTrue);
      expect(productNames.any((n) => n.contains('deep heat')), isTrue);
      expect(productNames.any((n) => n.contains('neurobion')), isTrue);
      expect(productNames.any((n) => n.contains('paracetamol')), isTrue);
    });

    test('Dual recommendation query (headache + medics + consultant) returns both drugs and on-call doctor cards', () async {
      final query = 'i am joel Lee. i am having a headache. i need a quick reliefe medics and a consultant to talk to';
      final response = await clinicalDataSource.sendMessage(query);

      // 1. Both recommended products and recommended doctor must be present
      expect(response.recommendedProducts, isNotNull);
      expect(response.recommendedProducts, isNotEmpty);
      expect(response.recommendedDoctor, isNotNull);

      // 2. Recommended doctor must be available and appropriate for headache / general acute care
      expect(response.recommendedDoctor!.id, 'doc-chinedu-eze');
      expect(response.recommendedDoctor!.isAvailable, isTrue);
      expect(response.recommendedDoctor!.name, contains('Chinedu Eze'));

      // 3. Recommended drugs must be headache/pain relievers, NOT unrelated medications
      final productNames = response.recommendedProducts!.map((p) => p.name.toLowerCase()).toList();
      expect(productNames.any((n) => n.contains('panadol') || n.contains('paracetamol')), isTrue);
      expect(productNames.any((n) => n.contains('osteocare')), isFalse);
      expect(productNames.any((n) => n.contains('coartem')), isFalse);

      // 4. Products must have explicit dosage and interval instructions
      for (final prod in response.recommendedProducts!) {
        expect(prod.dosageInstructions, isNotEmpty);
        expect(prod.dosageInstructions.toLowerCase(), contains('tablets'));
        expect(prod.dosageInstructions.toLowerCase(), contains('hours'));
      }
    });
  });

  group('Consultancy & Telehealth Widget Rendering Tests', () {
    testWidgets('ConsultantsDirectoryPage renders search, filters, and specialist cards', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));

      await tester.pumpWidget(
        const MaterialApp(
          home: ConsultantsDirectoryPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title & register action
      expect(find.text('ComfortCare Doctors & Specialists'), findsOneWidget);
      expect(find.text('Doctor Join'), findsOneWidget);

      // Verify category tabs
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Infectious Diseases'), findsOneWidget);
      expect(find.text('Pediatrics'), findsOneWidget);
      expect(find.text('Cardiovascular'), findsOneWidget);

      // Verify doctor card exists
      expect(find.text('Dr. Chinedu Eze'), findsOneWidget);
    });

    testWidgets('DoctorConsolePage renders online availability toggle and patient queue', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));

      await tester.pumpWidget(
        const MaterialApp(
          home: DoctorConsolePage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title
      expect(find.text('Doctor Clinical Console'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('Status: Accepting Consultations'), findsOneWidget);

      // Verify Queue header & metrics
      expect(find.text('Live Waiting Queue'), findsOneWidget);
    });
  });
}
