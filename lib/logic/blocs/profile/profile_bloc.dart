import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/profile_repository.dart';
import 'package:onecharge/logic/blocs/profile/profile_event.dart';
import 'package:onecharge/logic/blocs/profile/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository}) : super(ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onFetchProfile(
    FetchProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final customer = await profileRepository.getProfile();
      emit(ProfileLoaded(customer: customer));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileUpdating(currentCustomer: currentState.customer));
      try {
        final updatedCustomer = await profileRepository.updateProfile(
          name: event.name,
          phone: event.phone,
          profileImage: event.profileImage,
        );
        emit(
          ProfileUpdated(
            customer: updatedCustomer,
            message: 'Profile updated successfully!',
          ),
        );
        // After showing success, we should revert to ProfileLoaded with the new data
        emit(ProfileLoaded(customer: updatedCustomer));
      } catch (e) {
        emit(ProfileError(message: e.toString()));
        // Revert to previous state if error occurs
        emit(ProfileLoaded(customer: currentState.customer));
      }
    }
  }
}
