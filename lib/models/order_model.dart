import 'package:onecharge/models/product_model.dart';

class OrderResponse {
  final bool success;
  final OrderPaginationData data;

  OrderResponse({required this.success, required this.data});

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      success: json['success'] ?? false,
      data: OrderPaginationData.fromJson(json['data']),
    );
  }
}

class OrderDetailResponse {
  final bool success;
  final OrderModel data;

  OrderDetailResponse({required this.success, required this.data});

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      success: json['success'] ?? false,
      data: OrderModel.fromJson(json['data']),
    );
  }
}

class OrderPaginationData {
  final int currentPage;
  final List<OrderModel> data;
  final int total;
  final int lastPage;

  OrderPaginationData({
    required this.currentPage,
    required this.data,
    required this.total,
    required this.lastPage,
  });

  factory OrderPaginationData.fromJson(Map<String, dynamic> json) {
    return OrderPaginationData(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List? ?? [])
          .map((i) => OrderModel.fromJson(i))
          .toList(),
      total: json['total'] ?? 0,
      lastPage: json['last_page'] ?? 1,
    );
  }
}

class OrderModel {
  final int id;
  final String orderNumber;
  final String status;
  final double totalAmount;
  final String currency;
  final String paymentMethod;
  final String paymentStatus;
  final String? paymobIntentionId;
  final String? paymobClientSecret;
  final AddressModel? shippingAddress;
  final String? notes;
  final String placedAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    required this.currency,
    required this.paymentMethod,
    required this.paymentStatus,
    this.paymobIntentionId,
    this.paymobClientSecret,
    this.shippingAddress,
    this.notes,
    required this.placedAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      status: json['status'] ?? 'pending',
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
      currency: json['currency'] ?? 'AED',
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? 'pending',
      paymobIntentionId: json['paymob_intention_id'],
      paymobClientSecret: json['paymob_client_secret'],
      shippingAddress: json['shipping_address'] != null
          ? AddressModel.fromJson(json['shipping_address'])
          : null,
      notes: json['notes'],
      placedAt: json['placed_at'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((i) => OrderItemModel.fromJson(i))
          .toList(),
    );
  }
}

class AddressModel {
  final String city;
  final String name;
  final String email;
  final String phone;
  final String address;

  AddressModel({
    required this.city,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      city: json['city'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class OrderItemModel {
  final int id;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double lineTotal;
  final ProductModel? product;

  OrderItemModel({
    required this.id,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    this.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? 0,
      productName: json['product_name'] ?? '',
      unitPrice: double.tryParse(json['unit_price'].toString()) ?? 0.0,
      quantity: json['quantity'] ?? 1,
      lineTotal: double.tryParse(json['line_total'].toString()) ?? 0.0,
      product: json['product'] != null ? ProductModel.fromJson(json['product']) : null,
    );
  }
}
