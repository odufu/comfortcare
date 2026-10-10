import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../domain/entities/consultant_review_entity.dart';
import '../../domain/entities/consultation_session_entity.dart';
import '../models/doctor_model.dart';

abstract class ConsultantsRemoteDataSource {
  Future<List<DoctorModel>> getDoctors({
    String? specialty,
    String? query,
    bool onlyAvailable = false,
  });

  Future<DoctorModel?> getDoctorById(String id);
  Future<DoctorModel> registerDoctor(DoctorModel doctor);
  Future<DoctorModel> updateDoctorAvailability(String doctorId, bool isAvailable, String status);
  Future<void> rateDoctor({
    required String doctorId,
    required double rating,
    required String comment,
    required String patientName,
    String consultationType = 'Video Call',
  });

  Future<List<ConsultantReviewEntity>> getDoctorReviews(String doctorId);
  Future<ConsultationSessionEntity> createSession(ConsultationSessionEntity session);
  Future<List<ConsultationSessionEntity>> getSessionsForDoctor(String doctorId);
  Future<void> completeSession(String sessionId, {String? notes, double? rating, String? review});
  Future<DoctorModel?> findBestMatchingDoctor(String symptomsOrQuery);
  Future<List<DoctorModel>> getPendingConsultants();
  Future<DoctorModel> approveConsultant(String doctorId);
  Future<DoctorModel> rejectConsultant(String doctorId, {String? reason});
}

class ConsultantsRemoteDataSourceImpl implements ConsultantsRemoteDataSource {
  final _uuid = const Uuid();

  static final List<DoctorModel> _mockDoctors = [
    DoctorModel(
      id: 'doc-chinedu-eze',
      name: 'Dr. Chinedu Eze',
      title: 'Consultant Physician & Infectious Disease Specialist',
      specialty: 'Infectious Diseases & General Medicine',
      licenseNumber: 'MDCN Reg. #48291',
      qualifications: 'MBBS, FWACS, MSc Clinical Tropical Medicine',
      yearsOfExperience: 14,
      hospital: 'National Hospital Abuja / ComfortCare Health Hub',
      consultationFee: 6500.0,
      rating: 4.95,
      reviewCount: 142,
      isAvailable: true,
      availabilityStatus: 'Available Now',
      specializations: const [
        'Malaria',
        'Severe Fever',
        'Typhoid',
        'Chills',
        'Bacterial Infections',
        'Respiratory Illness',
        'Antibiotic Stewardship',
        'Headache',
      ],
      avatarUrl:
          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&auto=format&fit=crop&q=80',
      bio:
          'Senior consultant physician in acute infectious diseases, endemic fever management, and antimicrobial therapy with over 14 years clinical experience across Abuja federal medical centres.',
      nextAvailableSlot: 'Instant (under 2 mins)',
      supportsVideo: true,
      supportsAudio: true,
    ),
    DoctorModel(
      id: 'doc-amina-bello',
      name: 'Dr. Amina Bello',
      title: 'Consultant Cardiologist & Hypertension Lead',
      specialty: 'Cardiovascular & Internal Medicine',
      licenseNumber: 'MDCN Reg. #51902',
      qualifications: 'MBBS, FMCPath, Dip. Cardiology (London)',
      yearsOfExperience: 16,
      hospital: 'Garki Hospital Area 8, Abuja',
      consultationFee: 8500.0,
      rating: 4.98,
      reviewCount: 215,
      isAvailable: true,
      availabilityStatus: 'Available Now',
      specializations: const [
        'Hypertension',
        'Blood Pressure Monitoring',
        'Chest Pain',
        'Palpitations',
        'Heart Health',
        'Cardiovascular Risk',
        'Lipid Profile',
        'ECG Interpretation',
      ],
      avatarUrl:
          'https://images.unsplash.com/photo-1594824813572-c288bdf21469?w=400&auto=format&fit=crop&q=80',
      bio:
          'Fellow of the West African College of Physicians specializing in preventive cardiology, telemetric blood pressure optimization, and arterial vascular health.',
      nextAvailableSlot: 'Instant (under 4 mins)',
      supportsVideo: true,
      supportsAudio: true,
    ),
    DoctorModel(
      id: 'doc-zainab-usman',
      name: 'Dr. Zainab Usman',
      title: 'Consultant Pediatrician & Neonatologist',
      specialty: 'Pediatrics & Child Health',
      licenseNumber: 'MDCN Reg. #56312',
      qualifications: 'MBBS, FWACP (Pediatrics), MPH',
      yearsOfExperience: 11,
      hospital: 'Nizamiye Hospital / Wuse District Hospital',
      consultationFee: 7000.0,
      rating: 4.92,
      reviewCount: 98,
      isAvailable: true,
      availabilityStatus: 'Available Now',
      specializations: const [
        'Pediatric Fever',
        'Infant Nutrition',
        'Child Diarrhea & Dehydration',
        'Vaccination Advisory',
        'Cough & Cold in Toddlers',
        'Pediatric Asthma',
      ],
      avatarUrl:
          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&auto=format&fit=crop&q=80',
      bio:
          'Passionate pediatrician committed to accessible telehealth care for mothers and children, neonatal health guidance, and pediatric dosage calibration.',
      nextAvailableSlot: 'Available Now',
      supportsVideo: true,
      supportsAudio: true,
    ),
    DoctorModel(
      id: 'doc-emeka-okafor',
      name: 'Dr. Emeka Okafor',
      title: 'Consultant Endocrinologist & Diabetologist',
      specialty: 'Endocrinology & Diabetes',
      licenseNumber: 'MDCN Reg. #49104',
      qualifications: 'MBBS, FWACP, FACE',
      yearsOfExperience: 13,
      hospital: 'Cedarcrest Hospitals Apo, Abuja',
      consultationFee: 8000.0,
      rating: 4.88,
      reviewCount: 76,
      isAvailable: false,
      availabilityStatus: 'In Consultation',
      specializations: const [
        'Diabetes Mellitus',
        'High Blood Sugar',
        'Insulin Titration',
        'Thyroid Disorders',
        'Metabolic Syndrome',
        'Hypoglycemia Prevention',
      ],
      avatarUrl:
          'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400&auto=format&fit=crop&q=80',
      bio:
          'Endocrine specialist focused on long-term glycemic stabilization, cold-chain insulin therapy regimens, and cardiovascular metabolic protection.',
      nextAvailableSlot: 'In 25 mins',
      supportsVideo: true,
      supportsAudio: true,
    ),
    DoctorModel(
      id: 'doc-halima-danjuma',
      name: 'Dr. Halima Danjuma',
      title: 'Consultant Obstetrician & Gynecologist',
      specialty: 'Obstetrics & Maternal Health',
      licenseNumber: 'MDCN Reg. #52840',
      qualifications: 'MBBS, FWACS (OB-GYN), MRCOG',
      yearsOfExperience: 15,
      hospital: 'Federal Staff Hospital Jabi, Abuja',
      consultationFee: 7500.0,
      rating: 4.96,
      reviewCount: 164,
      isAvailable: true,
      availabilityStatus: 'Available Now',
      specializations: const [
        'Prenatal & Antenatal Care',
        'Pregnancy Safe Medications',
        'Menstrual Irregularities',
        'Pelvic Pain',
        'Postpartum Recovery',
        'Fertility Counseling',
      ],
      avatarUrl:
          'https://images.unsplash.com/photo-1623854767648-e7bb8009f0db?w=400&auto=format&fit=crop&q=80',
      bio:
          'Leading maternal health consultant ensuring expectant mothers receive compassionate, evidence-based obstetric advice and medication safety reviews.',
      nextAvailableSlot: 'Instant (under 5 mins)',
      supportsVideo: true,
      supportsAudio: true,
    ),
    DoctorModel(
      id: 'doc-pharm-tunde-adewale',
      name: 'Pharm. Tunde Adewale (PharmD)',
      title: 'Lead Clinical Pharmacologist & Medication Reviewer',
      specialty: 'Clinical Pharmacology & Therapeutics',
      licenseNumber: 'PCN Reg. #41209',
      qualifications: 'B.Pharm, PharmD, FPCPharm',
      yearsOfExperience: 12,
      hospital: 'ComfortCare Central Formulary, Wuse 2',
      consultationFee: 4500.0,
      rating: 4.91,
      reviewCount: 88,
      isAvailable: true,
      availabilityStatus: 'Available Now',
      specializations: const [
        'Drug Interactions',
        'Prescription Dosage Verification',
        'Polypharmacy Review',
        'Food-Drug Contraindications',
        'Side Effect Management',
        'Generic Substitutions',
      ],
      avatarUrl:
          'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=400&auto=format&fit=crop&q=80',
      bio:
          'Specialist in clinical pharmacokinetics, therapeutic drug monitoring, and verifying complex drug-drug combinations for Abuja patients.',
      nextAvailableSlot: 'Instant (under 1 min)',
      supportsVideo: true,
      supportsAudio: true,
    ),
    DoctorModel(
      id: 'doc-osas-ighodaro',
      name: 'Dr. Osas Ighodaro (PT, DPT)',
      title: 'Consultant Orthopedic Physiotherapist & Rehabilitation Specialist',
      specialty: 'Physiotherapy & Physical Rehabilitation',
      licenseNumber: 'MRTB Reg. #31842',
      qualifications: 'B.PT, DPT, CMP (Certified Maitland), OCS',
      yearsOfExperience: 12,
      hospital: 'National Orthopaedic & Rehabilitation Centre / ComfortCare Hub',
      consultationFee: 6000.0,
      rating: 4.97,
      reviewCount: 118,
      isAvailable: true,
      availabilityStatus: 'Available Now',
      specializations: const [
        'Fracture Recovery',
        'Gait Training & Fluid Mobility',
        'Post-Trauma Leg Rehabilitation',
        'Joint Stiffness & Range of Motion',
        'Quadriceps & Muscle Strengthening',
        'Weight-Bearing Rehabilitation',
        'Physical Therapy Assessment',
      ],
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
      bio:
          'Senior physical therapist specializing in post-fracture mobility restoration, gait rehabilitation, reducing joint stiffness, and progressive neuromuscular retraining for Abuja patients.',
      nextAvailableSlot: 'Instant (under 2 mins)',
      supportsVideo: true,
      supportsAudio: true,
    ),
    DoctorModel(
      id: 'doc-fatima-al-hassan',
      name: 'Dr. Fatima Al-Hassan (PhD)',
      title: 'Consultant Clinical Psychologist & Psychotherapist',
      specialty: 'Clinical Psychology & Psychotherapy',
      licenseNumber: 'NPA Reg. #18402',
      qualifications: 'BSc, MSc, PhD Clinical Psychology, Certified CBT',
      yearsOfExperience: 10,
      hospital: 'Abuja Psychological Health Clinic / ComfortCare Telehealth',
      consultationFee: 7500.0,
      rating: 4.94,
      reviewCount: 84,
      isAvailable: true,
      availabilityStatus: 'Available Now',
      specializations: const [
        'Trauma & Injury Coping',
        'Pain Psychology & Mental Resilience',
        'Recovery Stress & Anxiety',
        'Fear of Re-injury (Kinesiophobia)',
        'Cognitive Behavioral Therapy (CBT)',
        'Mindfulness & Chronic Rehabilitation Support',
      ],
      avatarUrl:
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&auto=format&fit=crop&q=80',
      bio:
          'Consultant clinical psychotherapist dedicated to helping patients navigate psychological barriers during recovery from physical trauma, accident injuries, mobility loss, and chronic pain.',
      nextAvailableSlot: 'Instant (under 3 mins)',
      supportsVideo: true,
      supportsAudio: true,
    ),
    DoctorModel(
      id: 'doc-kelechi-nwosu',
      name: 'Dr. Kelechi Nwosu',
      title: 'Consultant Orthopedic & Trauma Surgeon',
      specialty: 'Orthopedic Surgery & Trauma',
      licenseNumber: 'MDCN Reg. #44310',
      qualifications: 'MBBS, FWACS (Orthopaedics), AO Trauma Fellow',
      yearsOfExperience: 15,
      hospital: 'Cedarcrest Orthopaedic Hospital Apo, Abuja',
      consultationFee: 9000.0,
      rating: 4.96,
      reviewCount: 172,
      isAvailable: true,
      availabilityStatus: 'Available Now',
      specializations: const [
        'Bone Fractures & Non-Union',
        'Limb Trauma Recovery',
        'Orthopedic Radiographs & X-Ray Review',
        'Joint Reconstruction',
        'Post-Cast Alignment & Bone Consolidation',
      ],
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
      bio:
          'Chief trauma and orthopedic specialist advising on complex bone fracture consolidation, limb biomechanics, and post-cast recovery protocols.',
      nextAvailableSlot: 'Available Now',
      supportsVideo: true,
      supportsAudio: true,
    ),
  ];

  static final List<ConsultantReviewEntity> _mockReviews = [
    ConsultantReviewEntity(
      id: 'rev-01',
      doctorId: 'doc-chinedu-eze',
      patientName: 'Emeka Nwachukwu',
      rating: 5.0,
      comment:
          'Dr. Chinedu quickly reviewed my fever symptoms and malaria RDT photo. He prescribed Coartem and explained the lipid meal timing. Feeling 100% better within 48 hours!',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      consultationType: 'Video Call',
    ),
    ConsultantReviewEntity(
      id: 'rev-02',
      doctorId: 'doc-chinedu-eze',
      patientName: 'Fatima Garba',
      rating: 5.0,
      comment:
          'Very calm and reassuring doctor. Highly knowledgeable on Abuja malaria strains.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      consultationType: 'Audio Call',
    ),
    ConsultantReviewEntity(
      id: 'rev-03',
      doctorId: 'doc-amina-bello',
      patientName: 'Chief Oladipo Johnson',
      rating: 5.0,
      comment:
          'Dr. Amina evaluated my Omron BP telemetry readings over video call and adjusted my timing. Truly world-class telemedicine right here in Abuja.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      consultationType: 'Video Call',
    ),
    ConsultantReviewEntity(
      id: 'rev-04',
      doctorId: 'doc-zainab-usman',
      patientName: 'Blessing Okon',
      rating: 5.0,
      comment:
          'Prompt response when my 3-year-old had sudden chills. Her dosage guidance was spot on.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      consultationType: 'Video Call',
    ),
  ];

  static final List<ConsultationSessionEntity> _mockSessions = [
    ConsultationSessionEntity(
      id: 'sess-abj-01',
      doctorId: 'doc-chinedu-eze',
      doctorName: 'Dr. Chinedu Eze',
      doctorAvatar:
          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&auto=format&fit=crop&q=80',
      doctorSpecialty: 'Infectious Diseases & General Medicine',
      patientId: 'patient-abj-01',
      patientName: 'Amina Bello',
      scheduledAt: DateTime.now().subtract(const Duration(minutes: 15)),
      chiefComplaint: 'Acute headache, fever 38.6°C, chills and malaria suspicion',
      status: 'waiting',
      callType: 'video',
      fee: 6500.0,
    ),
    ConsultationSessionEntity(
      id: 'sess-abj-02',
      doctorId: 'doc-amina-bello',
      doctorName: 'Dr. Amina Bello',
      doctorAvatar:
          'https://images.unsplash.com/photo-1594824813572-c288bdf21469?w=400&auto=format&fit=crop&q=80',
      doctorSpecialty: 'Cardiovascular & Internal Medicine',
      patientId: 'patient-abj-02',
      patientName: 'Babatunde Adeleke',
      scheduledAt: DateTime.now().subtract(const Duration(hours: 2)),
      chiefComplaint: 'Pre-hypertension telemetry check (132/86 mmHg)',
      status: 'completed',
      callType: 'video',
      durationSeconds: 480,
      clinicalNotes: 'Prescribed lifestyle sodium restriction & repeated morning BP logging.',
      fee: 8500.0,
      patientRating: 5.0,
      patientReview: 'Excellent cardiovascular consultation.',
    ),
  ];

  static final List<DoctorModel> _mockPendingConsultants = [
    DoctorModel(
      id: 'doc-pending-farouk',
      name: 'Dr. Farouk Al-Mansur',
      title: 'Consultant Orthopedic & Trauma Surgeon',
      specialty: 'Orthopedic Surgery & Trauma',
      licenseNumber: 'MDCN-78921-ORTHO',
      qualifications: 'MBBS, FWACS (Orthopaedics)',
      yearsOfExperience: 16,
      hospital: 'Cedarcrest Orthopedic Centre, Apo, Abuja',
      consultationFee: 8500.0,
      rating: 4.9,
      reviewCount: 0,
      isAvailable: false,
      availabilityStatus: 'Pending Admin Approval',
      specializations: const ['Bone Fractures', 'Leg Mobility', 'Joint Stiffness', 'Trauma'],
      avatarUrl:
          'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=400&auto=format&fit=crop&q=80',
      bio:
          'Consultant orthopedic trauma surgeon with expertise in complex fracture management, post-op mobility recovery, and joint stabilization.',
      approvalStatus: 'pending',
      documentationName: 'MDCN_Consultant_Fellowship_Certificate.pdf',
    ),
    DoctorModel(
      id: 'doc-pending-fatima',
      name: 'Dr. Fatima Al-Hassan',
      title: 'Senior Clinical Psychologist & Psychotherapist',
      specialty: 'Clinical Psychology & Psychotherapy',
      licenseNumber: 'NPA-99214-PSY',
      qualifications: 'BSc, MSc, PhD Clinical Psychology, Certified CBT',
      yearsOfExperience: 11,
      hospital: 'Abuja MindCare & Psychological Centre, Maitama',
      consultationFee: 7000.0,
      rating: 4.88,
      reviewCount: 0,
      isAvailable: false,
      availabilityStatus: 'Pending Admin Approval',
      specializations: const ['Injury Trauma', 'Pain Coping', 'Fear of Re-injury', 'Anxiety'],
      avatarUrl:
          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&auto=format&fit=crop&q=80',
      bio:
          'Licensed psychotherapist helping patients navigate psychological hurdles in rehabilitation, pain anxiety, and trauma recovery.',
      approvalStatus: 'pending',
      documentationName: 'Practicing_License_Psychotherapy.pdf',
    ),
  ];

  static List<DoctorModel> get inMemoryDoctors => List.unmodifiable(_mockDoctors);
  static List<DoctorModel> get pendingConsultantsList => List.unmodifiable(_mockPendingConsultants);

  @override
  Future<List<DoctorModel>> getPendingConsultants() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_mockPendingConsultants);
  }

  @override
  Future<DoctorModel> approveConsultant(String doctorId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockPendingConsultants.indexWhere((d) => d.id == doctorId);
    if (index != -1) {
      final pending = _mockPendingConsultants.removeAt(index);
      final approved = DoctorModel(
        id: pending.id,
        name: pending.name,
        title: pending.title,
        specialty: pending.specialty,
        licenseNumber: pending.licenseNumber,
        qualifications: pending.qualifications,
        yearsOfExperience: pending.yearsOfExperience,
        hospital: pending.hospital,
        consultationFee: pending.consultationFee,
        rating: pending.rating,
        reviewCount: pending.reviewCount,
        isAvailable: true,
        availabilityStatus: 'Available Now',
        specializations: pending.specializations,
        avatarUrl: pending.avatarUrl,
        bio: pending.bio,
        nextAvailableSlot: 'Available Now',
        supportsVideo: pending.supportsVideo,
        supportsAudio: pending.supportsAudio,
        approvalStatus: 'approved',
        documentationName: pending.documentationName,
      );
      _mockDoctors.insert(0, approved);
      return approved;
    }
    return _mockDoctors.firstWhere((d) => d.id == doctorId);
  }

  @override
  Future<DoctorModel> rejectConsultant(String doctorId, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockPendingConsultants.indexWhere((d) => d.id == doctorId);
    if (index != -1) {
      final pending = _mockPendingConsultants[index];
      final rejected = DoctorModel(
        id: pending.id,
        name: pending.name,
        title: pending.title,
        specialty: pending.specialty,
        licenseNumber: pending.licenseNumber,
        qualifications: pending.qualifications,
        yearsOfExperience: pending.yearsOfExperience,
        hospital: pending.hospital,
        consultationFee: pending.consultationFee,
        rating: pending.rating,
        reviewCount: pending.reviewCount,
        isAvailable: false,
        availabilityStatus: 'Disapproved',
        specializations: pending.specializations,
        avatarUrl: pending.avatarUrl,
        bio: pending.bio,
        nextAvailableSlot: 'Unavailable',
        supportsVideo: pending.supportsVideo,
        supportsAudio: pending.supportsAudio,
        approvalStatus: 'rejected',
        documentationName: pending.documentationName,
      );
      _mockPendingConsultants[index] = rejected;
      return rejected;
    }
    return _mockDoctors.firstWhere((d) => d.id == doctorId);
  }

  @override
  Future<List<DoctorModel>> getDoctors({
    String? specialty,
    String? query,
    bool onlyAvailable = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _mockDoctors.where((doc) {
      if (onlyAvailable && !doc.isAvailable) return false;
      if (specialty != null && specialty != 'All' && specialty.isNotEmpty) {
        if (!doc.specialty.toLowerCase().contains(specialty.toLowerCase())) {
          return false;
        }
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchesName = doc.name.toLowerCase().contains(q);
        final matchesSpecialty = doc.specialty.toLowerCase().contains(q);
        final matchesHospital = doc.hospital.toLowerCase().contains(q);
        final matchesSpec = doc.specializations.any((s) => s.toLowerCase().contains(q));
        if (!matchesName && !matchesSpecialty && !matchesHospital && !matchesSpec) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Future<DoctorModel?> getDoctorById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _mockDoctors.firstWhere((d) => d.id == id);
    } catch (_) {
      try {
        return _mockPendingConsultants.firstWhere((d) => d.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<DoctorModel> registerDoctor(DoctorModel doctor) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (doctor.approvalStatus == 'pending') {
      final index = _mockPendingConsultants.indexWhere((d) => d.id == doctor.id);
      if (index != -1) {
        _mockPendingConsultants[index] = doctor;
      } else {
        _mockPendingConsultants.insert(0, doctor);
      }
      return doctor;
    }
    final index = _mockDoctors.indexWhere((d) => d.id == doctor.id);
    if (index != -1) {
      _mockDoctors[index] = doctor;
    } else {
      _mockDoctors.insert(0, doctor);
    }
    return doctor;
  }

  @override
  Future<DoctorModel> updateDoctorAvailability(
    String doctorId,
    bool isAvailable,
    String status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _mockDoctors.indexWhere((d) => d.id == doctorId);
    if (index != -1) {
      final updated = _mockDoctors[index].copyWith(
        isAvailable: isAvailable,
        availabilityStatus: status,
      );
      _mockDoctors[index] = DoctorModel.fromEntity(updated);
      return _mockDoctors[index];
    }
    throw Exception('Doctor not found');
  }

  @override
  Future<void> rateDoctor({
    required String doctorId,
    required double rating,
    required String comment,
    required String patientName,
    String consultationType = 'Video Call',
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newReview = ConsultantReviewEntity(
      id: 'rev-${_uuid.v4().substring(0, 8)}',
      doctorId: doctorId,
      patientName: patientName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
      consultationType: consultationType,
    );
    _mockReviews.insert(0, newReview);

    // Recalculate doctor rating
    final index = _mockDoctors.indexWhere((d) => d.id == doctorId);
    if (index != -1) {
      final existingReviews = _mockReviews.where((r) => r.doctorId == doctorId).toList();
      final totalScore = existingReviews.fold<double>(0.0, (acc, r) => acc + r.rating);
      final newRating = double.parse((totalScore / existingReviews.length).toStringAsFixed(2));
      final updated = _mockDoctors[index].copyWith(
        rating: newRating,
        reviewCount: existingReviews.length,
      );
      _mockDoctors[index] = DoctorModel.fromEntity(updated);
    }
  }

  @override
  Future<List<ConsultantReviewEntity>> getDoctorReviews(String doctorId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockReviews.where((r) => r.doctorId == doctorId).toList();
  }

  @override
  Future<ConsultationSessionEntity> createSession(ConsultationSessionEntity session) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockSessions.insert(0, session);
    return session;
  }

  @override
  Future<List<ConsultationSessionEntity>> getSessionsForDoctor(String doctorId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _mockSessions.where((s) => s.doctorId == doctorId).toList();
  }

  @override
  Future<void> completeSession(
    String sessionId, {
    String? notes,
    double? rating,
    String? review,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockSessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final sess = _mockSessions[index];
      _mockSessions[index] = sess.copyWith(
        status: 'completed',
        clinicalNotes: notes ?? sess.clinicalNotes,
        patientRating: rating ?? sess.patientRating,
        patientReview: review ?? sess.patientReview,
      );

      if (rating != null) {
        await rateDoctor(
          doctorId: sess.doctorId,
          rating: rating,
          comment: review ?? 'Completed clinical consultation.',
          patientName: sess.patientName,
          consultationType: sess.callType == 'video' ? 'Video Call' : 'Audio Call',
        );
      }
    }
  }

  @override
  Future<DoctorModel?> findBestMatchingDoctor(String symptomsOrQuery) async {
    final lower = symptomsOrQuery.toLowerCase().trim();
    if (lower.isEmpty) return _mockDoctors.first;

    final scored = <MapEntry<DoctorModel, int>>[];

    for (final doc in _mockDoctors) {
      int score = 0;
      final specLower = doc.specialty.toLowerCase();
      final bioLower = doc.bio.toLowerCase();

      if (doc.isAvailable) score += 10;

      for (final spec in doc.specializations) {
        final sLower = spec.toLowerCase();
        if (lower.contains(sLower)) {
          score += 20;
        } else {
          for (final token in sLower.split(' ')) {
            if (token.length > 3 && lower.contains(token)) {
              score += 6;
            }
          }
        }
      }

      // Check bio keywords
      for (final word in lower.split(' ')) {
        if (word.length >= 4 && bioLower.contains(word)) {
          score += 3;
        }
      }

      // Primary clinical condition and specialty matches (+50)
      if ((lower.contains('physio') ||
              lower.contains('physical therapy') ||
              lower.contains('fracture') ||
              lower.contains('leg') ||
              lower.contains('fluid') ||
              lower.contains('fluidly') ||
              lower.contains('mobility') ||
              lower.contains('stiff') ||
              lower.contains('gait') ||
              lower.contains('walk') ||
              lower.contains('rehab')) &&
          specLower.contains('physiotherapy')) {
        score += 50;
      }
      if ((lower.contains('psycho') ||
              lower.contains('mental') ||
              lower.contains('trauma') ||
              lower.contains('anxiety') ||
              lower.contains('counsel') ||
              lower.contains('stress') ||
              lower.contains('cbt') ||
              lower.contains('mind')) &&
          specLower.contains('psychology')) {
        score += 50;
      }
      if ((lower.contains('orthopedic') ||
              lower.contains('orthopaedic') ||
              lower.contains('bone') ||
              lower.contains('broken') ||
              lower.contains('cast') ||
              lower.contains('x-ray')) &&
          specLower.contains('orthopedic')) {
        score += 50;
      }
      if ((lower.contains('malaria') || lower.contains('fever') || lower.contains('chills') || lower.contains('infection')) &&
          specLower.contains('infectious')) {
        score += 50;
      }
      if ((lower.contains('bp') || lower.contains('hypertension') || lower.contains('pressure') || lower.contains('chest') || lower.contains('heart')) &&
          specLower.contains('cardio')) {
        score += 50;
      }
      if ((lower.contains('child') || lower.contains('baby') || lower.contains('kid') || lower.contains('infant') || lower.contains('toddler') || lower.contains('pediatric')) &&
          specLower.contains('pediatric')) {
        score += 50;
      }
      if ((lower.contains('diabetes') || lower.contains('sugar') || lower.contains('glucose') || lower.contains('insulin')) &&
          specLower.contains('endocrin')) {
        score += 50;
      }
      if ((lower.contains('pregnant') || lower.contains('pregnancy') || lower.contains('period') || lower.contains('female') || lower.contains('woman') || lower.contains('maternal')) &&
          specLower.contains('obstetric')) {
        score += 50;
      }
      if ((lower.contains('interaction') || lower.contains('side effect') || lower.contains('dosage') || lower.contains('drug') || lower.contains('swap')) &&
          specLower.contains('pharmacology')) {
        score += 50;
      }

      if (score > 0) {
        scored.add(MapEntry(doc, score));
      }
    }

    scored.sort((a, b) => b.value.compareTo(a.value));

    if (scored.isNotEmpty) {
      return scored.first.key;
    }
    return _mockDoctors.firstWhere((d) => d.isAvailable, orElse: () => _mockDoctors.first);
  }
}
