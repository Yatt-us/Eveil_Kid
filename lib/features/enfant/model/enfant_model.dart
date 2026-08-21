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

  factory EnfantModel.creerNouveau({
    required String utilisateurId,
    required String nom,
    required DateTime dateNaissance,
    required String genre,
    String? avatarUrl,
    String? uniqueEnfantId,
  }) {
    final idGenere =
        uniqueEnfantId ??
        FirebaseFirestore.instance.collection('utilisateurs').doc().id;

    return EnfantModel(
      enfantId: idGenere,
      utilisateurId: utilisateurId,
      nom: nom,
      dateNaissance: dateNaissance,
      avatarUrl: avatarUrl,
      souhait: [],
      resultatsActivite: [],
      codeSecuriteHash: '',
      estActif: true,
      genre: genre,
      dateCreation: DateTime.now(),
      dateModification: DateTime.now(),
    );
  }

  factory EnfantModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final map = snapshot.data() ?? {};

    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return EnfantModel(
      enfantId: map['enfantId']?.toString() ?? snapshot.id,
      utilisateurId: map['utilisateurId']?.toString() ?? '',
      nom: map['nom']?.toString() ?? '',
      dateNaissance: parseDate(map['dateNaissance']),
      avatarUrl: map['avatarUrl']?.toString(),
      souhait: map['souhait'] != null
          ? List<String>.from((map['souhait'] as List).map((e) => e.toString()))
          : [],
      resultatsActivite: map['resultatsActivite'] != null
          ? List<dynamic>.from(map['resultatsActivite'] as List)
          : [],
      codeSecuriteHash: map['codeSecuriteHash']?.toString() ?? '',
      estActif: map['estActif'] is bool
          ? map['estActif'] as bool
          : map['estActif']?.toString().toLowerCase() == 'true',
      genre: map['genre']?.toString() ?? '',
      dateCreation: parseDate(map['dateCreation']),
      dateModification: parseDate(map['dateModification']),
    );
  }

  Map<String, dynamic> toMap() => {
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
      resultatsActivite: resultatsActivite ?? this.resultatsActivite,
      codeSecuriteHash: codeSecuriteHash ?? this.codeSecuriteHash,
      estActif: estActif ?? this.estActif,
      genre: genre ?? this.genre,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  int get age {
    final now = DateTime.now();
    var result = now.year - dateNaissance.year;
    if (now.month < dateNaissance.month ||
        (now.month == dateNaissance.month && now.day < dateNaissance.day)) {
      result--;
    }
    return result < 0 ? 0 : result;
  }
}
