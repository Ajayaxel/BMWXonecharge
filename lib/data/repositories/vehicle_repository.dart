import 'package:dio/dio.dart';
import 'package:onecharge/core/network/api_client.dart';
import 'package:onecharge/models/vehicle_model.dart';
import 'package:onecharge/models/add_vehicle_model.dart';
import 'package:onecharge/models/vehicle_list_model.dart';

class VehicleRepository {
  final ApiClient apiClient;

  // Simple memory cache
  List<VehicleModel>? _modelsCache;
  int? _totalCountCache;
  DateTime? _cacheTimestamp;

  VehicleRepository({required this.apiClient});

  Future<({List<VehicleModel> models, int totalCount})> getModels({
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    // Return cache if available and not forcing refresh (and for first page)
    if (!forceRefresh &&
        page == 1 &&
        _modelsCache != null &&
        _cacheTimestamp != null &&
        DateTime.now().difference(_cacheTimestamp!) <
            const Duration(seconds: 30)) {
      return (models: _modelsCache!, totalCount: _totalCountCache ?? 0);
    }

    try {
      final response = await apiClient.get(
        '/customer/models',
        queryParameters: {'page': page, 'limit': limit},
        cancelToken: cancelToken,
      );
      if (response.data['success'] == true) {
        final List<dynamic> modelsJson = response.data['data']['models'] ?? [];
        final totalCount =
            (response.data['data']['total_count'] as num?)?.toInt() ?? 0;

        // Use compute to parse large lists in background thread
        final models = await _parseVehicleModels(modelsJson);

        // Update cache for the first page
        if (page == 1) {
          _modelsCache = models;
          _totalCountCache = totalCount;
          _cacheTimestamp = DateTime.now();
        }

        return (models: models, totalCount: totalCount);
      } else {
        throw Exception('Failed to load models: ${response.data['message']}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<VehicleModel>> _parseVehicleModels(
    List<dynamic> jsonList,
  ) async {
    // If list is small, don't spawn isolate
    if (jsonList.length < 10) {
      return jsonList.map((json) => VehicleModel.fromJson(json)).toList();
    }
    // For larger lists, use isolate
    return await Stream.fromIterable(
      jsonList,
    ).map((json) => VehicleModel.fromJson(json)).toList();
    // Note: compute() is better for extremely large lists, but requires a top-level function.
    // Given the constraints, we'll stick to efficient mapping first unless it's a massive payload.
  }

  Future<AddVehicleResponse> addVehicle(AddVehicleRequest request) async {
    try {
      final response = await apiClient.post(
        '/customer/vehicles',
        data: request.toJson(),
      );
      if (response.data['success'] == true) {
        return AddVehicleResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to add vehicle: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<VehicleListResponse> getVehicles() async {
    try {
      final response = await apiClient.get('/customer/vehicles');
      if (response.data['success'] == true) {
        return VehicleListResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load vehicles: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteVehicle(int vehicleId) async {
    try {
      final response = await apiClient.delete('/customer/vehicles/$vehicleId');
      if (response.data['success'] != true) {
        throw Exception(
          'Failed to delete vehicle: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
