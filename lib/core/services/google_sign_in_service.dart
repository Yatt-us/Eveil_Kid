import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service singleton charge d initialiser et d exposer Google Sign-In v7+.
///
/// L initialisation doit etre appelee une seule fois au demarrage (main.dart).
///
/// [serverClientId] = Web client ID visible dans Firebase Console
///  > Authentication > Sign-in method > Google > Configuration web (OAuth 2.0).
/// Remplace la valeur ci-dessous par la tienne.
class GoogleSignInService {
  GoogleSignInService._();

  // -----------------------------------------------------------------------
  // REMPLACE cette valeur par ton Web Client ID Firebase :
  // Firebase Console > Authentication > Sign-in method > Google > Web client ID
  // -----------------------------------------------------------------------
  static const String serverClientId =
      '847684786362-q4fg9som5pbfmp6hjljh2b14ppf4tmig.apps.googleusercontent.com';

  static bool _initialized = false;


  // -----------------------------------------------------------------------
  // INITIALISATION  (appeler une seule fois dans main())
  // -----------------------------------------------------------------------

  /// Initialise le singleton [GoogleSignIn] et tente une re-connexion legere
  /// (sans UI) si l utilisateur etait deja connecte.
  ///
  /// Appeler **une seule fois** avant [runApp].
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Sur le Web, Firebase Auth gère directement l'authentification Google via signInWithPopup.
    // L'initialisation du plugin mobile google_sign_in n'est pas nécessaire sur le Web.
    if (kIsWeb) return;

    try {
      await GoogleSignIn.instance.initialize(
        // clientId : inutile sur Android (gere par google-services.json)
        //            et sur iOS (pris dans GoogleService-Info.plist).
        //            Obligatoire uniquement sur le Web.
        serverClientId: serverClientId,
      );

      // Écouter les événements Google avant de lancer le lightweight,
      // afin de ne manquer aucun événement émis immédiatement.
      GoogleSignIn.instance.authenticationEvents
          .listen(
            _onGoogleAuthEvent,
            onError: (Object error) {
              debugPrint('[GoogleSignInService] authenticationEvents error: $error');
            },
          );

      // IMPORTANT : Firebase Auth restaure sa session de façon asynchrone.
      // `currentUser` est null au tout début du démarrage même si l'utilisateur
      // était connecté. On attend donc le premier événement de authStateChanges
      // (avec timeout) pour savoir si une session est déjà active avant de décider
      // de lancer le lightweight sign-in.
      //
      // Si l'utilisateur est déjà connecté à Firebase, on ne déclenche PAS
      // attemptLightweightAuthentication afin d'éviter d'afficher le sélecteur
      // de compte Google inutilement.
      final firebaseUser = await FirebaseAuth.instance
          .authStateChanges()
          .first
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () => FirebaseAuth.instance.currentUser,
          );

      if (firebaseUser != null) {
        debugPrint(
          '[GoogleSignInService] Firebase session already active (${firebaseUser.email}), '
          'skipping attemptLightweightAuthentication.',
        );
        return;
      }

      // Tentative silencieuse : reconnecte l'utilisateur sans afficher d'UI
      // si celui-ci s'était déjà connecté avec Google précédemment.
      GoogleSignIn.instance.attemptLightweightAuthentication();
    } catch (e) {
      debugPrint('[GoogleSignInService] initialize error: $e');
    }
  }

  // -----------------------------------------------------------------------
  // TRAITEMENT DES EVENEMENTS GOOGLE (lightweight)
  // -----------------------------------------------------------------------

  /// Appele pour chaque evenement emis par [authenticationEvents].
  ///
  /// - [GoogleSignInAuthenticationEventSignIn] : l utilisateur a ete identifie
  ///   via le lightweight. On signe dans Firebase si aucune session n est deja
  ///   active.
  /// - [GoogleSignInAuthenticationEventSignOut] : on ne touche pas a Firebase
  ///   pour eviter une deconnexion involontaire.
  /// Les erreurs du stream sont capturees par le handler onError du listen.
  static Future<void> _onGoogleAuthEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    if (event is GoogleSignInAuthenticationEventSignIn) {
      await _signLightweightAccountToFirebase(event.user);
    }
    // GoogleSignInAuthenticationEventSignOut : on ne touche pas a Firebase
    // pour eviter une deconnexion involontaire (l utilisateur aurait a se
    // reconnecter manuellement via le bouton).
  }

  /// Convertit un [GoogleSignInAccount] issu du lightweight en session Firebase,
  /// **uniquement** si Firebase n a pas deja une session active.
  static Future<void> _signLightweightAccountToFirebase(
    GoogleSignInAccount account,
  ) async {
    // Ne pas ecraser une session Firebase deja valide.
    if (FirebaseAuth.instance.currentUser != null) {
      debugPrint(
        '[GoogleSignInService] Firebase session already active, skipping lightweight sign-in.',
      );
      return;
    }

    try {
      final String? idToken = account.authentication.idToken;

      if (idToken == null) {
        debugPrint(
          '[GoogleSignInService] lightweight: idToken null, skipping Firebase sign-in.',
        );
        return;
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await FirebaseAuth.instance.signInWithCredential(credential);

      debugPrint(
        '[GoogleSignInService] lightweight sign-in to Firebase successful.',
      );
    } catch (e) {
      // Echec non bloquant : l utilisateur pourra utiliser le bouton sign-in.
      debugPrint('[GoogleSignInService] lightweight Firebase sign-in error: $e');
    }
  }

  // -----------------------------------------------------------------------
  // CONNEXION INTERACTIVE
  // -----------------------------------------------------------------------

  /// Declenche le selecteur de compte Google et retourne un [OAuthCredential]
  /// pret a etre utilise avec [FirebaseAuth.signInWithCredential].
  ///
  /// Leve une [UnsupportedError] si la plateforme ne supporte pas
  /// l authentification interactive (ex. certains contextes Web).
  static Future<OAuthCredential> getFirebaseCredential() async {
    if (kIsWeb || !GoogleSignIn.instance.supportsAuthenticate()) {
      throw UnsupportedError(
        'La connexion Google interactive via GoogleSignIn n\'est pas disponible sur cette plateforme.',
      );
    }

    // Ouvre le selecteur de compte Google.
    final GoogleSignInAccount account = await GoogleSignIn.instance
        .authenticate();

    // Recupere le idToken pour Firebase.
    final String? idToken = account.authentication.idToken;

    if (idToken == null) {
      throw Exception(
        'Impossible d\'obtenir le idToken Google. '
        'Verifie que serverClientId est correctement configure.',
      );
    }

    return GoogleAuthProvider.credential(
      idToken: idToken,
      // accessToken non requis pour Firebase ; on le passe si disponible.
      accessToken: null,
    );
  }

  // -----------------------------------------------------------------------
  // DECONNEXION
  // -----------------------------------------------------------------------

  /// Deconnecte l utilisateur du cote Google Sign-In.
  /// A appeler en complement de [FirebaseAuth.signOut].
  static Future<void> signOut() async {
    if (kIsWeb) return;
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      // Echec non bloquant : la session Firebase sera tout de meme revoquee.
      debugPrint('[GoogleSignInService] signOut error: $e');
    }
  }
}
