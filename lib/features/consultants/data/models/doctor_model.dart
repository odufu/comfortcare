import '../../domain/entities/doctor_entity.dart';

class DoctorModel extends DoctorEntity {
  const DoctorModel({
    required super.id,
    required super.name,
    required super.title,
    required super.specialty,
    required super.licenseNumber,
    required super.qualifications,
    required super.yearsOfExperience,
    required super.hospital,
    required super.consultationFee,
    super.rating = 4.9,
    super.reviewCount = 0,
    super.isAvailable = true,
    super.availabilityStatus = 'Available Now',
    super.specializations = const [],
    required super.avatarUrl,
    required super.bio,
    super.nextAvailableSlot = 'Instant (under 3 mins)',
    super.supportsVideo = true,
    super.supportsAudio = true,
    super.approvalStatus = 'approved',
    super.documentationName,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as String? ?? 'doc-unknown',
      name: json['name'] as String? ?? 'Consultant Doctor',
      title: json['title'] as String? ?? 'Medical Specialist',
      specialty: json['specialty'] as String? ?? 'General Medicine',
      licenseNumber: json['license_number'] as String? ?? 'MDCN-VERIFIED',
      qualifications: json['qualifications'] as String? ?? 'MBBS',
      yearsOfExperience: (json['years_of_experience'] as num?)?.toInt() ?? 8,
      hospital: json['hospital'] as String? ?? 'ComfortCare Telehealth Network, Abuja',
      consultationFee: (json['consultation_fee'] as num?)?.toDouble() ?? 5000.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
      availabilityStatus: json['availability_status'] as String? ?? 'Available Now',
      specializations: (json['specializations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      avatarUrl: json['avatar_url'] as String? ??
          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&auto=format&fit=crop&q=80',
      bio: json['bio'] as String? ?? 'Experienced clinical consultant registered with MDCN.',
      nextAvailableSlot: json['next_available_slot'] as String? ?? 'Instant (under 3 mins)',
      supportsVideo: json['supports_video'] as bool? ?? true,
      supportsAudio: json['supports_audio'] as bool? ?? true,
      approvalStatus: json['approval_status'] as String? ?? 'approved',
      documentationName: json['documentation_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'specialty': specialty,
      'license_number': licenseNumber,
      'qualifications': qualifications,
      'years_of_experience': yearsOfExperience,
      'hospital': hospital,
      'consultation_fee': consultationFee,
      'rating': rating,
      'review_count': reviewCount,
      'is_available': isAvailable,
      'availability_status': availabilityStatus,
      'specializations': specializations,
      'avatar_url': avatarUrl,
      'bio': bio,
      'next_available_slot': nextAvailableSlot,
      'supports_video': supportsVideo,
      'supports_audio': supportsAudio,
      'approval_status': approvalStatus,
      'documentation_name': documentationName,
    };
  }

  factory DoctorModel.fromEntity(DoctorEntity entity) {
    return DoctorModel(
      id: entity.id,
      name: entity.name,
      title: entity.title,
      specialty: entity.specialty,
      licenseNumber: entity.licenseNumber,
      qualifications: entity.qualifications,
      yearsOfExperience: entity.yearsOfExperience,
      hospital: entity.hospital,
      consultationFee: entity.consultationFee,
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      isAvailable: entity.isAvailable,
      availabilityStatus: entity.availabilityStatus,
      specializations: entity.specializations,
      avatarUrl: entity.avatarUrl,
      bio: entity.bio,
      nextAvailableSlot: entity.nextAvailableSlot,
      supportsVideo: entity.supportsVideo,
      supportsAudio: entity.supportsAudio,
      approvalStatus: entity.approvalStatus,
      documentationName: entity.documentationName,
    );
  }
}
