import 'package:equatable/equatable.dart';

class IssueSubType extends Equatable {
  final int id;
  final int issueCategoryId;
  final String? name;
  final String serviceCost;
  final String serviceCharge;
  final String vat;

  const IssueSubType({
    required this.id,
    required this.issueCategoryId,
    this.name,
    required this.serviceCost,
    required this.serviceCharge,
    required this.vat,
  });

  factory IssueSubType.fromJson(Map<String, dynamic> json) {
    return IssueSubType(
      id: json['id'] ?? 0,
      issueCategoryId: json['issue_category_id'] ?? 0,
      name: json['name'],
      serviceCost: json['service_cost']?.toString() ?? '0.00',
      serviceCharge: json['service_charge']?.toString() ?? '0.00',
      vat: json['vat']?.toString() ?? '0.00',
    );
  }

  @override
  List<Object?> get props => [id, issueCategoryId, name, serviceCost, serviceCharge, vat];
}

class IssueCategory extends Equatable {
  final int id;
  final String? name;
  final String serviceCost;
  final String serviceCharge;
  final String vat;
  final List<IssueSubType> subTypes;

  const IssueCategory({
    required this.id,
    this.name,
    required this.serviceCost,
    required this.serviceCharge,
    required this.vat,
    required this.subTypes,
  });

  factory IssueCategory.fromJson(Map<String, dynamic> json) {
    return IssueCategory(
      id: json['id'] ?? 0,
      name: json['name'],
      serviceCost: json['service_cost']?.toString() ?? '0.00',
      serviceCharge: json['service_charge']?.toString() ?? '0.00',
      vat: json['vat']?.toString() ?? '0.00',
      subTypes: (json['sub_types'] as List<dynamic>?)
              ?.map((item) => IssueSubType.fromJson(item))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, name, serviceCost, serviceCharge, vat, subTypes];
}
