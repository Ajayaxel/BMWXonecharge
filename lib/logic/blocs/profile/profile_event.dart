import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String name;
  final String phone;
  final String? dateOfBirth;
  final String? gender;
  final File? profileImage;

  const UpdateProfile({
    required this.name,
    required this.phone,
    this.dateOfBirth,
    this.gender,
    this.profileImage,
  });

  @override
  List<Object?> get props => [name, phone, dateOfBirth, gender, profileImage];
}
