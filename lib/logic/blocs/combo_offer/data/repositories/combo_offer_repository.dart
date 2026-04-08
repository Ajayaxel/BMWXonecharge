import 'package:onecharge/core/network/api_client.dart';
import '../models/combo_offer_model.dart';
import '../models/combo_purchase_model.dart';

class ComboOfferRepository {
  final ApiClient apiClient;

  ComboOfferRepository({required this.apiClient});

  Future<ComboOfferResponse> getComboOffers() async {
    try {
      final response = await apiClient.get('/customer/combo-offers');
      
      if (response.data['success'] == true) {
        return ComboOfferResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to fetch combo offers: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ComboPurchaseResponse> purchaseComboOffer(ComboPurchaseRequest request) async {
    try {
      final response = await apiClient.post(
        '/customer/combo-offers/purchase',
        data: request.toJson(),
      );

      if (response.data['success'] == true) {
        return ComboPurchaseResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed and purchase combo offer: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
