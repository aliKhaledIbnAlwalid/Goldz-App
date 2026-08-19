import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<UserModel> signInAsGuest();

  Future<void> signOut();
  Future<void> sendPasswordReset(String email);

  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;

    // Save the username into the Firebase profile
    await user.updateDisplayName(name.trim());

    // IMPORTANT: refresh the cached user so displayName isn't null
    await user.reload();

    return UserModel.fromFirebase(firebaseAuth.currentUser!);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return UserModel.fromFirebase(credential.user!);
  }

  @override
  Future<UserModel> signInAsGuest() async {
    final credential = await firebaseAuth.signInAnonymously();
    return UserModel.fromFirebase(credential.user!);
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;

    try {
      // Asks the server: does this account still exist and is it enabled?
      await user.reload();
      final refreshed = firebaseAuth.currentUser;
      if (refreshed == null) return null;
      return UserModel.fromFirebase(refreshed);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'user-disabled' ||
          e.code == 'user-token-expired') {
        await firebaseAuth.signOut();
        return null;
      }
      // Offline — trust the cached session rather than locking them out.
      return UserModel.fromFirebase(user);
    } catch (_) {
      return UserModel.fromFirebase(user);
    }
  }
}
