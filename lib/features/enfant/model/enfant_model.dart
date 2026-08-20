import 'package:cloud_firestore/cloud_firestore.dart';

class EnfantModel {
  final String enfantId;
  final String utilisateurId;
  final String nom;
  final DateTime dateNaissance;
  final String? avatarUrl;
  final List<String> souhait;
  final List<dynamic> resultatsActivite;
  final String codeSecuriteHash;
  final bool estActif;
  final String genre;
  final DateTime dateCreation;
  final DateTime dateModification;

  EnfantModel({
    required this.enfantId,
    required this.utilisateurId,
    required this.nom,
    required this.dateNaissance,
    this.avatarUrl,
    required this.souhait,
    required this.resultatsActivite,
    required this.codeSecuriteHash,
    required this.estActif,
    required this.genre,
    required this.dateCreation,
    required this.dateModification,
  });

  // Transformer les données Firestore en EnfantModel.
  factory EnfantModel.fromMap(Map<String, dynamic> map) {
    return EnfantModel(
      enfantId: map['enfantId'] ?? '',
      utilisateurId: map['utilisateurId'] ?? '',
      nom: map['nom'] ?? '',
      dateNaissance: (map['dateNaissance'] as Timestamp).toDate(),
      avatarUrl: map['avatarUrl'],
      souhait: List<String>.from(map['souhait'] ?? []),
      resultatsActivite:
          List<dynamic>.from(map['resultatsActivite'] ?? []),
      codeSecuriteHash: map['codeSecuriteHash'] ?? '',
      estActif: map['estActif'] ?? true,
      genre: map['genre'] ?? '',
      dateCreation: (map['dateCreation'] as Timestamp).toDate(),
      dateModification:
          (map['dateModification'] as Timestamp).toDate(),
    );
  }

  // Transformer EnfantModel en données enregistrables dans Firestore.
  Map<String, dynamic> toMap() {
    return {
      'enfantId': enfantId,
      'utilisateurId': utilisateurId,
      'nom': nom,
      'dateNaissance': Timestamp.fromDate(dateNaissance),
      'avatarUrl': avatarUrl,
      'souhait': souhait,
      'resultatsActivite': resultatsActivite,
      'codeSecuriteHash': codeSecuriteHash,
      'estActif': estActif,
      'genre': genre,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateModification': Timestamp.fromDate(dateModification),
    };
  }

  // Créer une copie de l'enfant avec certaines valeurs modifiées.
  EnfantModel copyWith({
    String? enfantId,
    String? utilisateurId,
    String? nom,
    DateTime? dateNaissance,
    String? avatarUrl,
    List<String>? souhait,
    List<dynamic>? resultatsActivite,
    String? codeSecuriteHash,
    bool? estActif,
    String? genre,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return EnfantModel(
      enfantId: enfantId ?? this.enfantId,
      utilisateurId: utilisateurId ?? this.utilisateurId,
      nom: nom ?? this.nom,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      souhait: souhait ?? this.souhait,
      resultatsActivite:
          resultatsActivite ?? this.resultatsActivite,
      codeSecuriteHash:
          codeSecuriteHash ?? this.codeSecuriteHash,
      estActif: estActif ?? this.estActif,
      genre: genre ?? this.genre,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification:
          dateModification ?? this.dateModification,
    );
  }

  // Calcul automatique de l'âge de l'enfant.
  int get age {
    final maintenant = DateTime.now();

    int resultat =
        maintenant.year - dateNaissance.year;

    if (maintenant.month < dateNaissance.month ||
        (maintenant.month == dateNaissance.month &&
            maintenant.day < dateNaissance.day)) {
      resultat--;
    }

    return resultat;
  }
}