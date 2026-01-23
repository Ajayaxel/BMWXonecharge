import 'package:equatable/equatable.dart';
import 'package:onecharge/models/charging_type_model.dart';

abstract class ChargingTypeState extends Equatable {
  const ChargingTypeState();

  @override
  List<Object> get props => [];
}

class ChargingTypeInitial extends ChargingTypeState {}

class ChargingTypeLoading extends ChargingTypeState {}

class ChargingTypeLoaded extends ChargingTypeState {
  final List<ChargingType> chargingTypes;

  const ChargingTypeLoaded(this.chargingTypes);

  @override
  List<Object> get props => [chargingTypes];
}

class ChargingTypeError extends ChargingTypeState {
  final String message;

  const ChargingTypeError(this.message);

  @override
  List<Object> get props => [message];
}
