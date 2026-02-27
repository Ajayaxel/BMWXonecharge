import 'package:equatable/equatable.dart';

class VehicleModel extends Equatable {
  final int id;
  final String name;
  final int brandId;
  final String image;
  final ModelBrand? brand;
  final VehicleCategory? vehicleCategory;

  const VehicleModel({
    required this.id,
    required this.name,
    required this.brandId,
    required this.image,
    this.brand,
    this.vehicleCategory,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      brandId: json['brand_id'] ?? 0,
      image: json['image'] ?? '',
      brand: json['brand'] != null ? ModelBrand.fromJson(json['brand']) : null,
      vehicleCategory: json['vehicle_category'] != null
          ? VehicleCategory.fromJson(json['vehicle_category'])
          : null,
    );
  }

  // Getter to provide fallback logic
  String get vehicleImage {
    if (image.isNotEmpty) return image;
    return brand?.image ?? '';
  }

  @override
  List<Object?> get props => [id, name, brandId, image, brand, vehicleCategory];
}

class ModelBrand extends Equatable {
  final int id;
  final String name;
  final String image;

  const ModelBrand({required this.id, required this.name, required this.image});

  factory ModelBrand.fromJson(Map<String, dynamic> json) {
    return ModelBrand(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, image];
}

class VehicleCategory extends Equatable {
  final int id;
  final String name;

  const VehicleCategory({required this.id, required this.name});

  factory VehicleCategory.fromJson(Map<String, dynamic> json) {
    return VehicleCategory(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  @override
  List<Object?> get props => [id, name];
}
