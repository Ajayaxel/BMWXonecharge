import 'package:equatable/equatable.dart';

class ServiceGroup extends Equatable {
  final int id;
  final String name;
  final List<ServiceIssueCategory> issueCategories;

  const ServiceGroup({
    required this.id,
    required this.name,
    required this.issueCategories,
  });

  factory ServiceGroup.fromJson(Map<String, dynamic> json) {
    return ServiceGroup(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      issueCategories: (json['issue_categories'] as List<dynamic>?)
              ?.map((item) => ServiceIssueCategory.fromJson(item))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, name, issueCategories];
}

class ServiceIssueCategory extends Equatable {
  final int id;
  final String? name;
  final String serviceCost;
  final String serviceCharge;
  final String vat;
  final String? image;
  final String? imageUrl;
  final List<ServiceIssueSubType> subTypes;
  final ServiceGroupPivot? pivot;

  const ServiceIssueCategory({
    required this.id,
    this.name,
    required this.serviceCost,
    required this.serviceCharge,
    required this.vat,
    this.image,
    this.imageUrl,
    required this.subTypes,
    this.pivot,
  });

  factory ServiceIssueCategory.fromJson(Map<String, dynamic> json) {
    return ServiceIssueCategory(
      id: json['id'] ?? 0,
      name: json['name'],
      serviceCost: json['service_cost']?.toString() ?? '0.00',
      serviceCharge: json['service_charge']?.toString() ?? '0.00',
      vat: json['vat']?.toString() ?? '0.00',
      image: json['image'],
      imageUrl: json['image_url'],
      subTypes: (json['sub_types'] as List<dynamic>?)
              ?.map((item) => ServiceIssueSubType.fromJson(item))
              .toList() ??
          [],
      pivot: json['pivot'] != null ? ServiceGroupPivot.fromJson(json['pivot']) : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        serviceCost,
        serviceCharge,
        vat,
        image,
        imageUrl,
        subTypes,
        pivot,
      ];
}

class ServiceIssueSubType extends Equatable {
  final int id;
  final int issueCategoryId;
  final String? name;
  final String serviceCost;
  final String serviceCharge;
  final String vat;
  final String? iconImage;
  final String? iconImageUrl;

  const ServiceIssueSubType({
    required this.id,
    required this.issueCategoryId,
    this.name,
    required this.serviceCost,
    required this.serviceCharge,
    required this.vat,
    this.iconImage,
    this.iconImageUrl,
  });

  factory ServiceIssueSubType.fromJson(Map<String, dynamic> json) {
    return ServiceIssueSubType(
      id: json['id'] ?? 0,
      issueCategoryId: json['issue_category_id'] ?? 0,
      name: json['name'],
      serviceCost: json['service_cost']?.toString() ?? '0.00',
      serviceCharge: json['service_charge']?.toString() ?? '0.00',
      vat: json['vat']?.toString() ?? '0.00',
      iconImage: json['icon_image'],
      iconImageUrl: json['icon_image_url'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        issueCategoryId,
        name,
        serviceCost,
        serviceCharge,
        vat,
        iconImage,
        iconImageUrl,
      ];
}

class ServiceGroupPivot extends Equatable {
  final int serviceGroupId;
  final int issueCategoryId;

  const ServiceGroupPivot({
    required this.serviceGroupId,
    required this.issueCategoryId,
  });

  factory ServiceGroupPivot.fromJson(Map<String, dynamic> json) {
    return ServiceGroupPivot(
      serviceGroupId: json['service_group_id'] ?? 0,
      issueCategoryId: json['issue_category_id'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [serviceGroupId, issueCategoryId];
}
