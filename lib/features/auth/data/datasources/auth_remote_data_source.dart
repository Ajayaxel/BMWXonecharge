import '../../../../core/network/dio_client.dart';
import '../../domain/entities/auth_user.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<void> logout();
  Future<AuthToken> refreshToken(String refreshToken);
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String phone,
    String password,
  );
  Future<Map<String, dynamic>> verifyOtp(String email, String otp);
  Future<Map<String, dynamic>> resendOtp(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _client.post(
        '/customer/login',
        data: {'email': email, 'password': password},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post('/customer/logout');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthToken> refreshToken(String refreshToken) async {
    try {
      final response = await _client.post(
        '/customer/refresh-token',
        data: {'refresh_token': refreshToken},
      );
      return AuthToken(
        accessToken: response.data['data']['token'],
        refreshToken: response.data['data']['refresh_token'],
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    try {
      final response = await _client.post(
        '/customer/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': password,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await _client.post(
        '/customer/verify-otp',
        data: {'email': email, 'otp': otp},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final response = await _client.post(
        '/customer/resend-otp',
        data: {'email': email},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
