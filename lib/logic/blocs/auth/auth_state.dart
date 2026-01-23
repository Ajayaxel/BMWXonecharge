import 'package:equatable/equatable.dart';
import 'package:onecharge/models/login_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final LoginResponse loginResponse;

  const AuthSuccess(this.loginResponse);

  @override
  List<Object> get props => [loginResponse];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
