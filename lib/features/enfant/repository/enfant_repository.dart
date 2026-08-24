import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';

class EnfantRepository {
  final FirebaseFirestore _firestore;

  EnfantRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _enfantsCollection(
    String parentId,
  ) {
    return _firestore
        .collection('utilisateurs')
        .doc(parentId)
        .collection('enfants');
  }

  Future<EnfantModel?> recupererEnfant({
    required String parentId,
    required String enfantId,
  }) async {
    final document = await _enfantsCollection(parentId).doc(enfantId).get();
    if (!document.exists || document.data() == null) return null;
    return EnfantModel.fromSnapshot(document);
  }

  Future<List<EnfantModel>> recupererEnfantsDuParent(String parentId) async {
    final querySnapshot = await _enfantsCollection(parentId).get();
    return querySnapshot.docs
        .map(EnfantModel.fromSnapshot)
        .where((enfant) => enfant.estActif)
        .toList();
  }

  Stream<List<EnfantModel>> suivreEnfantsDuParent(String parentId) {
    return _enfantsCollection(parentId).snapshots().map(
      (snapshot) => snapshot.docs
          .map(EnfantModel.fromSnapshot)
          .where((enfant) => enfant.estActif)
          .toList(),
    );
  }

  Future<void> ajouterEnfant({
    required String parentId,
    required EnfantModel enfant,
  }) async {
    await _enfantsCollection(parentId).doc(enfant.enfantId).set(enfant.toMap());
  }

  Future<void> modifierEnfant({
    required String parentId,
    required EnfantModel enfant,
  }) async {
    await _enfantsCollection(
      parentId,
    ).doc(enfant.enfantId).update(enfant.toMap());
  }

  Future<void> supprimerEnfant({
    required String parentId,
    required String enfantId,
  }) async {
    await _enfantsCollection(parentId).doc(enfantId).update({
      'estActif': false,
      'dateModification': Timestamp.now(),
    });
  }

  Future<void> mettreAJourPhoto({
    required String parentId,
    required String enfantId,
    required String photoUrl,
  }) async {
    await _enfantsCollection(parentId).doc(enfantId).update({
      'avatarUrl': photoUrl,
      'dateModification': Timestamp.now(),
    });
  }
}
