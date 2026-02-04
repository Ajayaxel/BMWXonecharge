import 'package:dio/dio.dart';
import 'package:onecharge/core/storage/token_storage.dart';

class ApiClient {
  late Dio _dio;
  static const String baseUrl = 'https://app.onecharge.io/api';

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) {
          return status != null && status < 500;
        },
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add auth interceptor to include token in requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip adding token for login endpoint
          if (options.path != '/customer/login') {
            final token = await TokenStorage.readToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              print('🔑 [ApiClient] Token added to request: ${options.path}');
            } else {
              print(
                '⚠️ [ApiClient] No token found for request: ${options.path}',
              );
            }
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            print(
              '❌ [ApiClient] Unauthenticated - Token may be invalid or expired',
            );
          }
          return handler.next(error);
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    int retries = 3,
  }) async {
    int attempt = 0;
    while (attempt < retries) {
      try {
        final response = await _dio.get(path, queryParameters: queryParameters);
        return response;
      } on DioException catch (e) {
        attempt++;
        // Only retry on connection errors or timeouts
        bool shouldRetry =
            e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            (e.type == DioExceptionType.unknown &&
                e.message?.contains('Connection reset') == true);

        if (attempt >= retries || !shouldRetry) {
          throw _handleError(e);
        }

        // Wait before retrying (exponential backoff could be used here)
        print('⚠️ [ApiClient] Request failed ($attempt/$retries). Retrying...');
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
    // Should not be reached due to throw in loop
    throw Exception('Failed to request $path after $retries attempts');
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
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
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

  Future<Response> download(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> postMultipart(
    String path, {
    required FormData formData,
  }) async {
    try {
      // Get token for multipart request
      final token = await TokenStorage.readToken();
      final headers = <String, dynamic>{'Accept': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(headers: headers, contentType: 'multipart/form-data'),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> putMultipart(
    String path, {
    required FormData formData,
  }) async {
    try {
      // Get token for multipart request
      final token = await TokenStorage.readToken();
      final headers = <String, dynamic>{'Accept': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.put(
        path,
        data: formData,
        options: Options(headers: headers, contentType: 'multipart/form-data'),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      String message = 'API Error: ${e.response?.statusCode}';

      if (data is Map) {
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              message = firstError.first.toString();
            } else {
              message = firstError.toString();
            }
          }
        } else if (data.containsKey('message')) {
          message = data['message'].toString();
        }
      }

      return Exception(message);
    } else {
      return Exception('Connection Error: ${e.message}');
    }
  }
}
