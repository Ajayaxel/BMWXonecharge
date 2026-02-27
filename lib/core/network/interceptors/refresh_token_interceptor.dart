import 'package:dio/dio.dart';
import '../../storage/secure_storage_service.dart';

class RefreshTokenInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<Map<String, dynamic>> _queue = [];

  RefreshTokenInterceptor(this._storage, this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.getRefreshToken();

      if (refreshToken == null) {
        return handler.next(err);
      }

      RequestOptions options = err.response!.requestOptions;

      if (_isRefreshing) {
        _queue.add({'options': options, 'handler': handler});
        return;
      }

      _isRefreshing = true;

      try {
        // Attempt to refresh token
        // Note: You should have a dedicated endpoint for this.
        // I'll assume /customer/refresh-token based on context or a standard pattern.
        final response = await _dio.post(
          '/customer/refresh-token',
          data: {'refresh_token': refreshToken},
        );

        if (response.statusCode == 200) {
          final newAccessToken = response.data['data']['token'];
          final newRefreshToken = response.data['data']['refresh_token'];

          await _storage.saveAccessToken(newAccessToken);
          if (newRefreshToken != null) {
            await _storage.saveRefreshToken(newRefreshToken);
          }

          _isRefreshing = false;

          // Retry the original request
          options.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await _dio.fetch(options);
          handler.resolve(retryResponse);

          // Process queue
          for (var element in _queue) {
            final queuedOptions = element['options'] as RequestOptions;
            final queuedHandler = element['handler'] as ErrorInterceptorHandler;

            queuedOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final queuedResponse = await _dio.fetch(queuedOptions);
            queuedHandler.resolve(queuedResponse);
          }
          _queue.clear();
          return;
        }
      } catch (e) {
        _isRefreshing = false;
        _queue.clear();
        await _storage.clearAll();
        // Here you might want to trigger a global logout event or navigate to login
        // but since we are in interceptor, we just pass the error.
        // The bloc will handle the AuthLoggedOut state if needed.
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}
