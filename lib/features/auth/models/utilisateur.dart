import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';

enum UserRole {
  parent,
  manager,
  admin;

  String get value {
    switch (this) {
      case UserRole.parent:
        return 'PARENT';
      case UserRole.manager:
        return 'MANAGER';
      case UserRole.admin:
        return 'ADMIN';
    }
  }

  static UserRole fromValue(dynamic value) {
    if (value == null) return UserRole.parent;
    final str = value.toString().trim().toUpperCase();
    if (str == 'ADMIN' || str == 'USERROLE.ADMIN' || str.contains('ADMIN')) {
      return UserRole.admin;
    }
    if (str == 'MANAGER' || str == 'USERROLE.MANAGER' || str.contains('MANAGER')) {
      return UserRole.manager;
    }
    return UserRole.parent;
  }
}

class Utilisateur {
  final String utilisateurId;
  final UserRole role;
  final int? nombreFavoris;
  final int? nombreEnfants;
  final String email;
  final String nom;
  final String? photoUrl;
  final String? telephone;
  final String? adresse;
  final bool estActif;
  final DateTime? dateCreation;
  final DateTime? dateModification;
  final List<EnfantModel> enfants;

  const Utilisateur({
    required this.utilisateurId,
    this.role = UserRole.parent,
    this.nombreFavoris,
    this.nombreEnfants,
    this.email = '',
    this.nom = '',
    this.photoUrl,
    this.telephone,
    this.adresse,
    this.estActif = true,
    this.dateCreation,
    this.dateModification,
    this.enfants = const [],
  });

  String get name => nom;

  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      utilisateurId: (map['utilisateurId'] as String?) ?? '',
      role: UserRole.fromValue(map['role']),
      nombreFavoris: (map['nombreFavoris'] as num?)?.toInt(),
      nombreEnfants: (map['nombreEnfants'] as num?)?.toInt(),
      email: (map['email'] as String?) ?? '',
      nom: (map['nom'] as String?) ?? '',
      photoUrl: map['photoUrl'] as String?,
      telephone: map['telephone'] as String?,
      adresse: map['adresse'] as String?,
      estActif: map['estActif'] as bool? ?? true,
      dateCreation: _timestampToDateTime(map['dateCreation']),
      dateModification: _timestampToDateTime(map['dateModification']),
    );
  }

  factory Utilisateur.fromFirestore(
    Map<String, dynamic> data,
    String id, {
    List<EnfantModel> enfants = const [],
  }) {
    return Utilisateur.fromMap({
      ...data,
      'utilisateurId': data['utilisateurId'] ?? id,
    }).copyWith(enfants: enfants);
  }

  String get uid => utilisateurId;

  Map<String, dynamic> toMap() {
    return {
      'utilisateurId': utilisateurId,
      'role': role.value,
      'nombreFavoris': nombreFavoris,
      'nombreEnfants': nombreEnfants,
      'email': email,
      'nom': nom,
      'photoUrl': photoUrl,
      'telephone': telephone,
      'adresse': adresse,
      'estActif': estActif,
      'dateCreation': dateCreation,
      'dateModification': dateModification,
    };
  }

  Map<String, dynamic> toFirestore() => toMap();

  Utilisateur copyWith({
    String? utilisateurId,
    UserRole? role,
    int? nombreFavoris,
    int? nombreEnfants,
    String? email,
    String? nom,
    String? photoUrl,
    String? telephone,
    String? adresse,
    bool? estActif,
    DateTime? dateCreation,
    DateTime? dateModification,
    List<EnfantModel>? enfants,
  }) {
    return Utilisateur(
      utilisateurId: utilisateurId ?? this.utilisateurId,
      role: role ?? this.role,
      nombreFavoris: nombreFavoris ?? this.nombreFavoris,
      nombreEnfants: nombreEnfants ?? this.nombreEnfants,
      email: email ?? this.email,
      nom: nom ?? this.nom,
      photoUrl: photoUrl ?? this.photoUrl,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      estActif: estActif ?? this.estActif,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      enfants: enfants ?? this.enfants,
    );
  }

  static DateTime? _timestampToDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
