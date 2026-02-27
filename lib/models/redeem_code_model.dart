class RedeemCodeResponse {
  final bool success;
  final String message;
  final RedeemCodeData? data;

  RedeemCodeResponse({required this.success, required this.message, this.data});

  factory RedeemCodeResponse.fromJson(Map<String, dynamic> json) {
    return RedeemCodeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? RedeemCodeData.fromJson(json['data']) : null,
    );
  }
}

class RedeemCodeData {
  final String code;
  final double discountAmount;
  final String type; // percentage or fixed

  RedeemCodeData({
    required this.code,
    required this.discountAmount,
    required this.type,
  });

  factory RedeemCodeData.fromJson(Map<String, dynamic> json) {
    return RedeemCodeData(
      code: json['code'] ?? '',
      discountAmount: (json['discount_amount'] ?? 0.0).toDouble(),
      type: json['type'] ?? 'fixed',
    );
  }
}
