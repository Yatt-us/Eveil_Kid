import 'package:cloud_firestore/cloud_firestore.dart';
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
      final initialParent = Utilisateur(
        utilisateurId: utilisateurId,
        role: UserRole.parent,
        nom: 'Aissata Traoré',
        email: 'aissata@example.com',
        nombreEnfants: enfants.length,
        enfants: enfants,
      );
      await _firestore
          .collection('utilisateurs')
          .doc(utilisateurId)
          .set(initialParent.toFirestore(), SetOptions(merge: true));
      return initialParent;
    }
    return Utilisateur.fromFirestore(data, userDoc.id, enfants: enfants);
  }

  @override
  Future<Utilisateur> fetchParentProfile(String utilisateurId) async {
    final userDoc = await _firestore
        .collection('utilisateurs')
        .doc(utilisateurId)
        .get();
    return _profileWithChildren(utilisateurId, userDoc);
  }

  @override
  Stream<Utilisateur> watchParentProfile(String utilisateurId) {
    return _firestore
        .collection('utilisateurs')
        .doc(utilisateurId)
        .snapshots()
        .asyncMap((userDoc) => _profileWithChildren(utilisateurId, userDoc));
  }

  @override
  Future<Utilisateur> updateParentProfile(Utilisateur parent) async {
    await _firestore
        .collection('utilisateurs')
        .doc(parent.utilisateurId)
        .set(parent.toFirestore(), SetOptions(merge: true));
    return parent;
  }

  @override
  Future<List<EnfantModel>> fetchEnfants(String utilisateurId) {
    return _enfantRepository.recupererEnfantsDuParent(utilisateurId);
  }

  @override
  Stream<List<EnfantModel>> watchEnfants(String utilisateurId) {
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
