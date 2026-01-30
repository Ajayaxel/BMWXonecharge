import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/login_model.dart';
import 'package:onecharge/models/register_model.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  Future<Object> login(LoginRequest request) async {
    try {
      final response = await apiClient.post(
        '/customer/login',
        data: request.toJson(),
      );
      if (response.data['success'] == true) {
        return LoginResponse.fromJson(response.data['data']);
      } else if (response.data['success'] == false &&
          response.data['data'] != null &&
          response.data['data']['requires_verification'] == true) {
        // Special case: Login failed because verification is required
        return VerificationRequiredResponse.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Login failed: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Object> register(RegisterRequest request) async {
    try {
      final response = await apiClient.post(
        '/customer/register',
        data: request.toJson(),
      );
      if (response.data['success'] == true) {
        // Check if token exists, if so return LoginResponse
        if (response.data['data']['token'] != null) {
          return LoginResponse.fromJson(response.data['data']);
        } else {
          // Otherwise return RegisterResponse (OTP flow)
          return RegisterResponse.fromJson(response.data['data']);
        }
      } else {
        throw Exception(
          'Registration failed: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginResponse> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await apiClient.post(
        '/customer/verify-otp',
        data: request.toJson(),
      );
      if (response.data['success'] == true) {
        return LoginResponse.fromJson(response.data['data']);
      } else {
        throw Exception(
          'Verification failed: ${response.data['message'] ?? 'Invalid OTP'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resendOtp(String email) async {
    try {
      final response = await apiClient.post(
        '/customer/resend-otp',
        data: {'email': email},
      );
      if (response.data['success'] != true) {
        throw Exception(
          'Resend OTP failed: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final response = await apiClient.post('/customer/logout');
      if (response.data['success'] != true) {
        throw Exception(
          'Logout failed: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
