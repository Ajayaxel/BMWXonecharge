import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/company_code_model.dart';

class CompanyCodeRepository {
  final ApiClient apiClient;

  CompanyCodeRepository({required this.apiClient});

  Future<CompanyCodeResponse> validateCompanyCode(String code) async {
    try {
      final response = await apiClient.post(
        '/customer/company-code/validate',
        data: {'code': code},
      );

      if (response.data != null) {
        return CompanyCodeResponse.fromJson(response.data);
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      rethrow;
    }
  }
}
