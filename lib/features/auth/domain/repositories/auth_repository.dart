import 'package:dartz/dartz.dart';
import 'package:onecharge/core/error/failures.dart';
import 'package:onecharge/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken);
  Future<Either<Failure, AuthUser>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
  Future<Either<Failure, AuthUser>> verifyOtp(String email, String otp);
  Future<Either<Failure, void>> resendOtp(String email);
  Future<Option<AuthUser>> getAuthenticatedUser();
}
