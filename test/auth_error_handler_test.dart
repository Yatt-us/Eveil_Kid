import 'package:eveilkid/core/errors/auth_error_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthErrorHandler Tests', () {
    test('traduit correctement invalid-credential', () {
      final exception = FirebaseAuthException(code: 'invalid-credential');
      final message = AuthErrorHandler.getMessage(exception);
      expect(
        message,
        'Email ou mot de passe incorrect. Veuillez vérifier vos identifiants.',
      );
    });

    test('traduit correctement wrong-password', () {
      final exception = FirebaseAuthException(code: 'wrong-password');
      final message = AuthErrorHandler.getMessage(exception);
      expect(message, 'Le mot de passe saisi est incorrect.');
    });

    test('traduit correctement user-not-found', () {
      final exception = FirebaseAuthException(code: 'user-not-found');
      final message = AuthErrorHandler.getMessage(exception);
      expect(message, 'Aucun compte n’est associé à cette adresse email.');
    });

    test('traduit correctement email-already-in-use', () {
      final exception = FirebaseAuthException(code: 'email-already-in-use');
      final message = AuthErrorHandler.getMessage(exception);
      expect(
        message,
        'Cette adresse email est déjà utilisée par un autre compte.',
      );
    });

    test('traduit correctement weak-password', () {
      final exception = FirebaseAuthException(code: 'weak-password');
      final message = AuthErrorHandler.getMessage(exception);
      expect(
        message,
        'Le mot de passe est trop faible. Veuillez saisir au moins 6 caractères.',
      );
    });

    test('traduit correctement user-disabled', () {
      final exception = FirebaseAuthException(code: 'user-disabled');
      final message = AuthErrorHandler.getMessage(exception);
      expect(
        message,
        'Ce compte utilisateur a été désactivé. Veuillez contacter le support.',
      );
    });

    test('traduit correctement network-request-failed', () {
      final exception = FirebaseAuthException(code: 'network-request-failed');
      final message = AuthErrorHandler.getMessage(exception);
      expect(
        message,
        'Impossible de contacter le serveur. Veuillez vérifier votre connexion internet.',
      );
    });

    test('traduit correctement too-many-requests', () {
      final exception = FirebaseAuthException(code: 'too-many-requests');
      final message = AuthErrorHandler.getMessage(exception);
      expect(
        message,
        'Trop de tentatives infructueuses. Veuillez patienter quelques instants avant de réessayer.',
      );
    });

    test('traduit correctement les exceptions Firestore / FirebaseException', () {
      final exception = FirebaseException(plugin: 'firestore', code: 'permission-denied');
      final message = AuthErrorHandler.getMessage(exception);
      expect(
        message,
        'Vous n’avez pas l’autorisation d’accéder à ces données.',
      );
    });

    test('gère les exceptions génériques proprement', () {
      final exception = Exception('Ce compte est désactivé.');
      final message = AuthErrorHandler.getMessage(exception);
      expect(message, 'Ce compte est désactivé.');
    });
  });
}
