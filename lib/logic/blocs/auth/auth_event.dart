import 'package:equatable/equatable.dart';
import 'package:onecharge/models/login_model.dart';

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
