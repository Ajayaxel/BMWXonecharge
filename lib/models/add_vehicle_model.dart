import 'package:equatable/equatable.dart';

class AddVehicleRequest extends Equatable {
  final int vehicleTypeId;
  final int brandId;
  final int modelId;
  final int chargingTypeId;
  final String vehicleNumber;

  const AddVehicleRequest({
    required this.vehicleTypeId,
    required this.brandId,
    required this.modelId,
    required this.chargingTypeId,
    required this.vehicleNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicle_type_id': vehicleTypeId,
      'brand_id': brandId,
      'model_id': modelId,
      'charging_type_id': chargingTypeId,
      'vehicle_number': vehicleNumber,
    };
  }

  @override
  List<Object?> get props => [
    vehicleTypeId,
    brandId,
    modelId,
    chargingTypeId,
    vehicleNumber,
  ];
}

class AddVehicleResponse extends Equatable {
  final bool success;
  final String message;
  final VehicleData data;

  const AddVehicleResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AddVehicleResponse.fromJson(Map<String, dynamic> json) {
    return AddVehicleResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: VehicleData.fromJson(json['data']['vehicle']),
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}

class VehicleData extends Equatable {
  final int id;
  final int customerId;
  final int vehicleTypeId;
  final int brandId;
  final int modelId;
  final int chargingTypeId;
  final String vehicleNumber;
  final String createdAt;
  final String updatedAt;
  final VehicleTypeData? vehicleType;
  final BrandData? brand;
  final ModelData? model;
  final ChargingTypeData? chargingType;

  const VehicleData({
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

  factory VehicleData.fromJson(Map<String, dynamic> json) {
    return VehicleData(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      vehicleTypeId: json['vehicle_type_id'] ?? 0,
      brandId: json['brand_id'] ?? 0,
      modelId: json['model_id'] ?? 0,
      chargingTypeId: json['charging_type_id'] ?? 0,
      vehicleNumber: json['vehicle_number'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      vehicleType: json['vehicle_type'] != null
          ? VehicleTypeData.fromJson(json['vehicle_type'])
          : null,
      brand: json['brand'] != null ? BrandData.fromJson(json['brand']) : null,
      model: json['model'] != null ? ModelData.fromJson(json['model']) : null,
      chargingType: json['charging_type'] != null
          ? ChargingTypeData.fromJson(json['charging_type'])
          : null,
    );
  }

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

class VehicleTypeData extends Equatable {
  final int id;
  final String name;
  final bool status;
  final String createdAt;
  final String updatedAt;

  const VehicleTypeData({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleTypeData.fromJson(Map<String, dynamic> json) {
    return VehicleTypeData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, status, createdAt, updatedAt];
}

class BrandData extends Equatable {
  final int id;
  final String name;
  final int vehicleTypeId;
  final String image;
  final String createdAt;
  final String updatedAt;

  const BrandData({
    required this.id,
    required this.name,
    required this.vehicleTypeId,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BrandData.fromJson(Map<String, dynamic> json) {
    return BrandData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      vehicleTypeId: json['vehicle_type_id'] ?? 0,
      image: json['image'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    vehicleTypeId,
    image,
    createdAt,
    updatedAt,
  ];
}

class ModelData extends Equatable {
  final int id;
  final String name;
  final int brandId;
  final String image;
  final String createdAt;
  final String updatedAt;

  const ModelData({
    required this.id,
    required this.name,
    required this.brandId,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ModelData.fromJson(Map<String, dynamic> json) {
    return ModelData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      brandId: json['brand_id'] ?? 0,
      image: json['image'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, brandId, image, createdAt, updatedAt];
}

class ChargingTypeData extends Equatable {
  final int id;
  final String name;
  final bool status;
  final String createdAt;
  final String updatedAt;

  const ChargingTypeData({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChargingTypeData.fromJson(Map<String, dynamic> json) {
    return ChargingTypeData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, status, createdAt, updatedAt];
}
