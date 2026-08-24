// lib/features/parent/repository/parent_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parent_model.dart';

abstract class ParentRepository {
  Future<UtilisateurModel> fetchParentProfile(String utilisateurId);
  Stream<UtilisateurModel> watchParentProfile(String utilisateurId);
  Future<UtilisateurModel> updateParentProfile(UtilisateurModel parent);
  Future<List<EnfantModel>> fetchEnfants(String utilisateurId);
  Stream<List<EnfantModel>> watchEnfants(String utilisateurId);
  Future<void> ajouterEnfant(EnfantModel enfant);
  Future<void> modifierEnfant(EnfantModel enfant);
  Future<void> supprimerEnfant(String enfantId, String utilisateurId);
}

class ParentFirestoreRepository implements ParentRepository {
  final FirebaseFirestore _firestore;

  ParentFirestoreRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _utilisateursCollection =>
      _firestore.collection('utilisateurs');

  CollectionReference<Map<String, dynamic>> get _enfantsCollection =>
      _firestore.collection('enfants');

  @override
  Future<UtilisateurModel> fetchParentProfile(String utilisateurId) async {
    final userDoc = await _utilisateursCollection.doc(utilisateurId).get();

    final enfantsSnapshot = await _enfantsCollection
        .where('utilisateurId', isEqualTo: utilisateurId)
        .where('estActif', isEqualTo: true)
        .get();

    final enfants = enfantsSnapshot.docs
        .map((doc) => EnfantModel.fromFirestore(doc.data(), doc.id))
        .toList();

    if (!userDoc.exists || userDoc.data() == null) {
      // Document utilisateur par défaut dans Firestore si inexistant
      final initialParent = UtilisateurModel(
        utilisateurId: utilisateurId,
        role: UserRole.PARENT,
        nom: 'Aissata Traoré',
        email: 'aissata@example.com',
        nombreEnfants: enfants.length,
        enfants: enfants,
      );

      await _utilisateursCollection
          .doc(utilisateurId)
          .set(initialParent.toFirestore(), SetOptions(merge: true));

      return initialParent;
    }

    return UtilisateurModel.fromFirestore(
      userDoc.data()!,
      userDoc.id,
      enfants: enfants,
    );
  }

  @override
  Stream<UtilisateurModel> watchParentProfile(String utilisateurId) {
    return _utilisateursCollection.doc(utilisateurId).snapshots().asyncMap((userDoc) async {
      final enfantsSnapshot = await _enfantsCollection
          .where('utilisateurId', isEqualTo: utilisateurId)
          .where('estActif', isEqualTo: true)
          .get();

      final enfants = enfantsSnapshot.docs
          .map((doc) => EnfantModel.fromFirestore(doc.data(), doc.id))
          .toList();

      if (!userDoc.exists || userDoc.data() == null) {
        return UtilisateurModel(
          utilisateurId: utilisateurId,
          role: UserRole.PARENT,
          nom: 'Aissata Traoré',
          email: 'aissata@example.com',
          enfants: enfants,
        );
      }

      return UtilisateurModel.fromFirestore(
        userDoc.data()!,
        userDoc.id,
        enfants: enfants,
      );
    });
  }

  @override
  Future<UtilisateurModel> updateParentProfile(UtilisateurModel parent) async {
    await _utilisateursCollection.doc(parent.utilisateurId).set(
          parent.toFirestore(),
          SetOptions(merge: true),
        );
    return parent;
  }

  @override
  Future<List<EnfantModel>> fetchEnfants(String utilisateurId) async {
    final query = await _enfantsCollection
        .where('utilisateurId', isEqualTo: utilisateurId)
        .where('estActif', isEqualTo: true)
        .get();

    return query.docs
        .map((doc) => EnfantModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Stream<List<EnfantModel>> watchEnfants(String utilisateurId) {
    return _enfantsCollection
        .where('utilisateurId', isEqualTo: utilisateurId)
        .where('estActif', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EnfantModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<void> ajouterEnfant(EnfantModel enfant) async {
    final docRef = _enfantsCollection.doc(enfant.enfantId.isNotEmpty ? enfant.enfantId : null);
    final toSave = enfant.copyWith(enfantId: docRef.id);

    await docRef.set(toSave.toFirestore());

    // Mettre à jour le compteur dénormalisé dans la collection 'utilisateurs'
    await _utilisateursCollection.doc(enfant.utilisateurId).update({
      'nombreEnfants': FieldValue.increment(1),
      'dateModification': Timestamp.now(),
    }).catchError((_) {});
  }

  @override
  Future<void> modifierEnfant(EnfantModel enfant) async {
    await _enfantsCollection.doc(enfant.enfantId).update(enfant.toFirestore());
  }

  @override
  Future<void> supprimerEnfant(String enfantId, String utilisateurId) async {
    await _enfantsCollection.doc(enfantId).update({
      'estActif': false,
      'dateModification': Timestamp.now(),
    });

    // Mettre à jour le compteur dénormalisé
    await _utilisateursCollection.doc(utilisateurId).update({
      'nombreEnfants': FieldValue.increment(-1),
      'dateModification': Timestamp.now(),
    }).catchError((_) {});
  }
}