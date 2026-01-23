import 'package:equatable/equatable.dart';

class ChargingType extends Equatable {
  final int id;
  final String name;

  const ChargingType({
    required this.id,
    required this.name,
  });

  factory ChargingType.fromJson(Map<String, dynamic> json) {
    return ChargingType(
      id: json['id'],
      name: json['name'],
    );
  }

  @override
  List<Object?> get props => [id, name];
}
