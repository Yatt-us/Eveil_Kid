import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';

/// Repository chargé des interactions avec Firestore pour la sous-collection
/// 'enfants' d'un utilisateur.
class EnfantRepository {
  final FirebaseFirestore _firestore;

  EnfantRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _enfantsCollection(String parentId) {
    return _firestore
        .collection('utilisateurs')
        .doc(parentId)
        .collection('enfants');
  }

  Future<EnfantModel?> recupererEnfant({
    required String parentId,
    required String enfantId,
  }) async {
    try {
      final document = await _enfantsCollection(parentId).doc(enfantId).get();

      if (!document.exists || document.data() == null) {
        return null;
      }

      return EnfantModel.fromSnapshot(document);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EnfantModel>> recupererEnfantsDuParent(String parentId) async {
    try {
      final querySnapshot = await _enfantsCollection(parentId).get();
      return querySnapshot.docs
          .map((doc) => EnfantModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<EnfantModel>> suivreEnfantsDuParent(String parentId) {
    return _enfantsCollection(parentId).snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => EnfantModel.fromSnapshot(doc))
          .toList(),
    );
  }

  Future<void> ajouterEnfant({
    required String parentId,
    required EnfantModel enfant,
  }) async {
    try {
      await _enfantsCollection(parentId)
          .doc(enfant.enfantId)
          .set(enfant.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> modifierEnfant({
    required String parentId,
    required EnfantModel enfant,
  }) async {
    try {
      await _enfantsCollection(parentId)
          .doc(enfant.enfantId)
          .update(enfant.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> supprimerEnfant({
    required String parentId,
    required String enfantId,
  }) async {
    try {
      await _enfantsCollection(parentId).doc(enfantId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> mettreAJourPhoto({
    required String parentId,
    required String enfantId,
    required String photoUrl,
  }) async {
    try {
      await _enfantsCollection(parentId).doc(enfantId).update({
        'avatarUrl': photoUrl,
        'dateModification': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EnfantModel>> recupererEnfants(String parentId) async {
    return recupererEnfantsDuParent(parentId);
  }

  Future<void> ajouterEnfantLegacy({
    required String parentId,
    required EnfantModel enfant,
  }) async {
    await ajouterEnfant(parentId: parentId, enfant: enfant);
  }

  Future<void> modifierEnfantLegacy({
    required String parentId,
    required EnfantModel enfant,
  }) async {
    await modifierEnfant(parentId: parentId, enfant: enfant);
  }

  Future<void> supprimerEnfantLegacy({
    required String parentId,
    required String enfantId,
  }) async {
    await supprimerEnfant(parentId: parentId, enfantId: enfantId);
  }
}
