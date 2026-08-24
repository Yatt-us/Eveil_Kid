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

  static UserRole fromValue(String value) {
    switch (value.toUpperCase()) {
      case 'PARENT':
        return UserRole.parent;

      case 'MANAGER':
        return UserRole.manager;

      case 'ADMIN':
        return UserRole.admin;

      default:
        throw ArgumentError('Rôle utilisateur inconnu : $value');
    }
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
    this.estActif = true,
    this.dateCreation,
    this.dateModification,
    this.enfants = const [],
  });

  String get name => nom;

  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      utilisateurId: map['utilisateurId'] as String,
      role: UserRole.fromValue(map['role'] as String),
      nombreFavoris: map['nombreFavoris'] as int?,
      nombreEnfants: map['nombreEnfants'] as int?,
      email: map['email'] as String,
      nom: map['nom'] as String,
      photoUrl: map['photoUrl'] as String?,
      telephone: map['telephone'] as String?,
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
