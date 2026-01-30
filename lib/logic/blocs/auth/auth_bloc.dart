import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/core/storage/token_storage.dart';
import 'package:onecharge/data/repositories/auth_repository.dart';
import 'package:onecharge/logic/blocs/auth/auth_event.dart';
import 'package:onecharge/logic/blocs/auth/auth_state.dart';
import 'package:onecharge/models/login_model.dart';
import 'package:onecharge/models/register_model.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.register(event.registerRequest);

      if (response is LoginResponse) {
        // Save token and name to storage
        await TokenStorage.saveToken(response.token);
        await TokenStorage.saveUserName(response.customer.name);
        emit(AuthSuccess(response));
      } else if (response is RegisterResponse) {
        // OTP required
        emit(AuthOtpRequired(response.email));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final loginResponse = await authRepository.verifyOtp(
        VerifyOtpRequest(email: event.email, otp: event.otp),
      );
      // Save token and name to storage
      await TokenStorage.saveToken(loginResponse.token);
      await TokenStorage.saveUserName(loginResponse.customer.name);
      emit(AuthSuccess(loginResponse));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onResendOtpRequested(
    ResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Don't emit AuthLoading if we want to keep the UI showing the OTP screen
    // But usually it's fine. If we emit loading, the OTP screen might rebuild.
    // Let's emit nothing but side effect, or handle localized loading.
    // For now, let's just do it
    try {
      await authRepository.resendOtp(event.email);
      emit(AuthOtpResent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.login(event.loginRequest);

      if (response is LoginResponse) {
        // Save token and name to storage
        await TokenStorage.saveToken(response.token);
        await TokenStorage.saveUserName(response.customer.name);
        emit(AuthSuccess(response));
      } else if (response is VerificationRequiredResponse) {
        // Login failed, OTP required
        emit(AuthOtpRequired(response.email));
      }
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
