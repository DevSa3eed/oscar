import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/services/dependency_injection.dart';

part 'auth_controller.g.dart';

class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.isLoading == isLoading &&
        other.isLoggedIn == isLoggedIn &&
        other.user == user &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(isLoading, isLoggedIn, user, errorMessage);
  }

  @override
  String toString() {
    return 'AuthState(isLoading: $isLoading, isLoggedIn: $isLoggedIn, user: $user, errorMessage: $errorMessage)';
  }
}

@riverpod
class AuthController extends _$AuthController {
  late final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  @override
  AuthState build() {
    _authRepository = getIt<AuthRepository>();

    // Set up disposal handler
    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    return const AuthState();
  }

  Future<void> initializeAuth() async {
    try {
      print('🔐 [AUTH] Starting authentication initialization...');
      // Set loading state
      state = state.copyWith(isLoading: true, errorMessage: null);

      _listenToAuthChanges();
      await _checkCurrentUser();
      print('🔐 [AUTH] Authentication initialization completed');
    } catch (e) {
      print('🔐 [AUTH] Authentication initialization failed: $e');
      // Handle Firebase/network errors gracefully
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to connect to authentication service. Please check your internet connection.',
      );
    }
  }

  Future<void> _checkCurrentUser() async {
    try {
      print('🔐 [AUTH] Checking current user...');
      final result = await _authRepository.getCurrentUser();

      // Check if provider is still mounted before updating state
      if (!ref.mounted) return;

      result.when(
        success: (user) {
          if (!ref.mounted) return;
          print('🔐 [AUTH] Current user check result: ${user != null ? "User found (${user.role})" : "No user"}');
          state = state.copyWith(
            isLoggedIn: user != null,
            user: user,
            isLoading: false,
          );
        },
        failure: (failure) {
          if (!ref.mounted) return;
          print('🔐 [AUTH] Current user check failed: ${failure.toString()}');
          state = state.copyWith(
            isLoading: false,
            errorMessage: _getErrorMessage(failure),
          );
        },
      );
    } catch (e) {
      print('🔐 [AUTH] Current user check exception: $e');
      // Handle Firebase not available or other critical errors
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Authentication service unavailable. Please check your connection.',
      );
    }
  }

  void _listenToAuthChanges() {
    _authSubscription?.cancel();
    _authSubscription = _authRepository.authStateChanges.listen(
      (user) {
        if (!ref.mounted) return;
        state = state.copyWith(
          isLoggedIn: user != null,
          user: user,
          isLoading: false,
          errorMessage: null,
        );
      },
      onError: (error) {
        if (!ref.mounted) return;
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Authentication error: $error',
        );
      },
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (!ref.mounted) return;

    result.when(
      success: (user) {
        if (!ref.mounted) return;
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: true,
          user: user,
          errorMessage: null,
        );
      },
      failure: (failure) {
        if (!ref.mounted) return;
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: false,
          user: null,
          errorMessage: _getErrorMessage(failure),
        );
      },
    );
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _authRepository.createUserWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
      role: role,
    );

    if (!ref.mounted) return;

    result.when(
      success: (user) {
        if (!ref.mounted) return;
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: true,
          user: user,
          errorMessage: null,
        );
      },
      failure: (failure) {
        if (!ref.mounted) return;
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: false,
          user: null,
          errorMessage: _getErrorMessage(failure),
        );
      },
    );
  }

  Future<void> signOut() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true);

    final result = await _authRepository.signOut();

    if (!ref.mounted) return;

    result.when(
      success: (_) {
        if (!ref.mounted) return;
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: false,
          user: null,
          errorMessage: null,
        );
      },
      failure: (failure) {
        if (!ref.mounted) return;
        state = state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        );
      },
    );
  }

  Future<void> updateProfile({required String name, String? photoUrl}) async {
    if (!ref.mounted) return;

    final currentUser = state.user;
    if (currentUser == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _authRepository.updateUserProfile(
      userId: currentUser.id,
      name: name,
      photoUrl: photoUrl,
    );

    if (!ref.mounted) return;

    result.when(
      success: (_) {
        if (!ref.mounted) return;
        // Update the user in state with new name
        final updatedUser = currentUser.copyWith(
          name: name,
          photoUrl: photoUrl ?? currentUser.photoUrl,
        );
        state = state.copyWith(
          isLoading: false,
          user: updatedUser,
          errorMessage: null,
        );
      },
      failure: (failure) {
        if (!ref.mounted) return;
        state = state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        );
      },
    );
  }

  String _getErrorMessage(Failure failure) {
    return failure.when(
      serverError: (message) => message,
      networkError: (message) => message,
      authError: (message) => message,
      validationError: (message) => message,
      notFoundError: (message) => message,
      permissionError: (message) => message,
      unknownError: (message) => message,
    );
  }
}
