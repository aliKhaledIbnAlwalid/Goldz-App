import 'package:dartz/dartz.dart';
import 'package:goldz/features/auth/domain/entities/user_entities.dart';
import '../../../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signInAsGuest();

  Future<Either<Failure, void>> signOut();

  /// Returns the currently logged-in user, or null if nobody is signed in.
  UserEntity? getCurrentUser();
}