import 'package:dartz/dartz.dart';
import 'package:onecharge/core/error/failures.dart';
import 'package:onecharge/features/auth/domain/entities/auth_user.dart';
import 'package:onecharge/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, AuthUser>> call({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    return repository.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
  }
}
