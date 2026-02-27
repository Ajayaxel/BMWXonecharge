import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/features/auth/domain/usecases/login_usecase.dart';
import 'package:onecharge/features/auth/domain/usecases/logout_usecase.dart';
import 'package:onecharge/features/auth/domain/repositories/auth_repository.dart';
import 'package:onecharge/features/auth/domain/usecases/register_usecase.dart';
import 'package:onecharge/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:onecharge/features/auth/presentation/bloc/auth_event.dart';
import 'package:onecharge/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final RegisterUseCase? _registerUseCase;
  final VerifyOtpUseCase? _verifyOtpUseCase;
  final AuthRepository _repository; // For check status

  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    RegisterUseCase? registerUseCase,
    VerifyOtpUseCase? verifyOtpUseCase,
    required AuthRepository repository,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _registerUseCase = registerUseCase,
       _verifyOtpUseCase = verifyOtpUseCase,
       _repository = repository,
       super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_registerUseCase == null) return;
    emit(AuthLoading());
    final result = await _registerUseCase(
      name: event.name,
      email: event.email,
      phone: event.phone,
      password: event.password,
    );
    result.fold((failure) => emit(AuthFailure(failure.message)), (user) {
      // If user id is 0, it means we need OTP verification (as per repository impl hint)
      if (user.id == 0) {
        emit(AuthOtpRequired(event.email));
      } else {
        emit(Authenticated(user));
      }
    });
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_verifyOtpUseCase == null) return;
    emit(AuthLoading());
    final result = await _verifyOtpUseCase(event.email, event.otp);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onResendOtpRequested(
    ResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _repository.resendOtp(event.email);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthOtpResent()),
    );
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final userOption = await _repository.getAuthenticatedUser();
      userOption.fold(
        () => emit(Unauthenticated()),
        (user) => emit(Authenticated(user)),
      );
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // ⚡ Optimization: Prevent duplicate loading states
    if (state is AuthLoading) return;

    emit(AuthLoading());

    final result = await _loginUseCase(event.email, event.password);

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _logoutUseCase();
    emit(Unauthenticated());
  }
}
