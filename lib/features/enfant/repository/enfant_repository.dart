import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';

/// Repository chargé des interactions avec Firestore pour la sous-collection 'enfants' d'un utilisateur.
class EnfantRepository {
  final FirebaseFirestore _firestore;

  EnfantRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Aide privée pour générer proprement le chemin d'accès à la sous-collection d'un parent.
  CollectionReference<Map<String, dynamic>> _enfantsCollection(String parentId) {
    return _firestore
        .collection('utilisateurs')
        .doc(parentId)
        .collection('enfants');
  }

  /// Récupère un enfant spécifique à partir de son identifiant et de celui de son parent.
  Future<EnfantModel?> recupererEnfant({
    required String parentId,
    required String enfantId,
  }) async {
    try {
      final document = await _enfantsCollection(parentId).doc(enfantId).get();

      if (!document.exists || document.data() == null) {
        return null;
      }

      // Utilisation dynamique du constructeur fromSnapshot adapté pour Firestore
      return EnfantModel.fromSnapshot(document);
    } catch (e) {
      rethrow;
    }
  }

  /// Récupère la liste de tous les enfants appartenant à un parent (utilisateurId).
  Future<List<EnfantModel>> recupererEnfantsDuParent(String parentId) async {
    try {
      // Plus besoin de filtre .where(), la sous-collection isole déjà les enfants de ce parent
      final querySnapshot = await _enfantsCollection(parentId).get();

      return querySnapshot.docs
          .map((doc) => EnfantModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Ajoute un nouvel enfant dans la sous-collection du parent.
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

  /// Met à jour les informations complètes d'un enfant.
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

  /// Supprime un enfant de la base de données.
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

  /// Met à jour uniquement la photo d'avatar d'un enfant.
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
}
