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
  final DateTime dateModification;

  const Tutoriel({
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
    required this.dateModification,
  });

  factory Tutoriel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};

    return Tutoriel(
      tutorielId: data['tutorielId']?.toString() ?? doc.id,
      categorieId: data['categorieId']?.toString() ?? '',
      jouetLieId: data['jouetLieId']?.toString() ?? '',
      createurId: data['createurId']?.toString() ?? '',
      titre: data['titre']?.toString() ?? 'Tutoriel',
      description: data['description']?.toString() ?? '',
      jouetsSuggeres: data['jouetsSuggeres'] is List
          ? List<String>.from((data['jouetsSuggeres'] as List).map((e) => e.toString()))
          : const [],
      videoUrl: data['videoUrl']?.toString() ?? '',
      miniatureUrl: data['miniatureUrl']?.toString() ?? '',
      duree: data['duree'] ?? 0,
      ageMinimum: data['ageMinimum'] ?? 0,
      ageMaximum: data['ageMaximum'] ?? 0,
      estPublie: data['estPublie'] is bool ? data['estPublie'] : true,
      dateCreation: _parseDate(data['dateCreation']),
      dateModification: _parseDate(data['dateModification']),
    );
  }

  factory Tutoriel.fromMap(Map<String, dynamic> map, {String? id}) {
    return Tutoriel(
      tutorielId: id ?? map['tutorielId']?.toString() ?? '',
      categorieId: map['categorieId']?.toString() ?? '',
      jouetLieId: map['jouetLieId']?.toString() ?? '',
      createurId: map['createurId']?.toString() ?? '',
      titre: map['titre']?.toString() ?? 'Tutoriel',
      description: map['description']?.toString() ?? '',
      jouetsSuggeres: map['jouetsSuggeres'] is List
          ? List<String>.from((map['jouetsSuggeres'] as List).map((e) => e.toString()))
          : const [],
      videoUrl: map['videoUrl']?.toString() ?? '',
      miniatureUrl: map['miniatureUrl']?.toString() ?? '',
      duree: map['duree'] ?? 0,
      ageMinimum: map['ageMinimum'] ?? 0,
      ageMaximum: map['ageMaximum'] ?? 0,
      estPublie: map['estPublie'] is bool ? map['estPublie'] : true,
      dateCreation: _parseDate(map['dateCreation']),
      dateModification: _parseDate(map['dateModification']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is DateTime) return value;
    return DateTime.now();
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
      dateModification: dateModification ?? this.dateModification,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tutorielId': tutorielId,
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

  String get ageRangeLabel =>
      ageMinimum == ageMaximum ? '$ageMinimum ans' : '$ageMinimum-$ageMaximum ans';

  String get durationLabel => '${duree.toString()} sec';
}