abstract class WalletEvent {}

class TopUpWalletEvent extends WalletEvent {
  final double amount;

  TopUpWalletEvent({required this.amount});
}

class FetchWalletDetailsEvent extends WalletEvent {}
