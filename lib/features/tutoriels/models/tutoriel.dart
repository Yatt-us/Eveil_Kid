import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/tutoriel_status.enum.dart';

class Tutoriel {
  final String? tutorielId;
  final String categorieId;
  final String? jouetLieId;
  final String createurId;
  final String titre;
  final String description;
  final List<String> jouetsSuggeres;
  final String videoUrl;
  final String miniatureUrl;
  final int duree; 
  final int ageMinimum;
  final int ageMaximum;
  final TutorielStatus statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  const Tutoriel({
    required this.tutorielId,
    required this.categorieId,
    required this.jouetLieId,
    required this.createurId,
    required this.titre,
    required this.description,
    this.jouetsSuggeres = const [],
    required this.videoUrl,
    required this.miniatureUrl,
    required this.duree,
    required this.ageMinimum,
    required this.ageMaximum,
    this.statut = TutorielStatus.brouillon,
    required this.dateCreation,
    required this.dateModification,
  });

  factory Tutoriel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Tutoriel(
      tutorielId: doc.id,
      categorieId: data['categorieId'] ?? '',
      jouetLieId: data['jouetLieId'],
      createurId: data['createurId'] ?? '',
      titre: data['titre'] ?? '',
      description: data['description'] ?? '',
      jouetsSuggeres: List<String>.from(data['jouetsSuggeres'] ?? []),
      videoUrl: data['videoUrl'] ?? '',
      miniatureUrl: data['miniatureUrl'] ?? '',
      duree: data['duree'] ?? 0,
      ageMinimum: data['ageMinimum'] ?? 0,
      ageMaximum: data['ageMaximum'] ?? 0,
      statut: TutorielStatusExtension.fromString(data['statut'] ?? 'brouillon'),
      dateCreation: (data['dateCreation'] as Timestamp).toDate(),
      dateModification: (data['dateModification'] as Timestamp).toDate(),
    );
  }

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
      'statut': statut.value,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateModification': Timestamp.fromDate(dateModification),
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
    int? duree,
    int? ageMinimum,
    int? ageMaximum,
    TutorielStatus? statut,
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
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  String get dureeFormatee {
    final minutes = duree ~/ 60;
    final secondes = duree % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secondes.toString().padLeft(2, '0')}';
  }

  String get statutLabel => statut.label;

   String get ageRangeLabel =>
      ageMinimum == ageMaximum ? '$ageMinimum ans' : '$ageMinimum-$ageMaximum ans';

  String get durationLabel => '${duree.toString()} sec';
}