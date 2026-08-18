import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/utilisateur.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ===========================================================================
  // INSCRIPTION
  // ===========================================================================

  Future<void> register({
    required String email,
    required String password,
    required String nom,
    String? telephone,
  }) async {
    User? user;

    try {
      // -----------------------------------------------------------------------
      // 1. Création du compte Firebase Authentication
      // -----------------------------------------------------------------------

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = credential.user;

      if (user == null) {
        throw Exception(
          'Impossible de récupérer l’utilisateur créé.',
        );
      }

      // -----------------------------------------------------------------------
      // 2. Création du profil dans Firestore
      // -----------------------------------------------------------------------

      await _firestore
          .collection('utilisateurs')
          .doc(user.uid)
          .set({
        'utilisateurId': user.uid,

        // Une inscription publique crée toujours un PARENT.
        'role': 'PARENT',

        // Ces champs concernent uniquement le rôle PARENT.
        'nombreFavoris': 0,
        'nombreEnfants': 0,

        'email': user.email,
        'nom': nom,
        'photoUrl': null,
        'telephone': telephone,

        'estActif': true,

        'dateCreation': FieldValue.serverTimestamp(),
        'dateModification': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException {
      // L'inscription Firebase Auth a échoué.
      rethrow;
    } on FirebaseException {
      // Firebase Auth a peut-être réussi,
      // mais la création du profil Firestore a échoué.

      if (user != null) {
        try {
          await user.delete();
        } catch (_) {
          // On ne remplace pas l'erreur originale
          // par l'erreur de suppression.
        }
      }

      rethrow;
    }
  }

  // ===========================================================================
  // CONNEXION
  // ===========================================================================

  Future<Utilisateur> login({
    required String email,
    required String password,
  }) async {
    // -------------------------------------------------------------------------
    // 1. Connexion à Firebase Authentication
    // -------------------------------------------------------------------------

    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception(
        'Impossible de récupérer l’utilisateur connecté.',
      );
    }

    // -------------------------------------------------------------------------
    // 2. Récupération du profil Firestore
    // -------------------------------------------------------------------------

    final utilisateur = await getUserProfile(user.uid);

    // -------------------------------------------------------------------------
    // 3. Vérification du compte
    // -------------------------------------------------------------------------

    if (!utilisateur.estActif) {
      // On déconnecte immédiatement le compte Firebase.
      await _auth.signOut();

      throw Exception(
        'Ce compte est désactivé.',
      );
    }

    return utilisateur;
  }

  // ===========================================================================
  // RÉCUPÉRER LE PROFIL FIRESTORE
  // ===========================================================================

  Future<Utilisateur> getUserProfile(String uid) async {
    final document = await _firestore
        .collection('utilisateurs')
        .doc(uid)
        .get();

    // -------------------------------------------------------------------------
    // Le document n'existe pas
    // -------------------------------------------------------------------------

    if (!document.exists) {
      throw Exception(
        'Le profil utilisateur est introuvable.',
      );
    }

    final data = document.data();

    if (data == null) {
      throw Exception(
        'Les données utilisateur sont introuvables.',
      );
    }

    // -------------------------------------------------------------------------
    // Transformation Map → Utilisateur
    // -------------------------------------------------------------------------

    return Utilisateur.fromMap(data);
  }

  // ===========================================================================
  // UTILISATEUR FIREBASE ACTUEL
  // ===========================================================================

  User? get currentFirebaseUser {
    return _auth.currentUser;
  }

  // ===========================================================================
  // PROFIL DE L'UTILISATEUR ACTUEL
  // ===========================================================================

  Future<Utilisateur?> getCurrentUserProfile() async {
    final user = _auth.currentUser;

    // Aucun utilisateur connecté.
    if (user == null) {
      return null;
    }

    final utilisateur = await getUserProfile(user.uid);

    // -------------------------------------------------------------------------
    // Vérification du compte
    // -------------------------------------------------------------------------

    if (!utilisateur.estActif) {
      await _auth.signOut();
      return null;
    }

    return utilisateur;
  }

  // ===========================================================================
  // SESSION / ÉTAT D'AUTHENTIFICATION
  // ===========================================================================

  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  // ===========================================================================
  // MOT DE PASSE OUBLIÉ
  // ===========================================================================

  Future<void> resetPassword({
    required String email,
  }) async {
    await _auth.sendPasswordResetEmail(
      email: email,
    );
  }

  // ===========================================================================
  // DÉCONNEXION
  // ===========================================================================

  Future<void> logout() async {
    await _auth.signOut();
  }
}