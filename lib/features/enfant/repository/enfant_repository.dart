import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';

class EnfantRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final String _collection = 'enfants';

  // Récupérer un enfant.
  Future<EnfantModel?> recupererEnfant(
    String enfantId,
  ) async {
    final document = await _firestore
        .collection(_collection)
        .doc(enfantId)
        .get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return EnfantModel.fromMap(document.data()!);
  }

  // Récupérer tous les enfants d'un parent.
  Future<List<EnfantModel>> recupererEnfantsDuParent(
    String parentId,
  ) async {
    final resultat = await _firestore
        .collection(_collection)
        .where(
          'utilisateurId',
          isEqualTo: parentId,
        )
        .get();

    return resultat.docs
        .map(
          (document) =>
              EnfantModel.fromMap(document.data()),
        )
        .toList();
  }

  // Ajouter un enfant.
  Future<void> ajouterEnfant(
    EnfantModel enfant,
  ) async {
    await _firestore
        .collection(_collection)
        .doc(enfant.enfantId)
        .set(enfant.toMap());
  }

  // Modifier un enfant.
  Future<void> modifierEnfant(
    EnfantModel enfant,
  ) async {
    await _firestore
        .collection(_collection)
        .doc(enfant.enfantId)
        .update(enfant.toMap());
  }

  // Supprimer un enfant.
  Future<void> supprimerEnfant(
    String enfantId,
  ) async {
    await _firestore
        .collection(_collection)
        .doc(enfantId)
        .delete();
  }

  // Modifier uniquement la photo.
  Future<void> mettreAJourPhoto(
    String enfantId,
    String photoUrl,
  ) async {
    await _firestore
        .collection(_collection)
        .doc(enfantId)
        .update({
      'avatarUrl': photoUrl,
      'dateModification': Timestamp.now(),
    });
  }
}