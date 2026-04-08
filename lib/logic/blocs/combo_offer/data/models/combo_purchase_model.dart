class ComboPurchaseRequest {
  final int comboOfferId;
  final String paymentMethod; // "paymob" or "wallet"
  
  // Product fields
  final String? name;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? building;
  final String? notes;

  // Service/Ticket fields
  final int? customerVehicleId;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? bookingType; // "instant" or "scheduled"
  final String? description;
  final String? scheduledAt; // "2026-04-10 10:00:00"
  final String? preferredTime;

  ComboPurchaseRequest({
    required this.comboOfferId,
    required this.paymentMethod,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.building,
    this.notes,
    this.customerVehicleId,
    this.location,
    this.latitude,
    this.longitude,
    this.bookingType,
    this.description,
    this.scheduledAt,
    this.preferredTime,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'combo_offer_id': comboOfferId,
      'payment_method': paymentMethod,
    };

    // Product fields
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;
    if (address != null) data['address'] = address;
    if (city != null) data['city'] = city;
    if (building != null) data['building'] = building;
    if (notes != null) data['notes'] = notes;

    // Service fields
    if (customerVehicleId != null) data['customer_vehicle_id'] = customerVehicleId;
    if (location != null) data['location'] = location;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    if (bookingType != null) data['booking_type'] = bookingType;
    if (description != null) data['description'] = description;
    if (scheduledAt != null) data['scheduled_at'] = scheduledAt;
    if (preferredTime != null) data['preferred_time'] = preferredTime;

    return data;
  }
}

class ComboPurchaseResponse {
  final bool success;
  final String message;
  final ComboPurchaseData? data;

  ComboPurchaseResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ComboPurchaseResponse.fromJson(Map<String, dynamic> json) {
    return ComboPurchaseResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ComboPurchaseData.fromJson(json['data']) : null,
    );
  }
}

class ComboPurchaseData {
  final String? paymentUrl;
  final String? intentionId;
  final int? orderId;
  final List<int>? ticketIds;

  ComboPurchaseData({
    this.paymentUrl,
    this.intentionId,
    this.orderId,
    this.ticketIds,
  });

  factory ComboPurchaseData.fromJson(Map<String, dynamic> json) {
    return ComboPurchaseData(
      paymentUrl: json['payment_url'],
      intentionId: json['intention_id'],
      orderId: json['order_id'],
      ticketIds: (json['ticket_ids'] as List?)?.map((i) => i as int).toList(),
    );
  }
}
