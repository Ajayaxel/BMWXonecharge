import 'package:dio/dio.dart';

class ApiClient {
  late Dio _dio;
  static const String baseUrl = 'https://onecharge.io/api';

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging or other interceptors here if needed
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
  }) async {
    try {
      final dio = baseUrl != null
          ? Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            )
          : _dio;
      final response = await dio.post(path, data: data, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> getWithBaseUrl(
    String path,
    String baseUrl, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      final response = await dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      return Exception(
        'API Error: ${e.response?.statusCode} - ${e.response?.data}',
      );
    } else {
      return Exception('Connection Error: ${e.message}');
    }
  }
}
