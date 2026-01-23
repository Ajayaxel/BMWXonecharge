import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/login_model.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await apiClient.post(
        '/customer/login',
        data: request.toJson(),
      );
      if (response.data['success'] == true) {
        return LoginResponse.fromJson(response.data['data']);
      } else {
        throw Exception(
            'Login failed: ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
