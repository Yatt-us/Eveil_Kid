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

  // Construction d'une instance depuis un DocumentSnapshot Firestore
  factory Activite.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data() ?? {};

    return Activite(
      id: snapshot.id,
      titre: data['titre'] ?? '',
      description: data['description'] ?? '',
      categorieId: data['categorieId'] ?? '',
      difficulte: data['difficulte'] ?? 'facile',
      ageMinimum: (data['ageMinimum'] as num?)?.toInt() ?? 3,
      ageMaximum: (data['ageMaximum'] as num?)?.toInt() ?? 6,
      dureeEnMinutes: (data['dureeEnMinutes'] as num?)?.toInt() ?? 5,
      materiels: List<String>.from(data['materiels'] ?? []),
      objectifsApprentissage: List<String>.from(data['objectifsApprentissage'] ?? []),
      statut: PublicationStatus.values.firstWhere(
        (e) => e.name == data['statut'],
        orElse: () => PublicationStatus.brouillon,
      ),
      imageUrl: data['imageUrl'],
      points: (data['points'] as num?)?.toInt() ?? 0,
      dateCreation: (data['dateCreation'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateModification: (data['dateModification'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ordreAffichage: (data['ordreAffichage'] as num?)?.toInt() ?? 0,
    );
  }

  // Conversion de l'objet en Map pour l'enregistrement Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'titre': titre,
      'description': description,
      'categorieId': categorieId,
      'difficulte': difficulte,
      'ageMinimum': ageMinimum,
      'ageMaximum': ageMaximum,
      'dureeEnMinutes': dureeEnMinutes,
      'materiels': materiels,
      'objectifsApprentissage': objectifsApprentissage,
      'statut': statut.name,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'points': points,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateModification': Timestamp.fromDate(dateModification),
      'ordreAffichage': ordreAffichage,
    };
  }

  static Activite empty() {
    return Activite(
      titre: '',
      description: '',
      categorieId: '',
      difficulte: 'facile',
      ageMinimum: 3,
      ageMaximum: 6,
      dureeEnMinutes: 5,
      points: 30,
      dateCreation: DateTime.now(),
      dateModification: DateTime.now(),
    );
  }

  Activite copyWith({
    String? id,
    String? titre,
    String? description,
    String? categorieId,
    String? difficulte,
    int? ageMinimum,
    int? ageMaximum,
    int? dureeEnMinutes,
    List<String>? materiels,
    List<String>? objectifsApprentissage,
    PublicationStatus? statut,
    String? imageUrl,
    int? points,
    DateTime? dateCreation,
    DateTime? dateModification,
    int? ordreAffichage,
  }) {
    return Activite(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      categorieId: categorieId ?? this.categorieId,
      difficulte: difficulte ?? this.difficulte,
      ageMinimum: ageMinimum ?? this.ageMinimum,
      ageMaximum: ageMaximum ?? this.ageMaximum,
      dureeEnMinutes: dureeEnMinutes ?? this.dureeEnMinutes,
      materiels: materiels ?? this.materiels,
      objectifsApprentissage: objectifsApprentissage ?? this.objectifsApprentissage,
      statut: statut ?? this.statut,
      imageUrl: imageUrl ?? this.imageUrl,
      points: points ?? this.points,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      ordreAffichage: ordreAffichage ?? this.ordreAffichage,
    );
  }
}