import 'package:equatable/equatable.dart';

class VehicleModel extends Equatable {
  final int id;
  final String name;
  final int brandId;
  final String image;
  final ModelBrand? brand;

  const VehicleModel({
    required this.id,
    required this.name,
    required this.brandId,
    required this.image,
    this.brand,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      name: json['name'],
      brandId: json['brand_id'],
      image: json['image'],
      brand: json['brand'] != null ? ModelBrand.fromJson(json['brand']) : null,
    );
  }

  @override
  List<Object?> get props => [id, name, brandId, image, brand];
}

class ModelBrand extends Equatable {
  final int id;
  final String name;

  const ModelBrand({required this.id, required this.name});

  factory ModelBrand.fromJson(Map<String, dynamic> json) {
    return ModelBrand(id: json['id'], name: json['name']);
  }

  @override
  List<Object?> get props => [id, name];
}
