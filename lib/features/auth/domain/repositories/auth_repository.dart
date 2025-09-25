import '../entities/user.dart';
import '../../../../core/utils/result.dart';

abstract class AuthRepository {
  Future<Result<User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Result<User>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
  });

  Future<Result<void>> signOut();

  Future<Result<User?>> getCurrentUser();

  Future<Result<void>> updateUserProfile({
    required String userId,
    String? name,
    String? photoUrl,
  });

  Stream<User?> get authStateChanges;
}
