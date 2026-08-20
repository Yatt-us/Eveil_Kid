import 'dart:async';

import 'package:eveilkid/core/errors/auth_error_handler.dart';
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
  final String? errorMessage;

  const AuthState({
    this.utilisateur,
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
  });

  bool get isAuthenticated => utilisateur != null;

  AuthState copyWith({
    Utilisateur? utilisateur,
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    bool clearUtilisateur = false,
    bool clearError = false,
  }) {
    return AuthState(
      utilisateur: clearUtilisateur ? null : utilisateur ?? this.utilisateur,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
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
          state = state.copyWith(
            clearUtilisateur: true,
            isLoading: false,
            isInitialized: true,
            clearError: true,
          );
          return;
        }

        try {
          state = state.copyWith(isLoading: true, clearError: true);

          final utilisateur = await _repository.getCurrentUserProfile();

          state = state.copyWith(
            utilisateur: utilisateur,
            isLoading: false,
            isInitialized: true,
            clearError: true,
          );
        } catch (e) {
          state = state.copyWith(
            clearUtilisateur: true,
            isLoading: false,
            isInitialized: true,
            errorMessage: AuthErrorHandler.getMessage(e),
          );
        }
      },
      onError: (error) {
        state = state.copyWith(
          clearUtilisateur: true,
          isLoading: false,
          isInitialized: true,
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
}

