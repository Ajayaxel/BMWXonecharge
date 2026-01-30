import 'package:equatable/equatable.dart';
import 'package:onecharge/models/login_model.dart';
import 'package:onecharge/models/register_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final LoginRequest loginRequest;

  const LoginRequested(this.loginRequest);

  @override
  List<Object> get props => [loginRequest];
}

class RegisterRequested extends AuthEvent {
  final RegisterRequest registerRequest;

  const RegisterRequested(this.registerRequest);

  @override
  List<Object> get props => [registerRequest];
}

class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;

  const VerifyOtpRequested({required this.email, required this.otp});

  @override
  List<Object> get props => [email, otp];
}

class ResendOtpRequested extends AuthEvent {
  final String email;

  const ResendOtpRequested(this.email);

  @override
  List<Object> get props => [email];
}

class LogoutRequested extends AuthEvent {}
