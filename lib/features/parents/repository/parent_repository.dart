import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eveilkid/features/auth/models/utilisateur.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import 'package:eveilkid/features/enfant/repository/enfant_repository.dart';

abstract class ParentRepository {
  Future<Utilisateur> fetchParentProfile(String utilisateurId);
  Stream<Utilisateur> watchParentProfile(String utilisateurId);
  Future<Utilisateur> updateParentProfile(Utilisateur parent);
  Future<List<EnfantModel>> fetchEnfants(String utilisateurId);
  Stream<List<EnfantModel>> watchEnfants(String utilisateurId);
  Future<void> ajouterEnfant(EnfantModel enfant);
  Future<void> modifierEnfant(EnfantModel enfant);
  Future<void> supprimerEnfant(String enfantId, String utilisateurId);
}

class ParentFirestoreRepository implements ParentRepository {
  final FirebaseFirestore _firestore;
  final EnfantRepository _enfantRepository;

  ParentFirestoreRepository({
    FirebaseFirestore? firestore,
    EnfantRepository? enfantRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _enfantRepository =
           enfantRepository ?? EnfantRepository(firestore: firestore);

  Future<Utilisateur> _profileWithChildren(
    String utilisateurId,
    DocumentSnapshot<Map<String, dynamic>> userDoc,
  ) async {
    final enfants = await fetchEnfants(utilisateurId);
    final data = userDoc.data();
    if (!userDoc.exists || data == null) {
      final authUser = FirebaseAuth.instance.currentUser;
      final isCurrentAuthUser = authUser != null && authUser.uid == utilisateurId;
      return Utilisateur(
        utilisateurId: utilisateurId,
        role: UserRole.parent,
        nom: isCurrentAuthUser ? (authUser.displayName ?? 'Parent') : 'Parent',
        email: isCurrentAuthUser ? (authUser.email ?? '') : '',
        nombreEnfants: enfants.length,
        enfants: enfants,
      );
    }
    return Utilisateur.fromFirestore(data, userDoc.id, enfants: enfants);
  }

  @override
  Future<Utilisateur> fetchParentProfile(String utilisateurId) async {
    if (utilisateurId.isEmpty) {
      return const Utilisateur(utilisateurId: '');
    }
    final userDoc = await _firestore
        .collection('utilisateurs')
        .doc(utilisateurId)
        .get();
    return _profileWithChildren(utilisateurId, userDoc);
  }

  @override
  Stream<Utilisateur> watchParentProfile(String utilisateurId) {
    if (utilisateurId.isEmpty) {
      return Stream.value(const Utilisateur(utilisateurId: ''));
    }
    return _firestore
        .collection('utilisateurs')
        .doc(utilisateurId)
        .snapshots()
        .asyncMap((userDoc) => _profileWithChildren(utilisateurId, userDoc));
  }

  @override
  Future<Utilisateur> updateParentProfile(Utilisateur parent) async {
    final docRef = _firestore.collection('utilisateurs').doc(parent.utilisateurId);
    
    // Mettre à jour uniquement les informations personnelles sans écraser le rôle existant dans Firestore
    await docRef.set({
      'utilisateurId': parent.utilisateurId,
      'nom': parent.nom,
      'email': parent.email,
      if (parent.telephone != null) 'telephone': parent.telephone,
      if (parent.photoUrl != null) 'photoUrl': parent.photoUrl,
      'dateModification': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Recharger le document pour renvoyer le profil complet avec son rôle d'origine préservé
    final docSnap = await docRef.get();
    if (docSnap.exists && docSnap.data() != null) {
      return _profileWithChildren(parent.utilisateurId, docSnap);
    }
    return parent;
  }

  @override
  Future<List<EnfantModel>> fetchEnfants(String utilisateurId) {
    if (utilisateurId.isEmpty) return Future.value([]);
    return _enfantRepository.recupererEnfantsDuParent(utilisateurId);
  }

  @override
  Stream<List<EnfantModel>> watchEnfants(String utilisateurId) {
    if (utilisateurId.isEmpty) return Stream.value([]);
    return _enfantRepository.suivreEnfantsDuParent(utilisateurId);
  }

  @override
  Future<void> ajouterEnfant(EnfantModel enfant) {
    return _enfantRepository.ajouterEnfant(
      parentId: enfant.utilisateurId,
      enfant: enfant,
    );
  }

  @override
  Future<void> modifierEnfant(EnfantModel enfant) {
    return _enfantRepository.modifierEnfant(
      parentId: enfant.utilisateurId,
      enfant: enfant,
    );
  }

  @override
  Future<void> supprimerEnfant(String enfantId, String utilisateurId) {
    return _enfantRepository.supprimerEnfant(
      parentId: utilisateurId,
      enfantId: enfantId,
    );
  }
}
