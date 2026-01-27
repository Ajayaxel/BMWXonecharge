class UserProfileResponse {
  final bool success;
  final UserProfile data;

  UserProfileResponse({required this.success, required this.data});

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      success: json['success'] ?? false,
      data: UserProfile.fromJson(json['data']),
    );
  }
}

class UserProfile {
  final Customer customer;

  UserProfile({required this.customer});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(customer: Customer.fromJson(json['customer']));
  }
}

class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profile_image'],
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
