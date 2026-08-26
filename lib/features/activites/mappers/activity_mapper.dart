import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/activites/models/activity.dart';

import '../enums/publication_status.enum.dart';

class ActivityMapper {
  static Activite fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Activite(
      id: doc.id,
      titre: data['titre'] ?? '',
      description: data['description'] ?? '',
      categorieId: data['categorieId'] ?? '',
      difficulte: data['difficulte'] ?? 'facile',
      ageMinimum: data['ageMinimum'] ?? 3,
      ageMaximum: data['ageMaximum'] ?? 6,
      dureeEnMinutes: data['dureeEnMinutes'] ?? 5,
      materiels: List<String>.from(data['materiels'] ?? []),
      objectifsApprentissage: List<String>.from(data['objectifsApprentissage'] ?? []),
      statut: PublicationStatusExtension.fromString(
        data['statut'] ?? 'brouillon'
      ),
      imageUrl: data['imageUrl'],
      points: data['points'] ?? 0,
      dateCreation: (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateModification: (data['dateModification'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ordreAffichage: data['ordreAffichage'] ?? 0,
    );
  }

  static Map<String, dynamic> toFirestore(Activite activite) {
    return {
      'titre': activite.titre,
      'description': activite.description,
      'categorieId': activite.categorieId,
      'difficulte': activite.difficulte,
      'ageMinimum': activite.ageMinimum,
      'ageMaximum': activite.ageMaximum,
      'dureeEnMinutes': activite.dureeEnMinutes,
      'materiels': activite.materiels,
      'objectifsApprentissage': activite.objectifsApprentissage,
      'statut': activite.statut.value,
      'imageUrl': activite.imageUrl,
      'points': activite.points,
      'dateCreation': Timestamp.fromDate(activite.dateCreation),
      'dateModification': Timestamp.fromDate(activite.dateModification),
      'ordreAffichage': activite.ordreAffichage,
    };
  }

  static List<Activite> fromFirestoreList(List<DocumentSnapshot> docs) {
    return docs.map((doc) => fromFirestore(doc)).toList();
  }
}