import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/categorie.dart';

class CategorieRepository {
  final FirebaseFirestore _firestore;

  CategorieRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _categoriesCollection =>  _firestore.collection('categories');


  Future<List<Categorie>> getCategories() async {
    final snapshot = await _categoriesCollection
        .where('estActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => Categorie.fromFirestore(doc))
        .toList();
  }

  Future<Categorie?> getCategorieById(
    String categorieId,
  ) async {
    final doc = await _categoriesCollection
        .doc(categorieId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return Categorie.fromFirestore(doc);
  }

  Future<List<Categorie>> getCategoriesPrincipales() async {
    final snapshot = await _categoriesCollection
        .where('parentId', isNull: true)
        .where('estActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => Categorie.fromFirestore(doc))
        .toList();
  }

  Future<List<Categorie>> getSousCategories(
    String parentId,
  ) async {
    final snapshot = await _categoriesCollection
        .where('parentId', isEqualTo: parentId)
        .where('estActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => Categorie.fromFirestore(doc))
        .toList();
  }

  Future<List<Categorie>> searchCategories(
    String recherche,
  ) async {
    final snapshot = await _categoriesCollection
        .where('estActive', isEqualTo: true)
        .get();

    final rechercheLower = recherche.toLowerCase();

    return snapshot.docs
        .map((doc) => Categorie.fromFirestore(doc))
        .where(
          (categorie) =>
              categorie.nom.toLowerCase().contains(
                    rechercheLower,
                  ),
        )
        .toList();
  }

  Future<void> ajouterCategorie(
    Categorie categorie,
  ) async {
    await _categoriesCollection
        .doc(categorie.categorieId)
        .set(categorie.toFirestore());
  }

  Future<void> modifierCategorie(
    Categorie categorie,
  ) async {
    await _categoriesCollection
        .doc(categorie.categorieId)
        .update(categorie.toFirestore());
  }
  Future<void> supprimerCategorie(
    String categorieId,
  ) async {
    await _categoriesCollection
        .doc(categorieId)
        .delete();
  }
}