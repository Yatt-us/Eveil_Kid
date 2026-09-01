import 'dart:async';

import 'package:eveilkid/core/errors/auth_error_handler.dart';
import 'package:eveilkid/core/services/parental_pin_service.dart';
import 'package:eveilkid/features/auth/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/utilisateur.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthState {
  final Utilisateur? utilisateur;
  final bool isLoading;
  final bool isInitialized;
  final bool isEmailVerified;
  final String? errorMessage;

  const AuthState({
    this.utilisateur,
    this.isLoading = false,
    this.isInitialized = false,
    this.isEmailVerified = false,
    this.errorMessage,
  });

  bool get isAuthenticated => utilisateur != null;

  AuthState copyWith({
    Utilisateur? utilisateur,
    bool? isLoading,
    bool? isInitialized,
    bool? isEmailVerified,
    String? errorMessage,
    bool clearUtilisateur = false,
    bool clearError = false,
  }) {
    return AuthState(
      utilisateur: clearUtilisateur ? null : utilisateur ?? this.utilisateur,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  StreamSubscription<User?>? _authSubscription;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    _listenToAuthState();

    return const AuthState();
  }

  // SESSION FIREBASE

  void _listenToAuthState() {
    _authSubscription = _repository.authStateChanges.listen(
      (user) async {
        if (user == null) {
          try {
            await ref.read(parentalPinServiceProvider).clearPin();
          } catch (_) {}
          state = state.copyWith(
            clearUtilisateur: true,
            isLoading: false,
            isInitialized: true,
            isEmailVerified: false,
            clearError: true,
          );
          return;
        }

        try {
          state = state.copyWith(isLoading: true, clearError: true);

          try {
            await user.reload();
          } catch (_) {}
          final refreshedUser = _repository.currentFirebaseUser ?? user;
          final utilisateur = await _repository.getCurrentUserProfile();

          state = state.copyWith(
            utilisateur: utilisateur,
            isLoading: false,
            isInitialized: true,
            isEmailVerified: refreshedUser.emailVerified,
            clearError: true,
          );
        } catch (e) {
          state = state.copyWith(
            isLoading: false,
            isInitialized: true,
            isEmailVerified: false,
            errorMessage: AuthErrorHandler.getMessage(e),
          );
        }
      },
      onError: (error) {
        state = state.copyWith(
          clearUtilisateur: true,
          isLoading: false,
          isInitialized: true,
          isEmailVerified: false,
          errorMessage: AuthErrorHandler.getMessage(error),
        );
      },
    );
  }

  // REGISTER

  Future<bool> register({
    required String email,
    required String password,
    required String nom,
    String? telephone,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.register(
        email: email,
        password: password,
        nom: nom,
        telephone: telephone,
      );

      state = state.copyWith(isLoading: false, clearError: true);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthErrorHandler.getMessage(e),
      );

      return false;
    }
  }

  // LOGIN

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final utilisateur = await _repository.login(
        email: email,
        password: password,
      );

      state = state.copyWith(
        utilisateur: utilisateur,
        isLoading: false,
        clearError: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthErrorHandler.getMessage(e),
      );

      return false;
    }
  }

  // LOGOUT

  Future<bool> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.logout();
      try {
        await ref.read(parentalPinServiceProvider).clearPin();
      } catch (_) {}

      state = state.copyWith(
        clearUtilisateur: true,
        isLoading: false,
        clearError: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthErrorHandler.getMessage(e),
      );

      return false;
    }
  }

  // RESET PASSWORD

  Future<bool> resetPassword({required String email}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.resetPassword(email: email);

      state = state.copyWith(isLoading: false, clearError: true);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthErrorHandler.getMessage(e),
      );

      return false;
    }
  }

  // GOOGLE SIGN IN

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final utilisateur = await _repository.signInWithGoogle();

      state = state.copyWith(
        utilisateur: utilisateur,
        isLoading: false,
        clearError: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthErrorHandler.getMessage(e),
      );

      return false;
    }
  }

  // CLEAR ERROR

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // EMAIL VERIFICATION

  Future<void> sendEmailVerification() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.sendEmailVerification();
      state = state.copyWith(isLoading: false, clearError: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthErrorHandler.getMessage(e),
      );
      rethrow;
    }
  }

  Future<bool> reloadAndCheckEmailVerified() async {
    try {
      final isVerified = await _repository.isEmailVerified();
      if (isVerified) {
        final user = _repository.currentFirebaseUser;
        if (user != null) {
          final utilisateur =
              await _repository.syncPendingUserToFirestoreIfVerified(user.uid);
          state = state.copyWith(
            utilisateur: utilisateur,
            isEmailVerified: true,
            clearError: true,
          );
          return true;
        }
      }
      state = state.copyWith(isEmailVerified: isVerified);
      return isVerified;
    } catch (e) {
      return false;
    }
  }
}

