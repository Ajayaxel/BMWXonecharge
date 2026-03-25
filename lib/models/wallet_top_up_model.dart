class WalletTopUpResponse {
  final bool success;
  final WalletTopUpData? data;
  final String? message;

  WalletTopUpResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory WalletTopUpResponse.fromJson(Map<String, dynamic> json) {
    return WalletTopUpResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? WalletTopUpData.fromJson(json['data']) : null,
      message: json['message'] as String?,
    );
  }
}

class WalletTopUpData {
  final String checkoutUrl;
  final int walletTransactionId;

  WalletTopUpData({
    required this.checkoutUrl,
    required this.walletTransactionId,
  });

  factory WalletTopUpData.fromJson(Map<String, dynamic> json) {
    return WalletTopUpData(
      checkoutUrl: json['checkout_url'] ?? '',
      walletTransactionId: json['wallet_transaction_id'] ?? 0,
    );
  }
}
