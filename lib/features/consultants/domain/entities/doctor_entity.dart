import 'package:equatable/equatable.dart';

class DoctorEntity extends Equatable {
  final String id;
  final String name;
  final String title;
  final String specialty;
  final String licenseNumber; // MDCN Reg No.
  final String qualifications; // MBBS, FWACS, etc.
  final int yearsOfExperience;
  final String hospital;
  final double consultationFee;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final String availabilityStatus; // 'Available Now', 'In Consultation', 'Offline'
  final List<String> specializations; // Medical cases/symptoms treated (used by AI)
  final String avatarUrl;
  final String bio;
  final String nextAvailableSlot;
  final bool supportsVideo;
  final bool supportsAudio;
  final String approvalStatus; // 'approved', 'pending', 'rejected'
  final String? documentationName;

  const DoctorEntity({
    required this.id,
    required this.name,
    required this.title,
    required this.specialty,
    required this.licenseNumber,
    required this.qualifications,
    required this.yearsOfExperience,
    required this.hospital,
    required this.consultationFee,
    this.rating = 4.9,
    this.reviewCount = 0,
    this.isAvailable = true,
    this.availabilityStatus = 'Available Now',
    this.specializations = const [],
    required this.avatarUrl,
    required this.bio,
    this.nextAvailableSlot = 'Instant (under 3 mins)',
    this.supportsVideo = true,
    this.supportsAudio = true,
    this.approvalStatus = 'approved',
    this.documentationName,
  });

  bool get isApproved => approvalStatus == 'approved';
  bool get isPendingApproval => approvalStatus == 'pending';

  DoctorEntity copyWith({
    String? id,
    String? name,
    String? title,
    String? specialty,
    String? licenseNumber,
    String? qualifications,
    int? yearsOfExperience,
    String? hospital,
    double? consultationFee,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    String? availabilityStatus,
    List<String>? specializations,
    String? avatarUrl,
    String? bio,
    String? nextAvailableSlot,
    bool? supportsVideo,
    bool? supportsAudio,
    String? approvalStatus,
    String? documentationName,
  }) {
    return DoctorEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      specialty: specialty ?? this.specialty,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      qualifications: qualifications ?? this.qualifications,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      hospital: hospital ?? this.hospital,
      consultationFee: consultationFee ?? this.consultationFee,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      specializations: specializations ?? this.specializations,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      nextAvailableSlot: nextAvailableSlot ?? this.nextAvailableSlot,
      supportsVideo: supportsVideo ?? this.supportsVideo,
      supportsAudio: supportsAudio ?? this.supportsAudio,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      documentationName: documentationName ?? this.documentationName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        title,
        specialty,
        licenseNumber,
        qualifications,
        yearsOfExperience,
        hospital,
        consultationFee,
        rating,
        reviewCount,
        isAvailable,
        availabilityStatus,
        specializations,
        avatarUrl,
        bio,
        nextAvailableSlot,
        supportsVideo,
        supportsAudio,
        approvalStatus,
        documentationName,
      ];
}
