import 'package:equatable/equatable.dart';

class VehicleListResponse extends Equatable {
  final bool success;
  final List<VehicleListItem> vehicles;

  const VehicleListResponse({
    required this.success,
    required this.vehicles,
  });

  factory VehicleListResponse.fromJson(Map<String, dynamic> json) {
    return VehicleListResponse(
      success: json['success'] ?? false,
      vehicles: (json['data']['vehicles'] as List<dynamic>)
          .map((v) => VehicleListItem.fromJson(v))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [success, vehicles];
}

class VehicleListItem extends Equatable {
  final int id;
  final int customerId;
  final int vehicleTypeId;
  final int brandId;
  final int modelId;
  final int chargingTypeId;
  final String vehicleNumber;
  final String createdAt;
  final String updatedAt;
  final VehicleTypeInfo? vehicleType;
  final BrandInfo? brand;
  final ModelInfo? model;
  final ChargingTypeInfo? chargingType;

  const VehicleListItem({
    required this.id,
    required this.customerId,
    required this.vehicleTypeId,
    required this.brandId,
    required this.modelId,
    required this.chargingTypeId,
    required this.vehicleNumber,
    required this.createdAt,
    required this.updatedAt,
    this.vehicleType,
    this.brand,
    this.model,
    this.chargingType,
  });

  factory VehicleListItem.fromJson(Map<String, dynamic> json) {
    return VehicleListItem(
      id: json['id'],
      customerId: json['customer_id'],
      vehicleTypeId: json['vehicle_type_id'],
      brandId: json['brand_id'],
      modelId: json['model_id'],
      chargingTypeId: json['charging_type_id'],
      vehicleNumber: json['vehicle_number'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      vehicleType: json['vehicle_type'] != null
          ? VehicleTypeInfo.fromJson(json['vehicle_type'])
          : null,
      brand: json['brand'] != null ? BrandInfo.fromJson(json['brand']) : null,
      model: json['model'] != null ? ModelInfo.fromJson(json['model']) : null,
      chargingType: json['charging_type'] != null
          ? ChargingTypeInfo.fromJson(json['charging_type'])
          : null,
    );
  }

  // Helper getters for easy access
  String get vehicleName => model?.name ?? 'Unknown Vehicle';
  String get vehicleImage => model?.image ?? '';

  @override
  List<Object?> get props => [
        id,
        customerId,
        vehicleTypeId,
        brandId,
        modelId,
        chargingTypeId,
        vehicleNumber,
        createdAt,
        updatedAt,
        vehicleType,
        brand,
        model,
        chargingType,
      ];
}

class VehicleTypeInfo extends Equatable {
  final int id;
  final String name;
  final bool status;
  final String createdAt;
  final String updatedAt;

  const VehicleTypeInfo({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleTypeInfo.fromJson(Map<String, dynamic> json) {
    return VehicleTypeInfo(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  @override
  List<Object?> get props => [id, name, status, createdAt, updatedAt];
}

class BrandInfo extends Equatable {
  final int id;
  final String name;
  final int vehicleTypeId;
  final String image;
  final String createdAt;
  final String updatedAt;

  const BrandInfo({
    required this.id,
    required this.name,
    required this.vehicleTypeId,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BrandInfo.fromJson(Map<String, dynamic> json) {
    return BrandInfo(
      id: json['id'],
      name: json['name'],
      vehicleTypeId: json['vehicle_type_id'],
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  @override
  List<Object?> get props => [id, name, vehicleTypeId, image, createdAt, updatedAt];
}

class ModelInfo extends Equatable {
  final int id;
  final String name;
  final int brandId;
  final String image;
  final String createdAt;
  final String updatedAt;

  const ModelInfo({
    required this.id,
    required this.name,
    required this.brandId,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      id: json['id'],
      name: json['name'],
      brandId: json['brand_id'],
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  @override
  List<Object?> get props => [id, name, brandId, image, createdAt, updatedAt];
}

class ChargingTypeInfo extends Equatable {
  final int id;
  final String name;
  final bool status;
  final String createdAt;
  final String updatedAt;

  const ChargingTypeInfo({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChargingTypeInfo.fromJson(Map<String, dynamic> json) {
    return ChargingTypeInfo(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  @override
  List<Object?> get props => [id, name, status, createdAt, updatedAt];
}
