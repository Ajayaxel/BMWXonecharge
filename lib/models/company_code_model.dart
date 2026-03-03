class CompanyCodeResponse {
  final bool success;
  final String message;
  final CompanyCodeData? data;

  CompanyCodeResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CompanyCodeResponse.fromJson(Map<String, dynamic> json) {
    return CompanyCodeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? CompanyCodeData.fromJson(json['data'])
          : null,
    );
  }
}

class CompanyCodeData {
  final bool valid;
  final int companyCodeId;
  final String name;
  final String code;
  final double baseAmount;
  final double discountAmount;
  final double discountedBaseAmount;
  final double vatAmount;
  final double totalAmount;
  final bool isFree;
  final String discountType;
  final double discountValue;

  CompanyCodeData({
    required this.valid,
    required this.companyCodeId,
    required this.name,
    required this.code,
    required this.baseAmount,
    required this.discountAmount,
    required this.discountedBaseAmount,
    required this.vatAmount,
    required this.totalAmount,
    required this.isFree,
    required this.discountType,
    required this.discountValue,
  });

  factory CompanyCodeData.fromJson(Map<String, dynamic> json) {
    return CompanyCodeData(
      valid: json['valid'] ?? false,
      companyCodeId: json['company_code_id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      baseAmount: (json['base_amount'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      discountedBaseAmount: (json['discounted_base_amount'] ?? 0).toDouble(),
      vatAmount: (json['vat_amount'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      isFree: json['is_free'] ?? false,
      discountType: json['discount_type'] ?? '',
      discountValue: (json['discount_value'] ?? 0).toDouble(),
    );
  }
}
