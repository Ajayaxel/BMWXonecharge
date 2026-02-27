import 'package:dartz/dartz.dart';
import 'package:onecharge/core/error/failures.dart';
import 'package:onecharge/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}
