import 'package:onecharge/models/product_model.dart';

class CartResponse {
  final bool success;
  final CartData data;

  CartResponse({required this.success, required this.data});

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      success: json['success'] ?? false,
      data: CartData.fromJson(json['data'] ?? {}),
    );
  }
}

class CartData {
  final List<CartItem> items;
  final double totalPrice;
  final int totalCount;
  final String currency;

  CartData({
    required this.items,
    required this.totalPrice,
    required this.totalCount,
    required this.currency,
  });

  factory CartData.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List? ?? [])
        .map((i) => CartItem.fromJson(i))
        .toList();
    
    return CartData(
      items: itemsList,
      totalPrice: double.tryParse(json['total'].toString()) ?? 0.0,
      totalCount: itemsList.fold(0, (sum, item) => sum + item.quantity),
      currency: json['currency'] ?? 'AED',
    );
  }
}

class CartItem {
  final int id;
  final ProductModel product;
  final int quantity;
  final double subtotal;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.subtotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = ProductModel.fromJson(json['product'] ?? {});
    final quantity = json['quantity'] ?? 1;
    // Calculate subtotal if not provided by API
    final subtotal = double.tryParse(json['sub_total'].toString()) ??
        (product.price * quantity);

    return CartItem(
      id: json['id'] ?? 0,
      product: product,
      quantity: quantity,
      subtotal: subtotal,
    );
  }
}
