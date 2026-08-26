import 'package:cloud_firestore/cloud_firestore.dart';

class Categorie {
  final String categorieId;
  final String nom;
  final int nombreJouetsDenormalise;
  final int nbTutoriels;
  final bool estActive;
  final Timestamp dateCreation;
  final Timestamp dateModification;
  final String? iconeUrl;
  final String? imageUrl;

  Categorie({
    required this.categorieId,
    required this.nom,
    required this.nombreJouetsDenormalise,
    required this.nbTutoriels,
    required this.estActive,
    required this.dateCreation,
    required this.dateModification,
    this.iconeUrl,
    this.imageUrl,
  });

  factory Categorie.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    final id = snapshot.id;

    return Categorie(
      categorieId: id,
      nom: data['nom'] ?? '',
      nombreJouetsDenormalise:
          data['nombreJouets'] ?? data['nombreJouetsDenormalise'] ?? 0,
      nbTutoriels: data['nbTutoriels'] ?? 0,
      estActive: data['estActive'] ?? data['estActif'] ?? true,
      dateCreation: data['dateCreation'] ?? Timestamp.now(),
      dateModification: data['dateModification'] ?? Timestamp.now(),
      iconeUrl: data['iconeUrl'],
      imageUrl: data['imageUrl'],
    );
  }

  Categorie copyWith({
    String? categorieId,
    String? nom,
    int? nombreJouetsDenormalise,
    int? nbTutoriels,
    bool? estActive,
    Timestamp? dateCreation,
    Timestamp? dateModification,
    String? iconeUrl,
    String? imageUrl,
  }) {
    return Categorie(
      categorieId: categorieId ?? this.categorieId,
      nom: nom ?? this.nom,
      nombreJouetsDenormalise:
          nombreJouetsDenormalise ?? this.nombreJouetsDenormalise,
      nbTutoriels: nbTutoriels ?? this.nbTutoriels,
      estActive: estActive ?? this.estActive,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      iconeUrl: iconeUrl ?? this.iconeUrl,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'categorieId': categorieId,
      'nom': nom,
      'nombreJouets': nombreJouetsDenormalise,
      'nombreJouetsDenormalise': nombreJouetsDenormalise,
      'nbTutoriels': nbTutoriels,
      'estActive': estActive,
      'estActif': estActive,
      'dateCreation': dateCreation,
      'dateModification': dateModification,
      'iconeUrl': iconeUrl,
      'imageUrl': imageUrl,
    };
  }
}