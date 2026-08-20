import 'package:cloud_firestore/cloud_firestore.dart';

class Tutoriel {
  final String tutorielId;
  final String categorieId;
  final String jouetLieId;
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

  Tutoriel({
    required this.tutorielId,
    required this.categorieId,
    required this.jouetLieId,
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
  });

  /// Firestore -> Model
  factory Tutoriel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return Tutoriel(
      tutorielId: doc.id,

      categorieId: data['categorieId'] as String? ?? '',

      // Peut être null
      jouetLieId: data['jouetLieId'] as String,

      createurId: data['createurId'] as String? ?? '',

      titre: data['titre'] as String? ?? '',

      description: data['description'] as String? ?? '',

      jouetsSuggeres: List<String>.from(
        data['jouetsSuggeres'] ?? [],
      ),

      videoUrl: data['videoUrl'] as String? ?? '',

      miniatureUrl: data['miniatureUrl'] as String? ?? '',

      duree: data['duree'] as num? ?? 0,

      ageMinimum: data['ageMinimum'] as num? ?? 0,

      ageMaximum: data['ageMaximum'] as num? ?? 0,

      estPublie: data['estPublie'] as bool? ?? false,

      dateCreation: data['dateCreation'] is Timestamp
          ? (data['dateCreation'] as Timestamp).toDate()
          : DateTime.now(),
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
    };
  }

  Tutoriel copyWith({
    String? tutorielId,
    String? categorieId,
    String? jouetLieId,
    String? createurId,
    String? titre,
    String? description,
    List<String>? jouetsSuggeres,
    String? videoUrl,
    String? miniatureUrl,
    num? duree,
    num? ageMinimum,
    num? ageMaximum,
    bool? estPublie,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Tutoriel(
      tutorielId: tutorielId ?? this.tutorielId,
      categorieId: categorieId ?? this.categorieId,
      jouetLieId: jouetLieId ?? this.jouetLieId,
      createurId: createurId ?? this.createurId,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      jouetsSuggeres: jouetsSuggeres ?? this.jouetsSuggeres,
      videoUrl: videoUrl ?? this.videoUrl,
      miniatureUrl: miniatureUrl ?? this.miniatureUrl,
      duree: duree ?? this.duree,
      ageMinimum: ageMinimum ?? this.ageMinimum,
      ageMaximum: ageMaximum ?? this.ageMaximum,
      estPublie: estPublie ?? this.estPublie,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }
}