import 'package:dartz/dartz.dart';
import 'package:onecharge/core/error/failures.dart';
import 'package:onecharge/features/auth/domain/entities/auth_user.dart';
import 'package:onecharge/features/auth/domain/repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  Future<Either<Failure, AuthToken>> call(String refreshToken) {
    return repository.refreshToken(refreshToken);
  }
}
