import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/categorie.dart';

class CategorieRepository {
  final FirebaseFirestore _firestore;

  CategorieRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _categoriesCollection =>
      _firestore.collection('categories');

  Future<List<Categorie>> getCategories() async {
    final snapshot = await _categoriesCollection
        .where('estActive', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => Categorie.fromFirestore(doc)).toList();
  }

  Future<Categorie?> getCategorieById(String categorieId) async {
    final doc = await _categoriesCollection.doc(categorieId).get();

    if (!doc.exists) {
      return null;
    }

    return Categorie.fromFirestore(doc);
  }

  Future<List<Categorie>> searchCategories(String recherche) async {
    final snapshot = await _categoriesCollection
        .where('estActive', isEqualTo: true)
        .get();

    final rechercheLower = recherche.toLowerCase();

    return snapshot.docs
        .map((doc) => Categorie.fromFirestore(doc))
        .where(
          (categorie) => categorie.nom.toLowerCase().contains(rechercheLower),
        )
        .toList();
  }

  Future<void> ajouterCategorie(Categorie categorie) async {
    final docRef = categorie.categorieId.isNotEmpty
        ? _categoriesCollection.doc(categorie.categorieId)
        : _categoriesCollection.doc();
    final effectiveCategory = categorie.categorieId.isNotEmpty
        ? categorie
        : categorie.copyWith(categorieId: docRef.id);
    await docRef.set(effectiveCategory.toFirestore(), SetOptions(merge: true));
  }

  Future<void> modifierCategorie(Categorie categorie) async {
    await _categoriesCollection
        .doc(categorie.categorieId)
        .set(categorie.toFirestore(), SetOptions(merge: true));
  }

  Future<void> supprimerCategorie(String categorieId) async {
    await _categoriesCollection.doc(categorieId).delete();
  }

  /// Récupère toutes les catégories pour l'administration (actives et inactives)
  Future<List<Categorie>> getAllCategoriesAdmin() async {
    final snapshot = await _categoriesCollection.get();
    return snapshot.docs.map((doc) => Categorie.fromFirestore(doc)).toList();
  }

  /// Écoute en temps réel les catégories actives (pour les parents/utilisateurs)
  Stream<List<Categorie>> streamCategoriesActives() {
    return _categoriesCollection
        .where('estActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Categorie.fromFirestore(doc)).toList(),
        );
  }

  /// Écoute en temps réel toutes les catégories
  Stream<List<Categorie>> streamCategoriesAdmin() {
    return _categoriesCollection.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Categorie.fromFirestore(doc)).toList(),
    );
  }

  /// Active ou désactive une catégorie
  Future<void> toggleActif(String categorieId, bool estActive) async {
    await _categoriesCollection.doc(categorieId).set({
      'estActive': estActive,
      'estActif': estActive,
      'dateModification': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  /// Ajuste le compteur de jouets d'une catégorie
  Future<void> incrementerNombreJouets(String categorieId, int delta) async {
    await _categoriesCollection.doc(categorieId).set({
      'nombreJouets': FieldValue.increment(delta),
      'nombreJouetsDenormalise': FieldValue.increment(delta),
      'dateModification': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}
