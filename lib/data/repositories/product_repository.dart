import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/cart_model.dart';
import 'package:onecharge/models/order_model.dart';
import 'package:onecharge/models/product_model.dart';

class ProductRepository {
  final ApiClient apiClient;

  ProductRepository({required this.apiClient});

  Future<ProductResponse> getProducts({int page = 1}) async {
    try {
      final response = await apiClient.get(
        '/customer/shop/products',
        queryParameters: {'page': page},
      );
      
      if (response.data['success'] == true) {
        return ProductResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to fetch products: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductDetailResponse> getProductDetail(int productId) async {
    try {
      final response = await apiClient.get('/customer/shop/products/$productId');
      if (response.data['success'] == true) {
        return ProductDetailResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to fetch product details: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addToWishlist(int productId) async {
    try {
      final response = await apiClient.post(
        '/customer/shop/wishlist',
        data: {'product_id': productId},
      );
      return response.data['success'] ?? false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> removeFromWishlist(int productId) async {
    try {
      final response = await apiClient.delete('/customer/shop/wishlist/$productId');
      return response.data['success'] ?? false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addToCart(int productId, int quantity) async {
    try {
      final response = await apiClient.post(
        '/customer/shop/cart',
        data: {
          'product_id': productId,
          'quantity': quantity,
        },
      );
      return response.data['success'] ?? false;
    } catch (e) {
      rethrow;
    }
  }

  Future<CartResponse> getCart() async {
    try {
      final response = await apiClient.get('/customer/shop/cart');
      if (response.data['success'] == true) {
        return CartResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to fetch cart: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> removeFromCart(int productId) async {
    try {
      final response = await apiClient.delete('/customer/shop/cart/$productId');
      return response.data['success'] ?? false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateCartQuantity(int productId, int quantity) async {
    try {
      final response = await apiClient.put(
        '/customer/shop/cart/$productId',
        data: {'quantity': quantity},
      );
      return response.data['success'] ?? false;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkout(Map<String, dynamic> checkoutData) async {
    try {
      final response = await apiClient.post(
        '/customer/shop/checkout',
        data: checkoutData,
      );
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(
          'Checkout failed: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<OrderResponse> getOrders({int page = 1}) async {
    try {
      final response = await apiClient.get(
        '/customer/shop/orders',
        queryParameters: {'page': page},
      );
      if (response.data['success'] == true) {
        return OrderResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to fetch orders: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<OrderDetailResponse> getOrderDetail(int orderId) async {
    try {
      final response = await apiClient.get('/customer/shop/orders/$orderId');
      if (response.data['success'] == true) {
        return OrderDetailResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to fetch order details: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ShopCategoryResponse> getCategories() async {
    try {
      final response = await apiClient.get('/customer/shop/categories');
      if (response.data['success'] == true) {
        return ShopCategoryResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to fetch categories: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
