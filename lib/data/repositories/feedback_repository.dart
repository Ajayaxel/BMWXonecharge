import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/feedback_model.dart';
import 'package:dio/dio.dart';

class FeedbackRepository {
  final ApiClient apiClient;

  FeedbackRepository({required this.apiClient});

  Future<FeedbackResponse> submitFeedback(FeedbackRequest request) async {
    try {
      final response = await apiClient.post(
        '/customer/feedback',
        data: request.toJson(),
      );

      if (response.data['success'] == true) {
        return FeedbackResponse.fromJson(response.data);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to submit feedback',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'] ?? 'An error occurred';
        throw Exception(message);
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
