class ProductResponse {
  final bool success;
  final ProductPaginationData data;

  ProductResponse({required this.success, required this.data});

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      success: json['success'] ?? false,
      data: ProductPaginationData.fromJson(json['data']),
    );
  }
}

class ProductDetailResponse {
  final bool success;
  final ProductModel data;

  ProductDetailResponse({required this.success, required this.data});

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailResponse(
      success: json['success'] ?? false,
      data: ProductModel.fromJson(json['data']),
    );
  }
}

class ProductPaginationData {
  final int currentPage;
  final List<ProductModel> data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final String? nextPageUrl;
  final String? path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  ProductPaginationData({
    required this.currentPage,
    required this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    required this.perPage,
    this.prevPageUrl,
    this.to,
    required this.total,
  });

  factory ProductPaginationData.fromJson(Map<String, dynamic> json) {
    return ProductPaginationData(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List? ?? [])
          .map((i) => ProductModel.fromJson(i))
          .toList(),
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'] ?? 15,
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'] ?? 0,
    );
  }
}

class ProductModel {
  final int id;
  final String name;
  final String slug;
  final String sku;
  final String? image;
  final String shortDescription;
  final String description;
  final String? keyFeature;
  final double price;
  final String currency;
  final int stock;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final bool isWishlisted;
  final String? subtitle;
  final String? backgroundColor;
  final List<ProductImageModel>? images;
  ComboProductPivot? comboPivot;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.sku,
    this.image,
    required this.shortDescription,
    required this.description,
    this.keyFeature,
    required this.price,
    required this.currency,
    required this.stock,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.isWishlisted = false,
    this.subtitle,
    this.backgroundColor,
    this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? json['product_id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      sku: json['sku'] ?? '',
      image: json['primary_image'] ?? json['image'] ?? json['image_url'],
      shortDescription: json['short_description'] ?? '',
      description: json['description'] ?? '',
      keyFeature: json['key_feature'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      currency: json['currency'] ?? 'AED',
      stock: json['stock'] ?? 0,
      isActive: (json['is_active'] == 1 || json['is_active'] == true),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isWishlisted: (json['is_wishlist'] == 1 || json['is_wishlist'] == true),
      subtitle: json['subtitle'],
      backgroundColor: json['background_color'],
      images: json['images'] != null
          ? (json['images'] as List)
              .map((i) => ProductImageModel.fromJson(i))
              .toList()
          : null,
    );
  }

  // Helper to get the main image
  String get mainImage {
    // If we have a full image URL, use it
    if (image != null && image!.isNotEmpty) {
      if (image!.startsWith('http')) return image!;
      return 'https://app.onecharge.io/storage/$image';
    }

    // Try to get from images list
    if (images != null && images!.isNotEmpty) {
      final primary = images!.firstWhere(
        (img) => img.isPrimary,
        orElse: () => images!.first,
      );
      if (primary.path.isNotEmpty) {
        if (primary.path.startsWith('http')) return primary.path;
        return 'https://app.onecharge.io/storage/${primary.path}';
      }
    }
    return '';
  }
}

class ProductImageModel {
  final int id;
  final int? productId;
  final String path;
  final bool isPrimary;
  final int sortOrder;
  final String? createdAt;
  final String? updatedAt;

  ProductImageModel({
    required this.id,
    this.productId,
    required this.path,
    required this.isPrimary,
    required this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] ?? 0,
      productId: json['product_id'],
      path: json['url'] ?? json['path'] ?? '',
      isPrimary: json['is_primary'] ?? false,
      sortOrder: json['sort_order'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class ShopCategoryResponse {
  final bool success;
  final List<ShopCategoryModel> data;

  ShopCategoryResponse({required this.success, required this.data});

  factory ShopCategoryResponse.fromJson(Map<String, dynamic> json) {
    return ShopCategoryResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List? ?? [])
          .map((i) => ShopCategoryModel.fromJson(i))
          .toList(),
    );
  }
}

class ShopCategoryModel {
  final int id;
  final String name;
  final String slug;
  final List<ProductModel> products;

  ShopCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.products,
  });

  factory ShopCategoryModel.fromJson(Map<String, dynamic> json) {
    return ShopCategoryModel(
      id: json['id'] ?? json['category_id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      products: (json['products'] as List? ?? [])
          .map((i) => ProductModel.fromJson(i))
          .toList(),
    );
  }
}

class ComboProductPivot {
  final int comboOfferId;
  final int productId;
  final int quantity;

  ComboProductPivot({
    required this.comboOfferId,
    required this.productId,
    required this.quantity,
  });

  factory ComboProductPivot.fromJson(Map<String, dynamic> json) {
    return ComboProductPivot(
      comboOfferId: json['combo_offer_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
    );
  }
}
