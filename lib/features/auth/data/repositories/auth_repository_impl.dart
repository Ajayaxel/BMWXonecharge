import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService storage;

  AuthRepositoryImpl({required this.remoteDataSource, required this.storage});

  @override
  Future<Either<Failure, AuthUser>> login(String email, String password) async {
    try {
      final responseData = await remoteDataSource.login(email, password);

      if (responseData['success'] == true) {
        return Right(await _handleAuthResponse(responseData));
      } else {
        return Left(ServerFailure(responseData['message'] ?? 'Login failed'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(_handleDioError(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await storage.clearAll();
      return const Right(null);
    } catch (e) {
      await storage.clearAll();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken) async {
    try {
      final token = await remoteDataSource.refreshToken(refreshToken);
      await storage.saveAccessToken(token.accessToken);
      if (token.refreshToken != null) {
        await storage.saveRefreshToken(token.refreshToken!);
      }
      return Right(token);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final responseData = await remoteDataSource.register(
        name,
        email,
        phone,
        password,
      );
      if (responseData['success'] == true) {
        // Registration might require OTP, so we don't handle response fully here if token isn't present
        if (responseData['data'] != null &&
            responseData['data']['token'] != null) {
          return Right(await _handleAuthResponse(responseData));
        }
        // If registration success but no token (OTP required), return a dummy user or handle state in BLoC
        // Our BLoC expects AuthUser for success, but if OTP is required, the BLoC should handle 'success: true' with message
        // Actually, let's map it to an exception or special state if it's not a full login.
        // For now, let's assume registration success means we move to OTP.
        return Right(AuthUser(id: 0, name: name, email: email, phone: phone));
      } else {
        return Left(
          ServerFailure(responseData['message'] ?? 'Registration failed'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure(_handleDioError(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> verifyOtp(String email, String otp) async {
    try {
      final responseData = await remoteDataSource.verifyOtp(email, otp);
      if (responseData['success'] == true) {
        return Right(await _handleAuthResponse(responseData));
      } else {
        return Left(
          ServerFailure(responseData['message'] ?? 'OTP verification failed'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure(_handleDioError(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendOtp(String email) async {
    try {
      final responseData = await remoteDataSource.resendOtp(email);
      if (responseData['success'] == true) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(responseData['message'] ?? 'OTP resend failed'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure(_handleDioError(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Option<AuthUser>> getAuthenticatedUser() async {
    final token = await storage.getAccessToken();
    final name = await storage.getUserName();
    if (token != null && name != null) {
      return Some(AuthUser(id: 0, name: name, email: '', phone: ''));
    }
    return None();
  }

  Future<AuthUser> _handleAuthResponse(
    Map<String, dynamic> responseData,
  ) async {
    final token = responseData['data']['token'];
    final refreshToken = responseData['data']['refresh_token'];
    final userData = responseData['data']['customer'];

    await storage.saveAccessToken(token);
    if (refreshToken != null) {
      await storage.saveRefreshToken(refreshToken);
    }

    final user = UserModel.fromJson(userData);
    await storage.saveUserName(user.name);

    return user;
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ??
          'Server error: ${e.response?.statusCode}';
    }
    return 'Network error: ${e.message}';
  }
}
