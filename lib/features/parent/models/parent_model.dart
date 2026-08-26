// lib/features/parent/models/parent_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  PARENT,
  MANAGER,
  ADMIN,
}

enum ElementFavoriType {
  JOUET,
  TUTORIEL,
}

/// Modèle pour la collection 'utilisateurs'
class UtilisateurModel {
  final String utilisateurId; // PK Firebase Auth
  final UserRole role;
  final int nombreFavoris;
  final int nombreEnfants;
  final String email;
  final String nom;
  final String? photoUrl;
  final String? telephone;
  final bool estActif;
  final DateTime dateCreation;
  final DateTime dateModification;
  final List<EnfantModel> enfants;

  UtilisateurModel({
    required this.utilisateurId,
    this.role = UserRole.PARENT,
    this.nombreFavoris = 0,
    this.nombreEnfants = 0,
    required this.email,
    required this.nom,
    this.photoUrl,
    this.telephone,
    this.estActif = true,
    DateTime? dateCreation,
    DateTime? dateModification,
    this.enfants = const [],
  })  : dateCreation = dateCreation ?? DateTime.now(),
        dateModification = dateModification ?? DateTime.now();

  // Alias pour la compatibilité
  String get id => utilisateurId;
  String get name => nom;

  UtilisateurModel copyWith({
    String? utilisateurId,
    UserRole? role,
    int? nombreFavoris,
    int? nombreEnfants,
    String? email,
    String? nom,
    String? name,
    String? photoUrl,
    String? telephone,
    bool? estActif,
    DateTime? dateCreation,
    DateTime? dateModification,
    List<EnfantModel>? enfants,
  }) {
    return UtilisateurModel(
      utilisateurId: utilisateurId ?? this.utilisateurId,
      role: role ?? this.role,
      nombreFavoris: nombreFavoris ?? this.nombreFavoris,
      nombreEnfants: nombreEnfants ?? (enfants != null ? enfants.length : this.nombreEnfants),
      email: email ?? this.email,
      nom: nom ?? name ?? this.nom,
      photoUrl: photoUrl ?? this.photoUrl,
      telephone: telephone ?? this.telephone,
      estActif: estActif ?? this.estActif,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? DateTime.now(),
      enfants: enfants ?? this.enfants,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'utilisateurId': utilisateurId,
      'role': role.name,
      'nombreFavoris': nombreFavoris,
      'nombreEnfants': enfants.isNotEmpty ? enfants.length : nombreEnfants,
      'email': email,
      'nom': nom,
      'photoUrl': photoUrl,
      'telephone': telephone,
      'estActif': estActif,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateModification': Timestamp.fromDate(dateModification),
    };
  }

  factory UtilisateurModel.fromFirestore(Map<String, dynamic> map, String id, {List<EnfantModel> enfants = const []}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    UserRole parseRole(dynamic val) {
      if (val == 'ADMIN') return UserRole.ADMIN;
      if (val == 'MANAGER') return UserRole.MANAGER;
      return UserRole.PARENT;
    }

    return UtilisateurModel(
      utilisateurId: id,
      role: parseRole(map['role']),
      nombreFavoris: (map['nombreFavoris'] as num?)?.toInt() ?? 0,
      nombreEnfants: (map['nombreEnfants'] as num?)?.toInt() ?? enfants.length,
      email: map['email'] ?? '',
      nom: map['nom'] ?? '',
      photoUrl: map['photoUrl'],
      telephone: map['telephone'],
      estActif: map['estActif'] is bool ? map['estActif'] : true,
      dateCreation: parseDate(map['dateCreation']),
      dateModification: parseDate(map['dateModification']),
      enfants: enfants,
    );
  }
}

// Alias pour compatibilité
typedef ParentModel = UtilisateurModel;

/// Modèle pour la collection 'enfants'
class EnfantModel {
  final String enfantId; // PK
  final String utilisateurId; // FK
  final String nom;
  final DateTime dateNaissance;
  final String? avatarUrl;
  final List<String> souhait;
  final List<dynamic> resultatsActivite;
  final String? codeSecuriteHash;
  final String genre;
  final bool estActif;
  final DateTime dateCreation;
  final DateTime dateModification;

  EnfantModel({
    required this.enfantId,
    required this.utilisateurId,
    required this.nom,
    required this.dateNaissance,
    this.avatarUrl,
    this.souhait = const [],
    this.resultatsActivite = const [],
    this.codeSecuriteHash,
    this.genre = 'NON_SPECIFIE',
    this.estActif = true,
    DateTime? dateCreation,
    DateTime? dateModification,
  })  : dateCreation = dateCreation ?? DateTime.now(),
        dateModification = dateModification ?? DateTime.now();

  // Getters utiles pour l'UI
  String get id => enfantId;
  String get name => nom;

  int get age {
    final now = DateTime.now();
    int calculatedAge = now.year - dateNaissance.year;
    if (now.month < dateNaissance.month ||
        (now.month == dateNaissance.month && now.day < dateNaissance.day)) {
      calculatedAge--;
    }
    return calculatedAge >= 0 ? calculatedAge : 0;
  }

  String get level {
    if (age <= 3) return 'Niveau 1';
    if (age <= 4) return 'Niveau 2';
    if (age <= 5) return 'Niveau 3';
    if (age <= 6) return 'Niveau 4';
    return 'Niveau 5';
  }

  EnfantModel copyWith({
    String? enfantId,
    String? utilisateurId,
    String? nom,
    DateTime? dateNaissance,
    String? avatarUrl,
    List<String>? souhait,
    List<dynamic>? resultatsActivite,
    String? codeSecuriteHash,
    String? genre,
    bool? estActif,
    DateTime? dateCreation,
    DateTime? dateModification,
    // Alias pour compatibilité d'appel
    String? name,
    int? age,
    String? level,
  }) {
    DateTime resolvedDateNaissance = dateNaissance ?? this.dateNaissance;
    if (age != null) {
      resolvedDateNaissance = DateTime(DateTime.now().year - age, 1, 1);
    }

    return EnfantModel(
      enfantId: enfantId ?? this.enfantId,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      nom: nom ?? name ?? this.nom,
      dateNaissance: resolvedDateNaissance,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      souhait: souhait ?? this.souhait,
      resultatsActivite: resultatsActivite ?? this.resultatsActivite,
      codeSecuriteHash: codeSecuriteHash ?? this.codeSecuriteHash,
      genre: genre ?? this.genre,
      estActif: estActif ?? this.estActif,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'enfantId': enfantId,
      'utilisateurId': utilisateurId,
      'nom': nom,
      'dateNaissance': Timestamp.fromDate(dateNaissance),
      'avatarUrl': avatarUrl,
      'souhait': souhait,
      'resultatsActivite': resultatsActivite,
      'codeSecuriteHash': codeSecuriteHash,
      'genre': genre,
      'estActif': estActif,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateModification': Timestamp.fromDate(dateModification),
    };
  }

  factory EnfantModel.fromFirestore(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime(2020, 1, 1);
      return DateTime(2020, 1, 1);
    }

    return EnfantModel(
      enfantId: id,
      utilisateurId: map['utilisateurId'] ?? '',
      nom: map['nom'] ?? '',
      dateNaissance: parseDate(map['dateNaissance']),
      avatarUrl: map['avatarUrl'],
      souhait: (map['souhait'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      resultatsActivite: (map['resultatsActivite'] as List<dynamic>?) ?? [],
      codeSecuriteHash: map['codeSecuriteHash'],
      genre: map['genre'] ?? 'NON_SPECIFIE',
      estActif: map['estActif'] is bool ? map['estActif'] : true,
      dateCreation: parseDate(map['dateCreation']),
      dateModification: parseDate(map['dateModification']),
    );
  }

  // Compatibilité toMap / fromMap
  Map<String, dynamic> toMap() => toFirestore();
  factory EnfantModel.fromMap(Map<String, dynamic> map, String id) => EnfantModel.fromFirestore(map, id);
}

/// Modèle pour la collection 'commandes'
class CommandeModel {
  final String commandeId; // PK
  final String utilisateurId; // FK
  final String nomClient; // snapshot
  final String emailClient; // snapshot
  final List<Map<String, dynamic>> articles;
  final double montantTotal;
  final String statut;
  final String statutPaiement;
  final DateTime dateCreation;
  final DateTime dateModification;

  CommandeModel({
    required this.commandeId,
    required this.utilisateurId,
    required this.nomClient,
    required this.emailClient,
    required this.articles,
    required this.montantTotal,
    required this.statut,
    required this.statutPaiement,
    DateTime? dateCreation,
    DateTime? dateModification,
  })  : dateCreation = dateCreation ?? DateTime.now(),
        dateModification = dateModification ?? DateTime.now();

  Map<String, dynamic> toFirestore() {
    return {
      'commandeId': commandeId,
      'utilisateurId': utilisateurId,
      'nomClient': nomClient,
      'emailClient': emailClient,
      'articles': articles,
      'montantTotal': montantTotal,
      'statut': statut,
      'statutPaiement': statutPaiement,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateModification': Timestamp.fromDate(dateModification),
    };
  }

  factory CommandeModel.fromFirestore(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return CommandeModel(
      commandeId: id,
      utilisateurId: map['utilisateurId'] ?? '',
      nomClient: map['nomClient'] ?? '',
      emailClient: map['emailClient'] ?? '',
      articles: (map['articles'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [],
      montantTotal: (map['montantTotal'] as num?)?.toDouble() ?? 0.0,
      statut: map['statut'] ?? 'EN_ATTENTE',
      statutPaiement: map['statutPaiement'] ?? 'EN_ATTENTE',
      dateCreation: parseDate(map['dateCreation']),
      dateModification: parseDate(map['dateModification']),
    );
  }
}

/// Modèle pour la collection 'favoris'
class FavoriModel {
  final String favoriId; // PK
  final String utilisateurId; // FK
  final String elementId; // FK polymorphe
  final ElementFavoriType typeElement;
  final String titre; // denormalisé
  final String? miniatureUrl; // denormalisé
  final double? prix; // denormalisé
  final DateTime dateCreation;

  FavoriModel({
    required this.favoriId,
    required this.utilisateurId,
    required this.elementId,
    required this.typeElement,
    required this.titre,
    this.miniatureUrl,
    this.prix,
    DateTime? dateCreation,
  }) : dateCreation = dateCreation ?? DateTime.now();

  Map<String, dynamic> toFirestore() {
    return {
      'favoriId': favoriId,
      'utilisateurId': utilisateurId,
      'elementId': elementId,
      'typeElement': typeElement.name,
      'titre': titre,
      'miniatureUrl': miniatureUrl,
      'prix': prix,
      'dateCreation': Timestamp.fromDate(dateCreation),
    };
  }

  factory FavoriModel.fromFirestore(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return FavoriModel(
      favoriId: id,
      utilisateurId: map['utilisateurId'] ?? '',
      elementId: map['elementId'] ?? '',
      typeElement: map['typeElement'] == 'TUTORIEL' ? ElementFavoriType.TUTORIEL : ElementFavoriType.JOUET,
      titre: map['titre'] ?? '',
      miniatureUrl: map['miniatureUrl'],
      prix: (map['prix'] as num?)?.toDouble(),
      dateCreation: parseDate(map['dateCreation']),
    );
  }
}

/// Modèle pour la collection 'panier'
class ArticlePanierModel {
  final String articlePanierId; // PK
  final String utilisateurId; // FK
  final String jouetId; // FK
  final String nomJouet; // denormalisé
  final double prixUnitaire; // denormalisé
  final String? miniatureUrl; // denormalisé
  final int stockDispo;
  final DateTime dateCreation;
  final DateTime dateModification;

  ArticlePanierModel({
    required this.articlePanierId,
    required this.utilisateurId,
    required this.jouetId,
    required this.nomJouet,
    required this.prixUnitaire,
    this.miniatureUrl,
    this.stockDispo = 1,
    DateTime? dateCreation,
    DateTime? dateModification,
  })  : dateCreation = dateCreation ?? DateTime.now(),
        dateModification = dateModification ?? DateTime.now();

  Map<String, dynamic> toFirestore() {
    return {
      'articlePanierId': articlePanierId,
      'utilisateurId': utilisateurId,
      'jouetId': jouetId,
      'nomJouet': nomJouet,
      'prixUnitaire': prixUnitaire,
      'miniatureUrl': miniatureUrl,
      'stockDispo': stockDispo,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateModification': Timestamp.fromDate(dateModification),
    };
  }

  factory ArticlePanierModel.fromFirestore(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return ArticlePanierModel(
      articlePanierId: id,
      utilisateurId: map['utilisateurId'] ?? '',
      jouetId: map['jouetId'] ?? '',
      nomJouet: map['nomJouet'] ?? '',
      prixUnitaire: (map['prixUnitaire'] as num?)?.toDouble() ?? 0.0,
      miniatureUrl: map['miniatureUrl'],
      stockDispo: (map['stockDispo'] as num?)?.toInt() ?? 1,
      dateCreation: parseDate(map['dateCreation']),
      dateModification: parseDate(map['dateModification']),
    );
  }
}