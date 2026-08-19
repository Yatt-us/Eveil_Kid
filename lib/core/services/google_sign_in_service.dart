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

    await GoogleSignIn.instance.initialize(
      // clientId : inutile sur Android (gere par google-services.json)
      //            et sur iOS (pris dans GoogleService-Info.plist).
      //            Obligatoire uniquement sur le Web.
      serverClientId: serverClientId,
    );

    // Tentative silencieuse : reconnecte l utilisateur sans afficher d UI
    // si celui-ci s etait deja connecte precedemment.
    GoogleSignIn.instance.attemptLightweightAuthentication();
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
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw UnsupportedError(
        'La connexion Google interactive n\'est pas disponible sur cette plateforme.',
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
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      // Echec non bloquant : la session Firebase sera tout de meme revoquee.
      debugPrint('[GoogleSignInService] signOut error: $e');
    }
  }
}
