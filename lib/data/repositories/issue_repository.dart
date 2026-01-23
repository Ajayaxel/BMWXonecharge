import 'package:dio/dio.dart';
import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/issue_category_model.dart';
import 'package:onecharge/models/ticket_model.dart';

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

  Future<CreateTicketResponse> createTicket(
    CreateTicketRequest request,
  ) async {
    try {
      final formData = FormData.fromMap({
        'issue_category_id': request.issueCategoryId,
        if (request.issueCategorySubTypeId != null)
          'issue_category_sub_type_id': request.issueCategorySubTypeId,
        'vehicle_type_id': request.vehicleTypeId,
        'brand_id': request.brandId,
        'model_id': request.modelId,
        'number_plate': request.numberPlate,
        if (request.description != null && request.description!.isNotEmpty)
          'description': request.description,
        'location': request.location,
        'latitude': request.latitude,
        'longitude': request.longitude,
        if (request.redeemCode != null && request.redeemCode!.isNotEmpty)
          'redeem_code': request.redeemCode,
      });

      // Add attachments if any
      if (request.attachments != null && request.attachments!.isNotEmpty) {
        for (var file in request.attachments!) {
          formData.files.add(
            MapEntry(
              'attachments[]',
              await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              ),
            ),
          );
        }
      }

      final response = await apiClient.postMultipart(
        '/customer/tickets',
        formData: formData,
      );

      if (response.data['success'] == true) {
        return CreateTicketResponse.fromJson(response.data);
      } else {
        // Parse validation errors if present
        final errors = response.data['errors'];
        String errorMessage = response.data['message'] ?? 'Unknown error';
        
        if (errors != null && errors is Map) {
          final errorList = <String>[];
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorList.add('${key}: ${value.first}');
            } else if (value is String) {
              errorList.add('${key}: $value');
            }
          });
          if (errorList.isNotEmpty) {
            errorMessage = '${errorMessage}\n${errorList.join('\n')}';
          }
        }
        
        throw Exception('Failed to create ticket: $errorMessage');
      }
    } on DioException catch (e) {
      // Handle DioException with better error messages
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          final errors = responseData['errors'];
          String errorMessage = responseData['message'] ?? 'Validation failed';
          
          if (errors != null && errors is Map) {
            final errorList = <String>[];
            errors.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                errorList.add('${key}: ${value.first}');
              } else if (value is String) {
                errorList.add('${key}: $value');
              }
            });
            if (errorList.isNotEmpty) {
              errorMessage = '${errorMessage}\n${errorList.join('\n')}';
            }
          }
          throw Exception('API Error: ${e.response?.statusCode} - $errorMessage');
        }
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<TicketDetailsResponse> getTicketDetails(int ticketId) async {
    try {
      final response = await apiClient.get('/customer/tickets/$ticketId');
      if (response.data['success'] == true) {
        return TicketDetailsResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load ticket details: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TicketListResponse> getTickets() async {
    try {
      final response = await apiClient.get('/customer/tickets');
      if (response.data['success'] == true) {
        return TicketListResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load tickets: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
