import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/google_sign_in_service.dart';
import '../models/utilisateur.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const String _pendingUserPrefix = 'pending_user_';

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ── GESTION DU STOCKAGE LOCAL DES INSCRIPTIONS EN ATTENTE ──

  Future<void> _savePendingRegistrationLocal({
    required String uid,
    required String email,
    required String nom,
    String? telephone,
    String role = 'PARENT',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode({
      'utilisateurId': uid,
      'role': role,
      'nombreFavoris': 0,
      'nombreEnfants': 0,
      'email': email,
      'nom': nom,
      'photoUrl': null,
      'telephone': telephone,
      'estActif': true,
      'dateCreation': DateTime.now().toIso8601String(),
      'dateModification': DateTime.now().toIso8601String(),
    });
    await prefs.setString('$_pendingUserPrefix$uid', data);
  }

  Future<Map<String, dynamic>?> _getPendingRegistrationLocal(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_pendingUserPrefix$uid');
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearPendingRegistrationLocal(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_pendingUserPrefix$uid');
  }

  // INSCRIPTION : Création Auth + Stockage Local (SharedPreferences) uniquement

  Future<void> register({
    required String email,
    required String password,
    required String nom,
    String? telephone,
  }) async {
    try {
      // 1. Création du compte Firebase Authentication
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception(
          'Impossible de récupérer l’utilisateur créé.',
        );
      }

      // 2. Mise à jour du displayName
      await user.updateDisplayName(nom);

      // 3. Stockage local dans SharedPreferences (pas d'envoi Firestore avant validation)
      await _savePendingRegistrationLocal(
        uid: user.uid,
        email: user.email ?? email,
        nom: nom,
        telephone: telephone,
      );

      // 4. Envoi du mail de confirmation
      await user.sendEmailVerification();
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      debugPrint('Erreur lors de l\'inscription: $e');
      rethrow;
    }
  }

  // SYNCHRONISATION VERS FIRESTORE APRÈS VÉRIFICATION DE L'EMAIL

  Future<Utilisateur> syncPendingUserToFirestoreIfVerified(String uid) async {
    final user = _auth.currentUser;
    if (user != null && user.uid == uid) {
      try {
        await user.reload();
      } catch (_) {}
    }
    final refreshedUser = _auth.currentUser ?? user;

    // 1. D'abord, vérifier si le document existe DÉJÀ dans Firestore
    final docRef = _firestore.collection('utilisateurs').doc(uid);
    final docSnap = await docRef.get();

    if (docSnap.exists && docSnap.data() != null) {
      // Le document existe déjà dans Firestore (ex: ADMIN, MANAGER, ou compte déjà synchronisé).
      // Ne JAMAIS écraser les données ni le rôle existant !
      await _clearPendingRegistrationLocal(uid);
      return Utilisateur.fromMap(docSnap.data()!);
    }

    final isVerified = refreshedUser != null &&
        refreshedUser.uid == uid &&
        refreshedUser.emailVerified;

    if (!isVerified) {
      // Si le compte n'est pas encore vérifié, on lit depuis SharedPreferences
      final localData = await _getPendingRegistrationLocal(uid);
      if (localData != null) {
        return Utilisateur.fromMap(localData);
      }
      return Utilisateur(
        utilisateurId: uid,
        role: UserRole.parent,
        email: refreshedUser?.email ?? '',
        nom: refreshedUser?.displayName ?? 'Parent',
        estActif: true,
      );
    }

    // Le compte est vérifié et n'existe pas encore dans Firestore : on le crée
    final localData = await _getPendingRegistrationLocal(uid);

    final email = refreshedUser.email ?? localData?['email'] ?? '';
    final nom = ((localData?['nom'] as String?)?.isNotEmpty == true)
        ? (localData!['nom'] as String)
        : (refreshedUser.displayName ??
            (email.isNotEmpty ? email.split('@')[0] : 'Parent'));
    final telephone = localData?['telephone'];
    final role = localData?['role'] ?? 'PARENT';

    final firestoreData = {
      'utilisateurId': uid,
      'role': role,
      'nombreFavoris': localData?['nombreFavoris'] ?? 0,
      'nombreEnfants': localData?['nombreEnfants'] ?? 0,
      'email': email,
      'nom': nom,
      'photoUrl': refreshedUser.photoURL,
      'telephone': telephone,
      'estActif': true,
      'dateCreation': FieldValue.serverTimestamp(),
      'dateModification': FieldValue.serverTimestamp(),
    };

    // Écriture initiale dans Firestore
    await docRef.set(firestoreData);

    // Suppression des données locales dans SharedPreferences après succès
    await _clearPendingRegistrationLocal(uid);

    // Lecture du profil créé
    final createdSnap = await docRef.get();
    if (createdSnap.exists && createdSnap.data() != null) {
      return Utilisateur.fromMap(createdSnap.data()!);
    }

    return Utilisateur(
      utilisateurId: uid,
      role: UserRole.fromValue(role),
      nombreFavoris: 0,
      nombreEnfants: 0,
      email: email,
      nom: nom,
      photoUrl: refreshedUser.photoURL,
      telephone: telephone,
      estActif: true,
    );
  }

  // CONNEXION

  Future<Utilisateur> login({
    required String email,
    required String password,
  }) async {
    // Connexion à Firebase Authentication
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

    // Récupération du profil
    final utilisateur = await getUserProfile(user.uid);

    // Vérification de l'état actif du compte
    if (!utilisateur.estActif) {
      await _auth.signOut();
      throw Exception(
        'Ce compte est désactivé.',
      );
    }

    return utilisateur;
  }

  // RÉCUPÉRER LE PROFIL UTILISATEUR

  Future<Utilisateur> getUserProfile(String uid) async {
    final user = _auth.currentUser;
    if (user != null && user.uid == uid) {
      try {
        await user.reload();
      } catch (_) {}
    }
    final refreshedUser = _auth.currentUser ?? user;

    // 1. Toujours vérifier d'abord si le document existe dans Firestore
    final docRef = _firestore.collection('utilisateurs').doc(uid);
    final docSnap = await docRef.get();

    if (docSnap.exists && docSnap.data() != null) {
      // Document Firestore existant -> Nettoyer le pending local s'il existe et retourner le profil officiel
      await _clearPendingRegistrationLocal(uid);
      return Utilisateur.fromMap(docSnap.data()!);
    }

    // 2. Si le document n'existe pas encore dans Firestore :
    // Si l'utilisateur est vérifié, synchroniser la création vers Firestore
    if (refreshedUser != null &&
        refreshedUser.uid == uid &&
        refreshedUser.emailVerified) {
      return await syncPendingUserToFirestoreIfVerified(uid);
    }

    // 3. Si l'utilisateur est connecté mais non vérifié, on lit depuis SharedPreferences
    final localData = await _getPendingRegistrationLocal(uid);
    if (localData != null) {
      return Utilisateur.fromMap(localData);
    }

    // 4. Fallback si l'utilisateur est présent dans Auth
    if (refreshedUser != null && refreshedUser.uid == uid) {
      final fallbackEmail = refreshedUser.email ?? '';
      final fallbackNom = refreshedUser.displayName ??
          (fallbackEmail.isNotEmpty ? fallbackEmail.split('@')[0] : 'Parent');

      return Utilisateur(
        utilisateurId: uid,
        role: UserRole.parent,
        nombreFavoris: 0,
        nombreEnfants: 0,
        email: fallbackEmail,
        nom: fallbackNom,
        photoUrl: refreshedUser.photoURL,
        telephone: null,
        estActif: true,
      );
    }

    throw Exception(
      'Le profil utilisateur est introuvable.',
    );
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

  Future<void> resetPassword({
    required String email,
  }) async {
    await _auth.sendPasswordResetEmail(
      email: email,
    );
  }

  // RENVOI DE L'EMAIL DE VÉRIFICATION

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    }
  }

  // VÉRIFICATION DU STATUT EMAIL

  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return _auth.currentUser?.emailVerified ?? false;
    }
    return false;
  }

  // CONNEXION GOOGLE

  Future<Utilisateur> signInWithGoogle() async {
    User? user;

    if (kIsWeb) {
      // Sur le Web, Firebase Auth gère directement la popup Google OAuth
      final googleProvider = GoogleAuthProvider();
      final userCredential = await _auth.signInWithPopup(googleProvider);
      user = userCredential.user;
    } else {
      // 1. Obtenir le credential Firebase via Google Sign-In v7+ sur mobile
      final OAuthCredential credential =
          await GoogleSignInService.getFirebaseCredential();

      // 2. Signer dans Firebase Auth
      final userCredential = await _auth.signInWithCredential(credential);
      user = userCredential.user;
    }

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
      if (!kIsWeb) {
        await GoogleSignInService.signOut();
      }
      throw Exception('Ce compte utilisateur a ete desactive.');
    }

    return utilisateur;
  }

  // DECONNEXION

  Future<void> logout() async {
    await _auth.signOut();
    if (!kIsWeb) {
      // Deconnexion Google pour forcer la selection de compte a la prochaine connexion.
      await GoogleSignInService.signOut();
    }
  }
}