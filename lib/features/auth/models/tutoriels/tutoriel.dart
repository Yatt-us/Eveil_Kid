import 'package:cloud_firestore/cloud_firestore.dart';

class Tutoriel {
  final String tutorielId;
  final String categorieId;
  final String? jouetLieId;
  final String createurId;
  final String titre;
  final String description;
  final List<String> jouetsSuggeres;
  final String videoUrl;
  final String miniatureUrl;
  final num duree;
  final num ageMinimum;
  final num ageMaximum;
  final bool estPublie;
  final DateTime dateCreation;
  final DateTime dateModification;
  

  Tutoriel({
    required this.tutorielId,
    required this.categorieId,
    this.jouetLieId,
    required this.createurId,
    required this.titre,
    required this.description,
    required this.jouetsSuggeres,
    required this.videoUrl,
    required this.miniatureUrl,
    required this.duree,
    required this.ageMinimum,
    required this.ageMaximum,
    required this.estPublie,
    required this.dateCreation,
    required this.dateModification,
  });

  /// Firestore -> Model
  factory Tutoriel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return Tutoriel(
      tutorielId: doc.id,
      categorieId: data['categorieId'] as String,
      jouetLieId: data['jouetLieId'] as String?,
      createurId: data['createurId'] as String,
      titre: data['titre'] as String,
      description: data['description'] as String,
      jouetsSuggeres: List<String>.from(
        data['jouetsSuggeres'] ?? [],
      ),
      videoUrl: data['videoUrl'] as String,
      miniatureUrl: data['miniatureUrl'] as String,
      duree: data['duree'] as num,
      ageMinimum: data['ageMinimum'] as num,
      ageMaximum: data['ageMaximum'] as num,
      estPublie: data['estPublie'] as bool,
      dateCreation: (data['dateCreation'] as Timestamp).toDate(),
      dateModification: (data['dateModification'] as Timestamp).toDate(),
    );
  }

  /// Model -> Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'categorieId': categorieId,
      'jouetLieId': jouetLieId,
      'createurId': createurId,
      'titre': titre,
      'description': description,
      'jouetsSuggeres': jouetsSuggeres,
      'videoUrl': videoUrl,
      'miniatureUrl': miniatureUrl,
      'duree': duree,
      'ageMinimum': ageMinimum,
      'ageMaximum': ageMaximum,
      'estPublie': estPublie,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateModification': Timestamp.fromDate(dateModification),
    };
  }
}