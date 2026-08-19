import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:goldz/features/auth/domain/entities/user_entities.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signUp(
        name: name,
        email: email,
        password: password,
      );
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      return const Left(ServerFailure('Something went wrong. Try again.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signIn(
        email: email,
        password: password,
      );
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      return const Left(ServerFailure('Something went wrong. Try again.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInAsGuest() async {
    try {
      final user = await remoteDataSource.signInAsGuest();
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      return const Left(ServerFailure('Could not continue as guest.'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Sign-out failed.'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordReset(String email) async {
    try {
      await remoteDataSource.sendPasswordReset(email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      // SECURITY: 'user-not-found' is treated as success. Revealing which
      // emails are registered lets attackers enumerate your user base.
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        return const Right(null);
      }
      return Left(AuthFailure(_mapFirebaseError(e.code)));
    } catch (_) {
      return const Left(ServerFailure('Could not send the reset email.'));
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() => remoteDataSource.getCurrentUser();

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'Password is too weak (min 6 characters).';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'operation-not-allowed':
      case 'admin-restricted-operation':
        return 'This sign-in method is disabled in Firebase Console.';
      default:
        return 'Authentication failed ($code).';
    }
  }
}
