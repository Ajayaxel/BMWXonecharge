import 'package:equatable/equatable.dart';
import 'package:onecharge/models/service_group_model.dart';

abstract class ServiceGroupState extends Equatable {
  const ServiceGroupState();

  @override
  List<Object?> get props => [];
}

class ServiceGroupInitial extends ServiceGroupState {}

class ServiceGroupLoading extends ServiceGroupState {}

class ServiceGroupLoaded extends ServiceGroupState {
  final List<ServiceGroup> serviceGroups;

  const ServiceGroupLoaded(this.serviceGroups);

  @override
  List<Object?> get props => [serviceGroups];
}

class ServiceGroupError extends ServiceGroupState {
  final String message;

  const ServiceGroupError(this.message);

  @override
  List<Object?> get props => [message];
}
