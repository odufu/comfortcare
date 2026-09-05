import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/manage_profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ManageProfileUseCase _manageProfileUseCase;

  ProfileBloc({required ManageProfileUseCase manageProfileUseCase})
      : _manageProfileUseCase = manageProfileUseCase,
        super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await _manageProfileUseCase.getProfile();
      emit(state.copyWith(status: ProfileStatus.loaded, profile: profile));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    try {
      await _manageProfileUseCase.updateProfile(event.profile);
      emit(state.copyWith(profile: event.profile));
    } catch (_) {}
  }
}
