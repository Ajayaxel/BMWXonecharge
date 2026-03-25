class WalletResponse {
  final bool success;
  final WalletDetailData data;

  WalletResponse({required this.success, required this.data});

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      success: json['success'] ?? false,
      data: WalletDetailData.fromJson(json['data']),
    );
  }
}

class WalletDetailData {
  final WalletInfo wallet;
  final List<Transaction> transactions;
  final WalletLimits limits;

  WalletDetailData({
    required this.wallet,
    required this.transactions,
    required this.limits,
  });

  factory WalletDetailData.fromJson(Map<String, dynamic> json) {
    return WalletDetailData(
      wallet: WalletInfo.fromJson(json['wallet']),
      transactions: (json['transactions'] as List)
          .map((t) => Transaction.fromJson(t))
          .toList(),
      limits: WalletLimits.fromJson(json['limits']),
    );
  }
}

class WalletInfo {
  final double balance;
  final String currency;

  WalletInfo({required this.balance, required this.currency});

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    return WalletInfo(
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] ?? 'AED',
    );
  }
}

class Transaction {
  final int id;
  final String type;
  final double amount;
  final String currency;
  final String status;
  final String createdAt;
  final String? completedAt;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'AED',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      completedAt: json['completed_at'],
    );
  }
}

class WalletLimits {
  final double min;
  final double max;

  WalletLimits({required this.min, required this.max});

  factory WalletLimits.fromJson(Map<String, dynamic> json) {
    return WalletLimits(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
    );
  }
}
