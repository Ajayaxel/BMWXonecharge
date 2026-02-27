import 'package:dartz/dartz.dart';
import 'package:onecharge/core/error/failures.dart';
import 'package:onecharge/features/auth/domain/entities/auth_user.dart';
import 'package:onecharge/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthUser>> call(String email, String password) {
    return repository.login(email, password);
  }
}
