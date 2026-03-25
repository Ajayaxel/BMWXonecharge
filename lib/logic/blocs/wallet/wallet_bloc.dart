import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/data/repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;

  WalletBloc({required this.walletRepository}) : super(WalletInitial()) {
    on<TopUpWalletEvent>(_onTopUpWallet);
    on<FetchWalletDetailsEvent>(_onFetchWalletDetails);
  }

  Future<void> _onTopUpWallet(
    TopUpWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      final response = await walletRepository.topUpWallet(event.amount);
      if (response.success && response.data != null) {
        emit(WalletTopUpSuccess(data: response.data!));
      } else {
        emit(WalletFailure(error: response.message ?? 'Wallet top-up failed'));
      }
    } catch (e) {
      emit(WalletFailure(error: e.toString()));
    }
  }

  Future<void> _onFetchWalletDetails(
    FetchWalletDetailsEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      final response = await walletRepository.getWalletDetails();
      if (response.success) {
        emit(WalletLoaded(data: response.data));
      } else {
        emit(WalletFailure(error: 'Failed to fetch wallet details'));
      }
    } catch (e) {
      emit(WalletFailure(error: e.toString()));
    }
  }
}
