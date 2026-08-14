import 'package:dartz/dartz.dart';
import 'package:goldz/features/auth/domain/entities/user_entities.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;
  SignInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) {
    return repository.signIn(email: email, password: password);
  }
}