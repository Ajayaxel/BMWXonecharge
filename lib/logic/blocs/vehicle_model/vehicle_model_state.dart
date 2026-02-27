import 'package:equatable/equatable.dart';
import 'package:onecharge/models/vehicle_model.dart';

abstract class VehicleModelState extends Equatable {
  final List<VehicleModel> models;
  final int totalCount;
  final bool hasReachedMax;
  final int currentPage;

  const VehicleModelState({
    this.models = const [],
    this.totalCount = 0,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [models, totalCount, hasReachedMax, currentPage];
}

class VehicleModelInitial extends VehicleModelState {
  const VehicleModelInitial() : super();
}

class VehicleModelLoading extends VehicleModelState {
  const VehicleModelLoading({
    super.models,
    super.totalCount,
    super.hasReachedMax,
    super.currentPage,
  });
}

class VehicleModelLoaded extends VehicleModelState {
  const VehicleModelLoaded({
    required super.models,
    required super.totalCount,
    required super.hasReachedMax,
    required super.currentPage,
  });

  @override
  bool get stringify => true;
}

class VehicleModelPaginationLoading extends VehicleModelLoaded {
  const VehicleModelPaginationLoading({
    required super.models,
    required super.totalCount,
    required super.hasReachedMax,
    required super.currentPage,
  });
}

class VehicleModelError extends VehicleModelState {
  final String message;

  const VehicleModelError(
    this.message, {
    super.models,
    super.totalCount,
    super.hasReachedMax,
    super.currentPage,
  });

  @override
  List<Object?> get props => [
    message,
    models,
    totalCount,
    hasReachedMax,
    currentPage,
  ];
}
