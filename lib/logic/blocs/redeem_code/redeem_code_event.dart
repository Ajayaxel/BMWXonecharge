import 'package:equatable/equatable.dart';

abstract class RedeemCodeEvent extends Equatable {
  const RedeemCodeEvent();

  @override
  List<Object?> get props => [];
}

class ValidateRedeemCode extends RedeemCodeEvent {
  final String code;

  const ValidateRedeemCode(this.code);

  @override
  List<Object?> get props => [code];
}

class ResetRedeemCode extends RedeemCodeEvent {}
