import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/services/google_sign_in_service.dart';
import '../models/utilisateur.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  // INSCRIPTION

  Future<void> register({
    required String email,
    required String password,
    required String nom,
    String? telephone,
    UserRole role = UserRole.parent,
  }) async {
    User? user;

    try {
      // Création du compte Firebase Authentication

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = credential.user;

      if (user == null) {
        throw Exception('Impossible de récupérer l’utilisateur créé.');
      }

      // Envoi d’un email de vérification
      await user.sendEmailVerification();

      //  Création du profil dans Firestore

      await _firestore.collection('utilisateurs').doc(user.uid).set({
        'utilisateurId': user.uid,

        // Une inscription publique crée un PARENT.
        'role': role.value,

        // Ces champs concernent uniquement le rôle PARENT.
        'nombreFavoris': role == UserRole.parent ? 0 : null,
        'nombreEnfants': role == UserRole.parent ? 0 : null,

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

  // CONNEXION

  Future<Utilisateur> login({
    required String email,
    required String password,
  }) async {
    //  Connexion à Firebase Authentication

    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Impossible de récupérer l’utilisateur connecté.');
    }

    //  Récupération du profil Firestore

    final utilisateur = await getUserProfile(user.uid);

    //  Vérification du compte

    if (!utilisateur.estActif) {
      // On déconnecte immédiatement le compte Firebase.
      await _auth.signOut();

      throw Exception('Ce compte est désactivé.');
    }

    return utilisateur;
  }

  // RÉCUPÉRER LE PROFIL FIRESTORE

  Future<Utilisateur> getUserProfile(String uid) async {
    final document = await _firestore.collection('utilisateurs').doc(uid).get();

    // Le document n'existe pas

    if (!document.exists) {
      throw Exception('Le profil utilisateur est introuvable.');
    }

    final data = document.data();

    if (data == null) {
      throw Exception('Les données utilisateur sont introuvables.');
    }

    // Transformation Map → Utilisateur

    return Utilisateur.fromMap(data);
  }

  // UTILISATEUR FIREBASE ACTUEL

  User? get currentFirebaseUser {
    return _auth.currentUser;
  }

  // PROFIL DE L'UTILISATEUR ACTUEL

  Future<Utilisateur?> getCurrentUserProfile() async {
    final user = _auth.currentUser;

    // Aucun utilisateur connecté.
    if (user == null) {
      return null;
    }

    final utilisateur = await getUserProfile(user.uid);

    // Vérification du compte

    if (!utilisateur.estActif) {
      await _auth.signOut();
      return null;
    }

    return utilisateur;
  }

  // SESSION / ÉTAT D'AUTHENTIFICATION

  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  // MOT DE PASSE OUBLIÉ

  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // CONNEXION GOOGLE

  Future<Utilisateur> signInWithGoogle() async {
    // 1. Obtenir le credential Firebase via Google Sign-In v7+
    final OAuthCredential credential =
        await GoogleSignInService.getFirebaseCredential();

    // 2. Signer dans Firebase Auth
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user == null) {
      throw Exception('Impossible de recuperer l\'utilisateur Google.');
    }

    // 3. Creer le profil Firestore si c est un nouvel utilisateur
    final docRef = _firestore.collection('utilisateurs').doc(user.uid);
    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      await docRef.set({
        'utilisateurId': user.uid,
        'role': 'PARENT',
        'nombreFavoris': 0,
        'nombreEnfants': 0,
        'email': user.email,
        'nom': user.displayName ?? 'Utilisateur',
        'photoUrl': user.photoURL,
        'telephone': null,
        'estActif': true,
        'dateCreation': FieldValue.serverTimestamp(),
        'dateModification': FieldValue.serverTimestamp(),
      });
    }

    // 4. Recuperer et verifier le profil
    final utilisateur = await getUserProfile(user.uid);
    if (!utilisateur.estActif) {
      await _auth.signOut();
      await GoogleSignInService.signOut();
      throw Exception('Ce compte utilisateur a ete desactive.');
    }

    return utilisateur;
  }

  // DECONNEXION

  Future<void> logout() async {
    await _auth.signOut();
    // Deconnexion Google pour forcer la selection de compte a la prochaine connexion.
    await GoogleSignInService.signOut();
  }
}
