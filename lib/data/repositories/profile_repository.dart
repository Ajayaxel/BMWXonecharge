import 'package:dio/dio.dart';
import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/user_profile_model.dart';
import 'dart:io';

class ProfileRepository {
  final ApiClient apiClient;

  ProfileRepository({required this.apiClient});

  Future<Customer> getProfile() async {
    try {
      final response = await apiClient.get('/customer/profile');
      if (response.data['success'] == true) {
        return Customer.fromJson(response.data['data']['customer']);
      } else {
        throw Exception(
          'Failed to load profile: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Customer> updateProfile({
    required String name,
    required String phone,
    File? profileImage,
  }) async {
    try {
      final Map<String, dynamic> data = {'name': name, 'phone': phone};

      if (profileImage != null) {
        String fileName = profileImage.path.split('/').last;
        data['profile_image'] = await MultipartFile.fromFile(
          profileImage.path,
          filename: fileName,
        );
      }

      final formData = FormData.fromMap(data);
      final response = await apiClient.putMultipart(
        '/customer/profile',
        formData: formData,
      );

      if (response.data['success'] == true) {
        return Customer.fromJson(response.data['data']['customer']);
      } else {
        throw Exception(
          'Failed to update profile: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
