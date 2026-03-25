import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/wallet_top_up_model.dart';
import 'package:onecharge/models/wallet_model.dart';

class WalletRepository {
  final ApiClient apiClient;

  WalletRepository({required this.apiClient});

  Future<WalletTopUpResponse> topUpWallet(double amount) async {
    try {
      final response = await apiClient.post(
        '/customer/wallet/top-up',
        data: {'amount': amount},
      );
      
      return WalletTopUpResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<WalletResponse> getWalletDetails() async {
    try {
      final response = await apiClient.get('/customer/wallet');
      return WalletResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
