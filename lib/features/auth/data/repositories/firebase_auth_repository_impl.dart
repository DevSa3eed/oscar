import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  FirebaseAuthRepositoryImpl({required FirebaseAuthDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Result<User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _dataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userModel != null) {
        return Result.success(userModel.toEntity());
      } else {
        return Result.failure(AuthError('Invalid email or password'));
      }
    } catch (e) {
      return Result.failure(AuthError('Sign in failed: $e'));
    }
  }

  @override
  Future<Result<User>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final userModel = await _dataSource.createUserWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
      );

      if (userModel != null) {
        return Result.success(userModel.toEntity());
      } else {
        return Result.failure(AuthError('Failed to create user'));
      }
    } catch (e) {
      return Result.failure(AuthError('User creation failed: $e'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _dataSource.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.failure(AuthError('Sign out failed: $e'));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final userModel = await _dataSource.getCurrentUser();
      return Result.success(userModel?.toEntity());
    } catch (e) {
      return Result.failure(AuthError('Failed to get current user: $e'));
    }
  }

  @override
  Future<Result<void>> updateUserProfile({
    required String userId,
    String? name,
    String? photoUrl,
  }) async {
    try {
      await _dataSource.updateUserProfile(
        userId: userId,
        name: name,
        photoUrl: photoUrl,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(AuthError('Failed to update profile: $e'));
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _dataSource.authStateChanges.map(
      (userModel) => userModel?.toEntity(),
    );
  }
}
