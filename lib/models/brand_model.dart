import 'package:equatable/equatable.dart';

class Brand extends Equatable {
  final int id;
  final String name;
  final int? vehicleTypeId;
  final String image;
  final VehicleType? vehicleType;
  final List<VehicleCategory> vehicleCategories;

  const Brand({
    required this.id,
    required this.name,
    this.vehicleTypeId,
    required this.image,
    this.vehicleType,
    this.vehicleCategories = const [],
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      vehicleTypeId: json['vehicle_type_id'],
      image: json['image'] ?? '',
      vehicleType: json['vehicle_type'] != null
          ? VehicleType.fromJson(json['vehicle_type'])
          : null,
      vehicleCategories: json['vehicle_categories'] != null
          ? (json['vehicle_categories'] as List)
              .map((e) => VehicleCategory.fromJson(e))
              .toList()
          : [],
    );
  }

  @override
  List<Object?> get props =>
      [id, name, vehicleTypeId, image, vehicleType, vehicleCategories];
}

class VehicleType extends Equatable {
  final int? id;
  final String? name;

  const VehicleType({this.id, this.name});

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(id: json['id'], name: json['name']);
  }

  @override
  List<Object?> get props => [id, name];
}

class VehicleCategory extends Equatable {
  final int id;
  final String name;

  const VehicleCategory({required this.id, required this.name});

  factory VehicleCategory.fromJson(Map<String, dynamic> json) {
    return VehicleCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}
