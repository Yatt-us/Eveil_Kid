import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_category_model.dart';
import '../mappers/activity_category_mapper.dart';

class ActiviteCategorieRepository {
  final CollectionReference _categoriesRef = 
      FirebaseFirestore.instance.collection('categories_activites');

  // Récupérer toutes les catégories actives
  Future<List<ActiviteCategorie>> getCategoriesActives() async {
  try {
    final snapshot = await _categoriesRef
        .where('estActive', isEqualTo: true)
        .orderBy('ordreAffichage')
        .get();

    print('Nombre de catégories trouvées : ${snapshot.docs.length}');

    for (final doc in snapshot.docs) {
      print('ID : ${doc.id}');
      print('DATA : ${doc.data()}');
    }

    return ActiviteCategorieMapper.fromFirestoreList(snapshot.docs);
  } catch (e) {
    print('ERREUR FIRESTORE : $e');
    throw Exception(
      'Erreur lors de la récupération des catégories: $e',
    );
  }
}

  // Récupérer toutes les catégories (pour admin)
  Future<List<ActiviteCategorie>> getAllCategories() async {
    try {
      final snapshot = await _categoriesRef
          .orderBy('ordreAffichage')
          .get();
      
      return ActiviteCategorieMapper.fromFirestoreList(snapshot.docs);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des catégories: $e');
    }
  }

  // Récupérer une catégorie par ID
  Future<ActiviteCategorie?> getCategorieById(String id) async {
    try {
      final doc = await _categoriesRef.doc(id).get();
      if (doc.exists) {
        return ActiviteCategorieMapper.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la catégorie: $e');
    }
  }
}