import 'package:equatable/equatable.dart';

class LoginRequest extends Equatable {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  @override
  List<Object> get props => [email, password];
}

class Customer extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImage: json['profile_image'],
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  @override
  List<Object?> get props =>
      [id, name, email, phone, profileImage, emailVerifiedAt, createdAt, updatedAt];
}

class LoginResponse extends Equatable {
  final Customer customer;
  final String token;
  final String tokenType;

  const LoginResponse({
    required this.customer,
    required this.token,
    required this.tokenType,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      customer: Customer.fromJson(json['customer']),
      token: json['token'],
      tokenType: json['token_type'],
    );
  }

  @override
  List<Object> get props => [customer, token, tokenType];
}
