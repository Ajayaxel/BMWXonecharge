import 'package:onecharge/core/network/api_client.dart';
import '../../models/product_group_model.dart';
import 'dart:developer' as developer;

class ProductGroupRepository {
  final ApiClient apiClient;

  ProductGroupRepository({required this.apiClient});

  Future<List<ProductGroupModel>> getProductGroups() async {
    try {
      final response = await apiClient.get('/customer/product-groups');
      developer.log("Product Groups Response: ${response.data}");
      
      if (response.data['success'] == true) {
        final List<dynamic> groupsJson = response.data['data']['product_groups'];
        return groupsJson.map((json) => ProductGroupModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load product groups: ${response.data['message']}',
        );
      }
    } catch (e) {
      developer.log("Error in getProductGroups: $e");
      rethrow;
    }
  }
}
