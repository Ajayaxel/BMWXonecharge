import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/core/storage/token_storage.dart';
import 'package:onecharge/data/repositories/auth_repository.dart';
import 'package:onecharge/logic/blocs/auth/auth_event.dart';
import 'package:onecharge/logic/blocs/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final loginResponse = await authRepository.login(event.loginRequest);
      // Save token to storage
      await TokenStorage.saveToken(loginResponse.token);
      emit(AuthSuccess(loginResponse));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
