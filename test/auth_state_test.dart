import 'package:eveilkid/features/auth/models/utilisateur.dart';
import 'package:eveilkid/features/auth/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthState Tests', () {
    test('état par défaut', () {
      const state = AuthState();
      expect(state.utilisateur, isNull);
      expect(state.isLoading, isFalse);
      expect(state.isInitialized, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.isAuthenticated, isFalse);
    });

    test('copyWith met à jour correctement les propriétés', () {
      const state = AuthState();

      final updated = state.copyWith(
        isLoading: true,
        isInitialized: true,
        errorMessage: 'Une erreur',
      );

      expect(updated.isLoading, isTrue);
      expect(updated.isInitialized, isTrue);
      expect(updated.errorMessage, 'Une erreur');
      expect(updated.isAuthenticated, isFalse);
    });

    test('isAuthenticated retourne true quand utilisateur est présent', () {
      final user = Utilisateur(
        utilisateurId: '123',
        role: UserRole.parent,
        email: 'parent@example.com',
        nom: 'Jean Dupont',
        estActif: true,
      );

      final state = AuthState(
        utilisateur: user,
        isInitialized: true,
      );

      expect(state.isAuthenticated, isTrue);
      expect(state.utilisateur?.nom, 'Jean Dupont');
      expect(state.utilisateur?.role, UserRole.parent);
    });

    test('clearUtilisateur supprime l’utilisateur', () {
      final user = Utilisateur(
        utilisateurId: '123',
        role: UserRole.parent,
        email: 'parent@example.com',
        nom: 'Jean Dupont',
        estActif: true,
      );

      final state = AuthState(
        utilisateur: user,
        isInitialized: true,
      );

      final cleared = state.copyWith(clearUtilisateur: true);
      expect(cleared.utilisateur, isNull);
      expect(cleared.isAuthenticated, isFalse);
    });
  });
}
