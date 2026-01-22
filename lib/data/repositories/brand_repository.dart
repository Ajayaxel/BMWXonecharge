import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/brand_model.dart';

class BrandRepository {
  final ApiClient apiClient;

  BrandRepository({required this.apiClient});

  Future<List<Brand>> getBrands() async {
    try {
      final response = await apiClient.get('/customer/brands');
      if (response.data['success'] == true) {
        final List<dynamic> brandsJson = response.data['data']['brands'];
        return brandsJson.map((json) => Brand.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load brands: ${response.data['message']}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
