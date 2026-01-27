import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/core/storage/token_storage.dart';
import 'package:onecharge/data/repositories/auth_repository.dart';
import 'package:onecharge/logic/blocs/auth/auth_event.dart';
import 'package:onecharge/logic/blocs/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final loginResponse = await authRepository.login(event.loginRequest);
      // Save token and name to storage
      await TokenStorage.saveToken(loginResponse.token);
      await TokenStorage.saveUserName(loginResponse.customer.name);
      emit(AuthSuccess(loginResponse));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      // Clear token from storage
      await TokenStorage.clearToken();
      emit(AuthLoggedOut());
    } catch (e) {
      // Even if API logout fails, we might want to clear local session
      await TokenStorage.clearToken();
      emit(AuthLoggedOut());
      // Alternatively, we could emit AuthError(e.toString()) if we want to show it
      // but usually logout should just work or force logout locally.
    }
  }
}
