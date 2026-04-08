import 'package:equatable/equatable.dart';
import 'product_model.dart';

class ProductGroupsResponse extends Equatable {
  final bool success;
  final List<ProductGroupModel> productGroups;

  const ProductGroupsResponse({
    required this.success,
    required this.productGroups,
  });

  factory ProductGroupsResponse.fromJson(Map<String, dynamic> json) {
    return ProductGroupsResponse(
      success: json['success'] ?? false,
      productGroups: (json['data']['product_groups'] as List<dynamic>?)
              ?.map((item) => ProductGroupModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [success, productGroups];
}

class ProductGroupModel extends Equatable {
  final int id;
  final String name;
  final List<ProductModel> products;

  const ProductGroupModel({
    required this.id,
    required this.name,
    required this.products,
  });

  factory ProductGroupModel.fromJson(Map<String, dynamic> json) {
    return ProductGroupModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      products: (json['products'] as List<dynamic>?)
              ?.map((item) => ProductModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, name, products];
}
