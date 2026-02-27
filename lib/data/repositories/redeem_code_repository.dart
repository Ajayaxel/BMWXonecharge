import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/redeem_code_model.dart';

class RedeemCodeRepository {
  final ApiClient apiClient;

  RedeemCodeRepository({required this.apiClient});

  Future<RedeemCodeResponse> validateCode(String code) async {
    try {
      final response = await apiClient.post(
        '/customer/redeem-code/validate',
        data: {'code': code},
      );

      if (response.data != null) {
        return RedeemCodeResponse.fromJson(response.data);
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      rethrow;
    }
  }
}
