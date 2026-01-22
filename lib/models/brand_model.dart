import 'package:equatable/equatable.dart';

class Brand extends Equatable {
  final int id;
  final String name;
  final int vehicleTypeId;
  final String image;
  final VehicleType? vehicleType;

  const Brand({
    required this.id,
    required this.name,
    required this.vehicleTypeId,
    required this.image,
    this.vehicleType,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      name: json['name'],
      vehicleTypeId: json['vehicle_type_id'],
      image: json['image'],
      vehicleType: json['vehicle_type'] != null
          ? VehicleType.fromJson(json['vehicle_type'])
          : null,
    );
  }

  @override
  List<Object?> get props => [id, name, vehicleTypeId, image, vehicleType];
}

class VehicleType extends Equatable {
  final int id;
  final String name;

  const VehicleType({required this.id, required this.name});

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(id: json['id'], name: json['name']);
  }

  @override
  List<Object?> get props => [id, name];
}
