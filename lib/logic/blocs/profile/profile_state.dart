import 'package:equatable/equatable.dart';
import 'package:onecharge/models/user_profile_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Customer customer;

  const ProfileLoaded({required this.customer});

  @override
  List<Object?> get props => [customer];
}

class ProfileUpdating extends ProfileState {
  final Customer currentCustomer;

  const ProfileUpdating({required this.currentCustomer});

  @override
  List<Object?> get props => [currentCustomer];
}

class ProfileUpdated extends ProfileState {
  final Customer customer;
  final String message;

  const ProfileUpdated({required this.customer, required this.message});

  @override
  List<Object?> get props => [customer, message];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
