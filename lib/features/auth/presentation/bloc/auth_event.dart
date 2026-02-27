import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

final class LogoutRequested extends AuthEvent {}

final class AuthCheckRequested extends AuthEvent {}

final class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });
}

final class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;
  const VerifyOtpRequested(this.email, this.otp);
}

final class ResendOtpRequested extends AuthEvent {
  final String email;
  const ResendOtpRequested(this.email);
}
