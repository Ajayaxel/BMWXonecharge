import 'package:equatable/equatable.dart';
import 'package:onecharge/models/login_model.dart';

class RegisterRequest extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }

  @override
  List<Object> get props => [
    name,
    email,
    phone,
    password,
    passwordConfirmation,
  ];
}

class RegisterResponse extends Equatable {
  final Customer customer;
  final String email;
  final String? message;

  const RegisterResponse({
    required this.customer,
    required this.email,
    this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      customer: Customer.fromJson(json['customer']),
      email: json['email'] ?? '',
      message:
          json['message'], // This might come from parent object but we'll see
    );
  }

  @override
  List<Object?> get props => [customer, email, message];
}

class VerifyOtpRequest extends Equatable {
  final String email;
  final String otp;

  const VerifyOtpRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp};
  }

  @override
  List<Object> get props => [email, otp];
}

class ResendOtpRequest extends Equatable {
  final String email;

  const ResendOtpRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }

  @override
  List<Object> get props => [email];
}

class VerificationRequiredResponse extends Equatable {
  final String email;

  const VerificationRequiredResponse({required this.email});

  factory VerificationRequiredResponse.fromJson(Map<String, dynamic> json) {
    return VerificationRequiredResponse(email: json['email'] ?? '');
  }

  @override
  List<Object> get props => [email];
}
