import 'package:equatable/equatable.dart';
import 'dart:io';

class CreateTicketRequest extends Equatable {
  final int issueCategoryId;
  final int? issueCategorySubTypeId;
  final int vehicleTypeId;
  final int brandId;
  final int modelId;
  final String numberPlate;
  final String? description;
  final String location;
  final double latitude;
  final double longitude;
  final List<File>? attachments;
  final String? redeemCode;

  const CreateTicketRequest({
    required this.issueCategoryId,
    this.issueCategorySubTypeId,
    required this.vehicleTypeId,
    required this.brandId,
    required this.modelId,
    required this.numberPlate,
    this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.attachments,
    this.redeemCode,
  });

  @override
  List<Object?> get props => [
        issueCategoryId,
        issueCategorySubTypeId,
        vehicleTypeId,
        brandId,
        modelId,
        numberPlate,
        description,
        location,
        latitude,
        longitude,
        attachments,
        redeemCode,
      ];
}

class CreateTicketResponse extends Equatable {
  final bool success;
  final String message;
  final TicketData? data;

  const CreateTicketResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateTicketResponse.fromJson(Map<String, dynamic> json) {
    return CreateTicketResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? TicketData.fromJson(json['data']) : null,
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}

class TicketData extends Equatable {
  final bool paymentRequired;
  final String? paymentUrl;
  final String? intentionId;
  final String? clientSecret;
  final PaymentBreakdown? paymentBreakdown;
  final Ticket? ticket;

  const TicketData({
    required this.paymentRequired,
    this.paymentUrl,
    this.intentionId,
    this.clientSecret,
    this.paymentBreakdown,
    this.ticket,
  });

  factory TicketData.fromJson(Map<String, dynamic> json) {
    return TicketData(
      paymentRequired: json['payment_required'] ?? false,
      paymentUrl: json['payment_url'],
      intentionId: json['intention_id'],
      clientSecret: json['client_secret'],
      paymentBreakdown: json['payment_breakdown'] != null
          ? PaymentBreakdown.fromJson(json['payment_breakdown'])
          : null,
      ticket: json['ticket'] != null ? Ticket.fromJson(json['ticket']) : null,
    );
  }

  @override
  List<Object?> get props => [
        paymentRequired,
        paymentUrl,
        intentionId,
        clientSecret,
        paymentBreakdown,
        ticket,
      ];
}

class Ticket extends Equatable {
  final int id;
  final String ticketId;
  final int customerId;
  final String? paymentMethod;
  final String? bookingType;
  final String? scheduledAt;
  final TicketIssueCategory? issueCategory;
  final TicketIssueCategorySubType? issueCategorySubType;
  final String? location;
  final String? latitude;
  final String? longitude;
  final String? status;
  final TicketDriver? driver;
  final List<String> attachments;
  final TicketInvoice? invoice;
  final String? createdAt;
  final String? updatedAt;

  const Ticket({
    required this.id,
    required this.ticketId,
    required this.customerId,
    this.paymentMethod,
    this.bookingType,
    this.scheduledAt,
    this.issueCategory,
    this.issueCategorySubType,
    this.location,
    this.latitude,
    this.longitude,
    this.status,
    this.driver,
    this.attachments = const [],
    this.invoice,
    this.createdAt,
    this.updatedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] ?? 0,
      ticketId: json['ticket_id'] ?? '',
      customerId: json['customer_id'] ?? 0,
      paymentMethod: json['payment_method'],
      bookingType: json['booking_type'],
      scheduledAt: json['scheduled_at'],
      issueCategory: json['issue_category'] != null
          ? TicketIssueCategory.fromJson(json['issue_category'])
          : null,
      issueCategorySubType: json['issue_category_sub_type'] != null
          ? TicketIssueCategorySubType.fromJson(json['issue_category_sub_type'])
          : null,
      location: json['location'],
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      status: json['status'],
      driver: json['driver'] != null
          ? TicketDriver.fromJson(json['driver'])
          : null,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : [],
      invoice: json['invoice'] != null
          ? TicketInvoice.fromJson(json['invoice'])
          : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        ticketId,
        customerId,
        paymentMethod,
        bookingType,
        scheduledAt,
        issueCategory,
        issueCategorySubType,
        location,
        latitude,
        longitude,
        status,
        driver,
        attachments,
        invoice,
        createdAt,
        updatedAt,
      ];
}

class TicketIssueCategory extends Equatable {
  final int id;
  final String name;

  const TicketIssueCategory({
    required this.id,
    required this.name,
  });

  factory TicketIssueCategory.fromJson(Map<String, dynamic> json) {
    return TicketIssueCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}

class TicketIssueCategorySubType extends Equatable {
  final int id;
  final String name;
  final double serviceCost;
  final double serviceCharge;
  final double vat;

  const TicketIssueCategorySubType({
    required this.id,
    required this.name,
    this.serviceCost = 0,
    this.serviceCharge = 0,
    this.vat = 0,
  });

  factory TicketIssueCategorySubType.fromJson(Map<String, dynamic> json) {
    return TicketIssueCategorySubType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      serviceCost: (json['service_cost'] ?? 0).toDouble(),
      serviceCharge: (json['service_charge'] ?? 0).toDouble(),
      vat: (json['vat'] ?? 0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, name, serviceCost, serviceCharge, vat];
}

class TicketDriver extends Equatable {
  final int? id;
  final String? name;
  final String? phone;
  final String? image;

  const TicketDriver({
    this.id,
    this.name,
    this.phone,
    this.image,
  });

  factory TicketDriver.fromJson(Map<String, dynamic> json) {
    return TicketDriver(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      image: json['image'],
    );
  }

  @override
  List<Object?> get props => [id, name, phone, image];
}

class TicketInvoice extends Equatable {
  final int id;
  final String invoiceNumber;
  final String invoiceUrl;
  final double subtotal;
  final double vatAmount;
  final double discountAmount;
  final double totalAmount;
  final String currency;
  final String? createdAt;

  const TicketInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceUrl,
    required this.subtotal,
    required this.vatAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.currency,
    this.createdAt,
  });

  factory TicketInvoice.fromJson(Map<String, dynamic> json) {
    return TicketInvoice(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      invoiceUrl: json['invoice_url'] ?? '',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      vatAmount: (json['vat_amount'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'AED',
      createdAt: json['created_at'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        invoiceUrl,
        subtotal,
        vatAmount,
        discountAmount,
        totalAmount,
        currency,
        createdAt,
      ];
}

class PaymentBreakdown extends Equatable {
  final double baseAmount;
  final double vatAmount;
  final double totalAmount;
  final String currency;
  final bool discountApplied;
  final double discountAmount;
  final String? redeemCode;

  const PaymentBreakdown({
    required this.baseAmount,
    required this.vatAmount,
    required this.totalAmount,
    required this.currency,
    required this.discountApplied,
    required this.discountAmount,
    this.redeemCode,
  });

  factory PaymentBreakdown.fromJson(Map<String, dynamic> json) {
    return PaymentBreakdown(
      baseAmount: (json['base_amount'] ?? 0).toDouble(),
      vatAmount: (json['vat_amount'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'AED',
      discountApplied: json['discount_applied'] ?? false,
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      redeemCode: json['redeem_code'],
    );
  }

  @override
  List<Object?> get props => [
        baseAmount,
        vatAmount,
        totalAmount,
        currency,
        discountApplied,
        discountAmount,
        redeemCode,
      ];
}

class TicketDetailsResponse extends Equatable {
  final bool success;
  final TicketDetailsData? data;

  const TicketDetailsResponse({
    required this.success,
    this.data,
  });

  factory TicketDetailsResponse.fromJson(Map<String, dynamic> json) {
    return TicketDetailsResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? TicketDetailsData.fromJson(json['data'])
          : null,
    );
  }

  @override
  List<Object?> get props => [success, data];
}

class TicketDetailsData extends Equatable {
  final Ticket? ticket;

  const TicketDetailsData({
    this.ticket,
  });

  factory TicketDetailsData.fromJson(Map<String, dynamic> json) {
    return TicketDetailsData(
      ticket: json['ticket'] != null ? Ticket.fromJson(json['ticket']) : null,
    );
  }

  @override
  List<Object?> get props => [ticket];
}

class TicketListResponse extends Equatable {
  final bool success;
  final TicketListData? data;

  const TicketListResponse({
    required this.success,
    this.data,
  });

  factory TicketListResponse.fromJson(Map<String, dynamic> json) {
    return TicketListResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? TicketListData.fromJson(json['data'])
          : null,
    );
  }

  @override
  List<Object?> get props => [success, data];
}

class TicketListData extends Equatable {
  final List<Ticket> tickets;

  const TicketListData({
    required this.tickets,
  });

  factory TicketListData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> ticketsJson = json['tickets'] ?? [];
    return TicketListData(
      tickets: ticketsJson
          .map((t) => Ticket.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [tickets];
}
