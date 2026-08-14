import 'package:dartz/dartz.dart';
import 'package:goldz/features/auth/domain/entities/user_entities.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class GuestSignInUseCase {
  final AuthRepository repository;
  GuestSignInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() {
    return repository.signInAsGuest();
  }
}