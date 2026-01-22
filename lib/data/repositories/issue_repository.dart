import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/issue_category_model.dart';

class IssueRepository {
  final ApiClient apiClient;

  IssueRepository({required this.apiClient});

  Future<List<IssueCategory>> getIssueCategories() async {
    try {
      final response = await apiClient.get('/customer/issue-categories');
      if (response.data['success'] == true) {
        final List<dynamic> categoriesJson =
            response.data['data']['issue_categories'];
        return categoriesJson
            .map((json) => IssueCategory.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to load issue categories: ${response.data['message']}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
