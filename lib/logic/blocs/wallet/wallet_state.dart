import 'package:onecharge/models/wallet_top_up_model.dart';
import 'package:onecharge/models/wallet_model.dart';

abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletTopUpSuccess extends WalletState {
  final WalletTopUpData data;

  WalletTopUpSuccess({required this.data});
}

class WalletLoaded extends WalletState {
  final WalletDetailData data;

  WalletLoaded({required this.data});
}

class WalletFailure extends WalletState {
  final String error;

  WalletFailure({required this.error});
}
