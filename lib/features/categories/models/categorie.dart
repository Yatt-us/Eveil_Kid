import 'package:cloud_firestore/cloud_firestore.dart';

class Categorie {
  final String categorieId;

  /// null = catégorie racine
  /// non-null = sous-catégorie
  final String? parentId;

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
    this.parentId,
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
    final data = snapshot.data()!;

    return Categorie(
      categorieId:
          data['categorieId'] ?? snapshot.id,

      parentId:
          data['parentId'],

      nom:
          data['nom'] ?? '',

      nombreJouetsDenormalise:
          data['nombreJouetsDenormalise'] ?? 0,

      nbTutoriels:
          data['nbTutoriels'] ?? 0,

      estActive:
          data['estActive'] ?? true,

      dateCreation:
          data['dateCreation'] ?? Timestamp.now(),

      dateModification:
          data['dateModification'] ?? Timestamp.now(),

      iconeUrl:
          data['iconeUrl'],

      imageUrl:
          data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'categorieId': categorieId,
      'parentId': parentId,
      'nom': nom,
      'nombreJouetsDenormalise':
          nombreJouetsDenormalise,
      'nbTutoriels':
          nbTutoriels,
      'estActive':
          estActive,
      'dateCreation':
          dateCreation,
      'dateModification':
          dateModification,
      'iconeUrl':
          iconeUrl,
      'imageUrl':
          imageUrl,
    };
  }
}