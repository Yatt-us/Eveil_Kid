import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/activites/enums/publication_status.enum.dart';

class Activite {
  final String? id;
  final String titre;
  final String description;
  final String categorieId; 
  final String difficulte; 
  final int ageMinimum;
  final int ageMaximum;
  final int dureeEnMinutes;
  final List<String> materiels;
  final List<String> objectifsApprentissage;
  final PublicationStatus statut;
  final String? imageUrl;
  final int points;
  final DateTime dateCreation;
  final DateTime dateModification;
  final int ordreAffichage;

  const Activite({
    this.id,
    required this.titre,
    required this.description,
    required this.categorieId,
    required this.difficulte,
    required this.ageMinimum,
    required this.ageMaximum,
    required this.dureeEnMinutes,
    this.materiels = const [],
    this.objectifsApprentissage = const [],
    this.statut = PublicationStatus.brouillon,
    this.imageUrl,
    required this.points,
    required this.dateCreation,
    required this.dateModification,
    this.ordreAffichage = 0,
  });

  factory Activite.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    
    PublicationStatus parseStatus(String? statusStr) {
      return PublicationStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => PublicationStatus.brouillon,
      );
    }

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
      statut: parseStatus(data['statut']),
      imageUrl: data['imageUrl'],
      points: data['points'] ?? 30,
      dateCreation: (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateModification: (data['dateModification'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ordreAffichage: data['ordreAffichage'] ?? 0,
    );
  }
}