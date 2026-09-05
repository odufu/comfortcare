import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final UserProfileEntity profile;

  const UpdateProfileEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}
