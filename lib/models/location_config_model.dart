import 'package:equatable/equatable.dart';

class LocationConfigResponse extends Equatable {
  final bool success;
  final LocationConfigData data;

  const LocationConfigResponse({
    required this.success,
    required this.data,
  });

  factory LocationConfigResponse.fromJson(Map<String, dynamic> json) {
    return LocationConfigResponse(
      success: json['success'] ?? false,
      data: LocationConfigData.fromJson(json['data'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [success, data];
}

class LocationConfigData extends Equatable {
  final List<AddressType> addressTypes;
  final List<dynamic> locationContextTypes;

  const LocationConfigData({
    required this.addressTypes,
    required this.locationContextTypes,
  });

  factory LocationConfigData.fromJson(Map<String, dynamic> json) {
    return LocationConfigData(
      addressTypes: (json['address_types'] as List? ?? [])
          .map((e) => AddressType.fromJson(e as Map<String, dynamic>))
          .toList(),
      locationContextTypes: json['location_context_types'] as List? ?? [],
    );
  }

  @override
  List<Object?> get props => [addressTypes, locationContextTypes];
}

class AddressType extends Equatable {
  final int id;
  final String name;
  final String? iconUrl;
  final int sortOrder;
  final List<PropertyType> propertyTypes;

  const AddressType({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.sortOrder,
    required this.propertyTypes,
  });

  factory AddressType.fromJson(Map<String, dynamic> json) {
    return AddressType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      iconUrl: json['icon_url'],
      sortOrder: json['sort_order'] ?? 0,
      propertyTypes: (json['property_types'] as List? ?? [])
          .map((e) => PropertyType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, iconUrl, sortOrder, propertyTypes];
}

class PropertyType extends Equatable {
  final int id;
  final String name;
  final int sortOrder;
  final List<FloorType> floorTypes;

  const PropertyType({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.floorTypes,
  });

  factory PropertyType.fromJson(Map<String, dynamic> json) {
    return PropertyType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
      floorTypes: (json['floor_types'] as List? ?? [])
          .map((e) => FloorType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, sortOrder, floorTypes];
}

class FloorType extends Equatable {
  final int id;
  final String code;
  final String name;
  final int sortOrder;
  final List<FloorNumber> floorNumbers;

  const FloorType({
    required this.id,
    required this.code,
    required this.name,
    required this.sortOrder,
    required this.floorNumbers,
  });

  factory FloorType.fromJson(Map<String, dynamic> json) {
    return FloorType(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
      floorNumbers: (json['floor_numbers'] as List? ?? [])
          .map((e) => FloorNumber.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, code, name, sortOrder, floorNumbers];
}

class FloorNumber extends Equatable {
  final int id;
  final String label;
  final int sortOrder;

  const FloorNumber({
    required this.id,
    required this.label,
    required this.sortOrder,
  });

  factory FloorNumber.fromJson(Map<String, dynamic> json) {
    return FloorNumber(
      id: json['id'] ?? 0,
      label: json['label'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, label, sortOrder];
}
