import 'package:equatable/equatable.dart';

class LocationModel extends Equatable {
  final int? id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? additionalInfo;
  final bool isDefault;

  const LocationModel({
    this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.additionalInfo,
    this.isDefault = false,
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
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0.0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0.0') ?? 0.0,
      additionalInfo: json['additional_info']?.toString(),
      isDefault:
          json['is_default'] == 1 ||
          json['is_default'] == true ||
          json['is_default']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'additional_info': additionalInfo,
      'is_default': isDefault,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    latitude,
    longitude,
    additionalInfo,
    isDefault,
  ];

  LocationModel copyWith({
    int? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? additionalInfo,
    bool? isDefault,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
