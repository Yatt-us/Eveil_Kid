import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_category_model.dart';

class ActiviteCategorieMapper {
  static ActiviteCategorie fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ActiviteCategorie(
      id: doc.id,
      nom: data['nom'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'],
      couleur: data['couleur'],
      ordreAffichage: data['ordreAffichage'] ?? 0,
      estActive: data['estActive'] ?? true,
      dateCreation: (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateModification: (data['dateModification'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

   static Map<String, dynamic> toFirestore(ActiviteCategorie categorie) {
    return {
      'nom': categorie.nom,
      'description': categorie.description,
      if (categorie.icon != null) 'icon': categorie.icon,
      if (categorie.couleur != null) 'couleur': categorie.couleur,
      'ordreAffichage': categorie.ordreAffichage,
      'estActive': categorie.estActive,
     
      if (categorie.dateCreation != null) 
        'dateCreation': Timestamp.fromDate(categorie.dateCreation!),
      if (categorie.dateModification != null) 
        'dateModification': Timestamp.fromDate(categorie.dateModification!),
    };
  }

  static List<ActiviteCategorie> fromFirestoreList(List<DocumentSnapshot> docs) {
    return docs.map((doc) => fromFirestore(doc)).toList();
  }
}