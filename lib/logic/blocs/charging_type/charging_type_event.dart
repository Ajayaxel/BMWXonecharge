import 'package:equatable/equatable.dart';

abstract class ChargingTypeEvent extends Equatable {
  const ChargingTypeEvent();

  @override
  List<Object> get props => [];
}

class FetchChargingTypes extends ChargingTypeEvent {}
