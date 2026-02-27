import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
  });

  @override
  List<Object?> get props => [id, name, email, phone, profileImage];
}

class AuthToken extends Equatable {
  final String accessToken;
  final String? refreshToken;

  const AuthToken({required this.accessToken, this.refreshToken});

  @override
  List<Object?> get props => [accessToken, refreshToken];
}
