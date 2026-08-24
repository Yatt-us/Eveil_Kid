import 'package:firebase_auth/firebase_auth.dart';

/// Gestionnaire centralisé des erreurs d'authentification Firebase.
/// Traduit les codes d'erreur techniques en messages clairs et conviviaux en français.
class AuthErrorHandler {
  AuthErrorHandler._();

  /// Transforme n'importe quelle exception liée à l'authentification en message utilisateur lisible.
  static String getMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return _mapFirebaseAuthCode(error.code, error.message);
    }

    if (error is FirebaseException) {
      return _mapFirebaseCoreCode(error.code, error.message);
    }

    if (error is Exception) {
      final msg = error.toString().replaceFirst('Exception: ', '').trim();
      if (msg.isNotEmpty) {
        return msg;
      }
    }

    return 'Une erreur inattendue est survenue. Veuillez réessayer.';
  }

  /// Traduction exhaustive des codes d'erreur Firebase Authentication.
  static String _mapFirebaseAuthCode(String code, String? defaultMessage) {
    switch (code) {
      // Identifiants & Mot de passe
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect. Veuillez vérifier vos identifiants.';
      case 'wrong-password':
        return 'Le mot de passe saisi est incorrect.';
      case 'user-not-found':
        return 'Aucun compte n’est associé à cette adresse email.';
      case 'invalid-email':
        return 'Le format de l’adresse email est invalide.';
      case 'weak-password':
        return 'Le mot de passe est trop faible. Veuillez saisir au moins 6 caractères.';
      
      // Inscription & Conflits de compte
      case 'email-already-in-use':
        return 'Cette adresse email est déjà utilisée par un autre compte.';
      case 'account-exists-with-different-credential':
        return 'Un compte existe déjà avec cette adresse email mais une méthode de connexion différente.';
      case 'credential-already-in-use':
        return 'Ces identifiants sont déjà liés à un autre compte utilisateur.';
      
      // État du compte & Permissions
      case 'user-disabled':
        return 'Ce compte utilisateur a été désactivé. Veuillez contacter le support.';
      case 'operation-not-allowed':
        return 'Cette méthode de connexion n’est pas activée.';
      case 'requires-recent-login':
        return 'Cette opération sensible nécessite que vous vous reconnectiez.';
      case 'user-token-expired':
      case 'session-expired':
        return 'Votre session a expiré. Veuillez vous reconnecter.';

      // Sécurité & Réseau
      case 'too-many-requests':
        return 'Trop de tentatives infructueuses. Veuillez patienter quelques instants avant de réessayer.';
      case 'network-request-failed':
        return 'Impossible de contacter le serveur. Veuillez vérifier votre connexion internet.';
      case 'quota-exceeded':
        return 'Le quota de requêtes a été dépassé. Veuillez réessayer ultérieurement.';

      // Réinitialisation de mot de passe & Liens
      case 'invalid-action-code':
        return 'Le code ou lien de réinitialisation est invalide.';
      case 'expired-action-code':
        return 'Le lien de réinitialisation a expiré. Veuillez refaire une demande.';

      // Popup Web & Redirections
      case 'popup-closed-by-user':
        return 'La fenêtre de connexion a été fermée avant la fin de l’opération.';
      case 'cancelled-popup-request':
        return 'Une seule tentative de connexion peut être en cours à la fois.';
      case 'popup-blocked':
        return 'La fenêtre de connexion a été bloquée par votre navigateur. Veuillez autoriser les popups pour ce site.';

      // Saisie / Validation
      case 'channel-error':
        return 'Veuillez renseigner tous les champs obligatoires.';
      case 'null-user':
        return 'Impossible de récupérer l’utilisateur connecté.';

      default:
        if (defaultMessage != null && defaultMessage.isNotEmpty) {
          return defaultMessage;
        }
        return 'Une erreur d’authentification est survenue ($code).';
    }
  }

  /// Gestion des erreurs Firestore / Firebase générales
  static String _mapFirebaseCoreCode(String code, String? defaultMessage) {
    switch (code) {
      case 'permission-denied':
        return 'Vous n’avez pas l’autorisation d’accéder à ces données.';
      case 'unavailable':
        return 'Le service est momentanément indisponible. Veuillez réessayer plus tard.';
      case 'not-found':
        return 'La ressource demandée est introuvable.';
      default:
        return defaultMessage ?? 'Une erreur liée au service Firebase est survenue ($code).';
    }
  }
}
