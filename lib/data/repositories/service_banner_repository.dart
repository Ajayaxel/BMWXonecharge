import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/service_banner_model.dart';

class ServiceBannerRepository {
  final ApiClient apiClient;

  ServiceBannerRepository({required this.apiClient});

  Future<ServiceBanner> getServiceBanner() async {
    try {
      final response = await apiClient.get('/customer/service-banner');
      if (response.data['success'] == true) {
        final bannerJson = response.data['data']['banner'];
        return ServiceBanner.fromJson(bannerJson);
      } else {
        throw Exception(
          'Failed to load service banner: ${response.data['message']}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
