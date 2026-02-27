import 'package:equatable/equatable.dart';
import 'package:onecharge/models/redeem_code_model.dart';

abstract class RedeemCodeState extends Equatable {
  const RedeemCodeState();

  @override
  List<Object?> get props => [];
}

class RedeemCodeInitial extends RedeemCodeState {}

class RedeemCodeLoading extends RedeemCodeState {}

class RedeemCodeSuccess extends RedeemCodeState {
  final RedeemCodeResponse response;

  const RedeemCodeSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class RedeemCodeFailure extends RedeemCodeState {
  final String message;

  const RedeemCodeFailure(this.message);

  @override
  List<Object?> get props => [message];
}
