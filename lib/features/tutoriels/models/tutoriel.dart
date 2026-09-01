import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/tutoriel_status.enum.dart';
import '../utils/duration_utils.dart';

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
  final int duree; // Durée de la vidéo en secondes stockée dans Firestore
  final int ageMinimum;
  final int ageMaximum;
  final TutorielStatus statut;
  final DateTime dateCreation;
  final DateTime dateModification;

  const Tutoriel({
    this.tutorielId,
    required this.categorieId,
    this.jouetLieId,
    required this.createurId,
    required this.titre,
    required this.description,
    this.jouetsSuggeres = const [],
    required this.videoUrl,
    required this.miniatureUrl,
    this.duree = 0,
    required this.ageMinimum,
    required this.ageMaximum,
    this.statut = TutorielStatus.brouillon,
    required this.dateCreation,
    required this.dateModification,
  });

  /// Retourne la durée formatée en chaîne lisible (ex: "03:45" ou "01:12:30")
  String get dureeFormatted => formatDurationSeconds(duree.toDouble());

  factory Tutoriel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};

    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    TutorielStatus parseStatut(dynamic statutVal, dynamic estPublieVal) {
      if (statutVal != null && statutVal.toString().trim().isNotEmpty) {
        return TutorielStatusExtension.fromString(statutVal.toString());
      }
      if (estPublieVal == true) {
        return TutorielStatus.publie;
      }
      return TutorielStatus.publie;
    }

    return Tutoriel(
      tutorielId: doc.id,
      categorieId: data['categorieId']?.toString() ?? '',
      jouetLieId: data['jouetLieId']?.toString(),
      createurId: data['createurId']?.toString() ?? '',
      titre: data['titre']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      jouetsSuggeres: List<String>.from(data['jouetsSuggeres'] ?? []),
      videoUrl: data['videoUrl']?.toString() ?? '',
      miniatureUrl: data['miniatureUrl']?.toString() ?? '',
      duree: (data['duree'] is num)
          ? (data['duree'] as num).toInt()
          : int.tryParse(data['duree']?.toString() ?? '0') ?? 0,
      ageMinimum: (data['ageMinimum'] is num)
          ? (data['ageMinimum'] as num).toInt()
          : int.tryParse(data['ageMinimum']?.toString() ?? '0') ?? 0,
      ageMaximum: (data['ageMaximum'] is num)
          ? (data['ageMaximum'] as num).toInt()
          : int.tryParse(data['ageMaximum']?.toString() ?? '0') ?? 0,
      statut: parseStatut(data['statut'], data['estPublie']),
      dateCreation: parseDate(data['dateCreation']),
      dateModification: parseDate(data['dateModification']),
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
      'estPublie': statut == TutorielStatus.publie,
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

  bool get estPublie => statut == TutorielStatus.publie;
  bool get estBrouillon => statut == TutorielStatus.brouillon;

  String get statutLabel => statut.label;

  String get ageRangeLabel {
    if (ageMinimum == ageMaximum) return '$ageMinimum ans';
    return '$ageMinimum - $ageMaximum ans';
  }

  bool isTargetedForAge(int age) => age >= ageMinimum && age <= ageMaximum;
}