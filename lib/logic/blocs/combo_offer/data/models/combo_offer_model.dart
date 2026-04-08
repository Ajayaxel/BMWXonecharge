import 'package:onecharge/models/product_model.dart';

class ComboOfferResponse {
  final bool success;
  final List<ComboOfferModel> data;

  ComboOfferResponse({required this.success, required this.data});

  factory ComboOfferResponse.fromJson(Map<String, dynamic> json) {
    return ComboOfferResponse(
      success: json['success'] ?? false,
      data: (json['data']['combo_offers'] as List? ?? [])
          .map((i) => ComboOfferModel.fromJson(i))
          .toList(),
    );
  }
}

class ComboOfferModel {
  final int id;
  final String name;
  final String description;
  final String originalPrice;
  final String discountPercentage;
  final String comboPrice;
  final String image;
  final String imageUrl;
  final List<ProductModel> products;
  final List<ComboServiceModel> services;

  ComboOfferModel({
    required this.id,
    required this.name,
    required this.description,
    required this.originalPrice,
    required this.discountPercentage,
    required this.comboPrice,
    required this.image,
    required this.imageUrl,
    required this.products,
    required this.services,
  });

  factory ComboOfferModel.fromJson(Map<String, dynamic> json) {
    return ComboOfferModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      originalPrice: json['original_price']?.toString() ?? '0.00',
      discountPercentage: json['discount_percentage']?.toString() ?? '0.00',
      comboPrice: json['combo_price']?.toString() ?? '0.00',
      image: json['image'] ?? '',
      imageUrl: json['image_url'] ?? '',
      products: (json['products'] as List? ?? [])
          .map((i) => ProductModel.fromJson(i)..comboPivot = ComboProductPivot.fromJson(i['pivot'] ?? {}))
          .toList(),
      services: (json['services'] as List? ?? [])
          .map((i) => ComboServiceModel.fromJson(i))
          .toList(),
    );
  }
}

class ComboServiceModel {
  final int id;
  final String name;
  final String serviceCharge;
  final ComboServicePivot pivot;

  ComboServiceModel({
    required this.id,
    required this.name,
    required this.serviceCharge,
    required this.pivot,
  });

  factory ComboServiceModel.fromJson(Map<String, dynamic> json) {
    return ComboServiceModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      serviceCharge: json['service_charge']?.toString() ?? '0.00',
      pivot: ComboServicePivot.fromJson(json['pivot'] ?? {}),
    );
  }
}

class ComboServicePivot {
  final int comboOfferId;
  final int issueCategoryId;
  final int quantity;
  final int? issueCategorySubTypeId;
  final String? serviceCost;
  final String? serviceCharge;
  final String? vatAmount;

  ComboServicePivot({
    required this.comboOfferId,
    required this.issueCategoryId,
    required this.quantity,
    this.issueCategorySubTypeId,
    this.serviceCost,
    this.serviceCharge,
    this.vatAmount,
  });

  factory ComboServicePivot.fromJson(Map<String, dynamic> json) {
    return ComboServicePivot(
      comboOfferId: json['combo_offer_id'] ?? 0,
      issueCategoryId: json['issue_category_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      issueCategorySubTypeId: json['issue_category_sub_type_id'],
      serviceCost: json['service_cost']?.toString(),
      serviceCharge: json['service_charge']?.toString(),
      vatAmount: json['vat_amount']?.toString(),
    );
  }
}
