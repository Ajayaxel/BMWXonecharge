import 'package:equatable/equatable.dart';

class LocationModel extends Equatable {
  final int? id;
  final int? customerId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int? addressTypeId;
  final int? propertyTypeId;
  final int? floorTypeId;
  final int? floorNumberId;
  final String? towerBuildingName;
  final String? roadArea;
  final String? directionToReach;
  final String? additionalInfo;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic addressType;
  final dynamic propertyType;
  final dynamic floorType;
  final dynamic floorNumber;

  const LocationModel({
    this.id,
    this.customerId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.addressTypeId,
    this.propertyTypeId,
    this.floorTypeId,
    this.floorNumberId,
    this.towerBuildingName,
    this.roadArea,
    this.directionToReach,
    this.additionalInfo,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
    this.addressType,
    this.propertyType,
    this.floorType,
    this.floorNumber,
  });

  factory LocationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LocationModel(
        name: '',
        address: '',
        latitude: 0.0,
        longitude: 0.0,
      );
    }
    return LocationModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      customerId: json['customer_id'] is int
          ? json['customer_id'] as int
          : int.tryParse(json['customer_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0.0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0.0') ?? 0.0,
      addressTypeId: json['address_type_id'] is int
          ? json['address_type_id'] as int
          : int.tryParse(json['address_type_id']?.toString() ?? ''),
      propertyTypeId: json['property_type_id'] is int
          ? json['property_type_id'] as int
          : int.tryParse(json['property_type_id']?.toString() ?? ''),
      floorTypeId: json['floor_type_id'] is int
          ? json['floor_type_id'] as int
          : int.tryParse(json['floor_type_id']?.toString() ?? ''),
      floorNumberId: json['floor_number_id'] is int
          ? json['floor_number_id'] as int
          : int.tryParse(json['floor_number_id']?.toString() ?? ''),
      towerBuildingName: json['tower_building_name']?.toString(),
      roadArea: json['road_area']?.toString(),
      directionToReach: json['direction_to_reach']?.toString(),
      additionalInfo: json['additional_info']?.toString(),
      isDefault: json['is_default'] == 1 ||
          json['is_default'] == true ||
          json['is_default']?.toString().toLowerCase() == 'true',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      addressType: json['address_type'],
      propertyType: json['property_type'],
      floorType: json['floor_type'],
      floorNumber: json['floor_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      'name': name,
      'address': address,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'address_type_id': addressTypeId,
      'property_type_id': propertyTypeId,
      'floor_type_id': floorTypeId,
      'floor_number_id': floorNumberId,
      'tower_building_name': towerBuildingName,
      'road_area': roadArea,
      'direction_to_reach': directionToReach,
      'additional_info': additionalInfo,
      'is_default': isDefault,
    };
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        name,
        address,
        latitude,
        longitude,
        addressTypeId,
        propertyTypeId,
        floorTypeId,
        floorNumberId,
        towerBuildingName,
        roadArea,
        directionToReach,
        additionalInfo,
        isDefault,
        createdAt,
        updatedAt,
        addressType,
        propertyType,
        floorType,
        floorNumber,
      ];

  LocationModel copyWith({
    int? id,
    int? customerId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? addressTypeId,
    int? propertyTypeId,
    int? floorTypeId,
    int? floorNumberId,
    String? towerBuildingName,
    String? roadArea,
    String? directionToReach,
    String? additionalInfo,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LocationModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressTypeId: addressTypeId ?? this.addressTypeId,
      propertyTypeId: propertyTypeId ?? this.propertyTypeId,
      floorTypeId: floorTypeId ?? this.floorTypeId,
      floorNumberId: floorNumberId ?? this.floorNumberId,
      towerBuildingName: towerBuildingName ?? this.towerBuildingName,
      roadArea: roadArea ?? this.roadArea,
      directionToReach: directionToReach ?? this.directionToReach,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      addressType: addressType,
      propertyType: propertyType,
      floorType: floorType,
      floorNumber: floorNumber,
    );
  }
}

class LocationListResponse extends Equatable {
  final bool success;
  final LocationListData data;

  const LocationListResponse({
    required this.success,
    required this.data,
  });

  factory LocationListResponse.fromJson(Map<String, dynamic> json) {
    return LocationListResponse(
      success: json['success'] ?? false,
      data: LocationListData.fromJson(json['data'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [success, data];
}

class LocationListData extends Equatable {
  final List<LocationModel> locations;
  final MetaData? meta;

  const LocationListData({
    required this.locations,
    this.meta,
  });

  factory LocationListData.fromJson(Map<String, dynamic> json) {
    return LocationListData(
      locations: (json['locations'] as List? ?? [])
          .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] != null
          ? MetaData.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [locations, meta];
}

class MetaData extends Equatable {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const MetaData({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory MetaData.fromJson(Map<String, dynamic> json) {
    return MetaData(
      currentPage: json['current_page'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      perPage: json['per_page'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [currentPage, lastPage, perPage, total];
}
