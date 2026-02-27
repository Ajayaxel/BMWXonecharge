import 'package:dartz/dartz.dart';
import 'package:onecharge/core/error/failures.dart';
import 'package:onecharge/features/auth/domain/entities/auth_user.dart';
import 'package:onecharge/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, AuthUser>> call(String email, String otp) {
    return repository.verifyOtp(email, otp);
  }
}
