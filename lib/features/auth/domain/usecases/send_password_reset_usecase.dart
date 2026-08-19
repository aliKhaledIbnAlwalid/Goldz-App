import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetUseCase {
  final AuthRepository repository;
  SendPasswordResetUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) =>
      repository.sendPasswordReset(email);
}