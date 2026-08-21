import 'package:cloud_firestore/cloud_firestore.dart';

class Jouet {
  final String jouetId;
  final String categorieId;
  final String createurId;

  final String nom;
  final String description;
  final String nomCategorieDenormalise;

  final List<String> images;
  final String imagePrincipaleUrl;

  final int ageMinimum;
  final int ageMaximum;

  final double prix;
  final String devise;

  final int stock;
  final int stockDisponible;

  final double noteMoyenneDenormalise;
  final int nombreAvisDenormalise;
  final int nbTutorielsAssocies;

  final bool estActif;
  final bool estPopulaire;

  final Timestamp dateCreation;
  final Timestamp dateModification;

  Jouet({
    required this.jouetId,
    required this.categorieId,
    required this.createurId,
    required this.nom,
    required this.description,
    required this.nomCategorieDenormalise,
    required this.images,
    required this.imagePrincipaleUrl,
    required this.ageMinimum,
    required this.ageMaximum,
    required this.prix,
    required this.devise,
    required this.stock,
    required this.stockDisponible,
    required this.noteMoyenneDenormalise,
    required this.nombreAvisDenormalise,
    required this.nbTutorielsAssocies,
    required this.estActif,
    this.estPopulaire = false,
    required this.dateCreation,
    required this.dateModification,
  });

  Jouet copyWith({
    String? jouetId,
    String? categorieId,
    String? createurId,
    String? nom,
    String? description,
    String? nomCategorieDenormalise,
    List<String>? images,
    String? imagePrincipaleUrl,
    int? ageMinimum,
    int? ageMaximum,
    double? prix,
    String? devise,
    int? stock,
    int? stockDisponible,
    double? noteMoyenneDenormalise,
    int? nombreAvisDenormalise,
    int? nbTutorielsAssocies,
    bool? estActif,
    bool? estPopulaire,
    Timestamp? dateCreation,
    Timestamp? dateModification,
  }) {
    return Jouet(
      jouetId: jouetId ?? this.jouetId,
      categorieId: categorieId ?? this.categorieId,
      createurId: createurId ?? this.createurId,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      nomCategorieDenormalise:
          nomCategorieDenormalise ?? this.nomCategorieDenormalise,
      images: images ?? this.images,
      imagePrincipaleUrl: imagePrincipaleUrl ?? this.imagePrincipaleUrl,
      ageMinimum: ageMinimum ?? this.ageMinimum,
      ageMaximum: ageMaximum ?? this.ageMaximum,
      prix: prix ?? this.prix,
      devise: devise ?? this.devise,
      stock: stock ?? this.stock,
      stockDisponible: stockDisponible ?? this.stockDisponible,
      noteMoyenneDenormalise:
          noteMoyenneDenormalise ?? this.noteMoyenneDenormalise,
      nombreAvisDenormalise:
          nombreAvisDenormalise ?? this.nombreAvisDenormalise,
      nbTutorielsAssocies:
          nbTutorielsAssocies ?? this.nbTutorielsAssocies,
      estActif: estActif ?? this.estActif,
      estPopulaire: estPopulaire ?? this.estPopulaire,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  factory Jouet.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;

    return Jouet(
      jouetId: data['jouetId'] ?? snapshot.id,
      categorieId: data['categorieId'] ?? '',
      createurId: data['createurId'] ?? '',

      nom: data['nom'] ?? '',
      description: data['description'] ?? '',
      nomCategorieDenormalise:
          data['nomCategorieDenormalise'] ?? '',

      images: List<String>.from(data['images'] ?? []),
      imagePrincipaleUrl:
          data['imagePrincipaleUrl'] ?? '',

      ageMinimum: data['ageMinimum'] ?? 0,
      ageMaximum: data['ageMaximum'] ?? 0,

      prix: (data['prix'] ?? 0).toDouble(),
      devise: data['devise'] ?? 'FCFA',

      stock: data['stock'] ?? 0,
      stockDisponible: data['stockDisponible'] ?? 0,

      noteMoyenneDenormalise:
          (data['noteMoyenneDenormalise'] ?? 0).toDouble(),

      nombreAvisDenormalise:
          data['nombreAvisDenormalise'] ?? 0,

      nbTutorielsAssocies:
          data['nbTutorielsAssocies'] ?? 0,

      estActif: data['estActif'] ?? true,
      estPopulaire: data['estPopulaire'] ?? false,

      dateCreation:
          data['dateCreation'] ?? Timestamp.now(),

      dateModification:
          data['dateModification'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'jouetId': jouetId,
      'categorieId': categorieId,
      'createurId': createurId,

      'nom': nom,
      'description': description,
      'nomCategorieDenormalise': nomCategorieDenormalise,

      'images': images,
      'imagePrincipaleUrl': imagePrincipaleUrl,

      'ageMinimum': ageMinimum,
      'ageMaximum': ageMaximum,

      'prix': prix,
      'devise': devise,

      'stock': stock,
      'stockDisponible': stockDisponible,

      'noteMoyenneDenormalise':
          noteMoyenneDenormalise,

      'nombreAvisDenormalise':
          nombreAvisDenormalise,

      'nbTutorielsAssocies':
          nbTutorielsAssocies,

      'estActif': estActif,
      'estPopulaire': estPopulaire,

      'dateCreation': dateCreation,
      'dateModification': dateModification,
    };
  }

}