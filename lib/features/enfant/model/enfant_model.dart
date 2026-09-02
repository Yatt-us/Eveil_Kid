import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle représentant un enfant lié dynamiquement à un parent (utilisateur).
class EnfantModel {
  final String enfantId;
  final String utilisateurId; // ID Dynamique du Parent
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

  /// Constructeur pour initialiser un nouvel enfant avec des ID dynamiques
  /// générés à la volée avant l'insertion dans Firestore.
  factory EnfantModel.creerNouveau({
    required String utilisateurId,
    required String nom,
    required DateTime dateNaissance,
    required String genre,
    String? avatarUrl,
    String? uniqueEnfantId, // Optionnel : si vous générez l'ID via Firebase avant
  }) {
    // Génère un ID Firestore local si aucun n'est fourni
    final idGenere = uniqueEnfantId ?? FirebaseFirestore.instance.collection('temporaire').doc().id;
    
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

  /// Factory pour créer un [EnfantModel] à partir d'un Snapshot Firestore.
  /// Récupère l'ID du document si `enfantId` est absent du Map.
  factory EnfantModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final map = snapshot.data() ?? {};
    
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return EnfantModel(
      enfantId: map['enfantId']?.toString() ?? snapshot.id, // Dynamique selon le document
      utilisateurId: map['utilisateurId']?.toString() ?? '',
      nom: map['nom']?.toString() ?? '',
      dateNaissance: parseDate(map['dateNaissance']),
      avatarUrl: map['avatarUrl']?.toString(),
      souhait: map['souhait'] != null
          ? List<String>.from(map['souhait'].map((e) => e.toString()))
              .where((s) => !s.contains(' ') && s.isNotEmpty)
              .toList()
          : [],
      resultatsActivite: map['resultatsActivite'] != null
          ? List<dynamic>.from(map['resultatsActivite'])
          : [],
      codeSecuriteHash: map['codeSecuriteHash']?.toString() ?? '',
      estActif: map['estActif'] is bool
          ? map['estActif']
          : (map['estActif']?.toString().toLowerCase() == 'true'),
      genre: map['genre']?.toString() ?? '',
      dateCreation: parseDate(map['dateCreation']),
      dateModification: parseDate(map['dateModification']),
    );
  }

  /// Convertit l'instance [EnfantModel] en Map pour l'enregistrement Firestore.
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

  /// Crée une copie de l'objet en injectant de nouvelles valeurs dynamiques.
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

  /// Calcul dynamique de l'âge de l'enfant en années.
  int get age {
    final maintenant = DateTime.now();
    int resultat = maintenant.year - dateNaissance.year;

    if (maintenant.month < dateNaissance.month ||
        (maintenant.month == dateNaissance.month &&
            maintenant.day < dateNaissance.day)) {
      resultat--;
    }

    return resultat < 0 ? 0 : resultat;
  }

  /// Calcul dynamique du total de points / étoiles gagnés par l'enfant.
  int get totalPoints {
    int total = 0;
    for (final item in resultatsActivite) {
      if (item is Map) {
        final pts = item['pointsGagnes'] ?? item['score'];
        if (pts is num) {
          total += pts.toInt();
        }
      }
    }
    return total;
  }

  /// Étoiles gagnées (équivalent aux points cumulés).
  int get etoiles => totalPoints;

  /// Nombre total d'activités terminées.
  int get totalActivitesTerminees {
    int count = 0;
    for (final item in resultatsActivite) {
      if (item is Map) {
        final isDone = item['termine'] == true ||
            item['estTerminee'] == true ||
            item['estReussi'] == true ||
            (item['score'] != null && (item['score'] as num) > 0);
        if (isDone) count++;
      }
    }
    return count;
  }

  /// Niveau dynamique de l'enfant (50 points par niveau).
  int get niveau => (1 + (totalPoints ~/ 50)).clamp(1, 100);

  /// Progression vers le prochain niveau (entre 0.05 et 1.0).
  double get progressionNiveau =>
      ((totalPoints % 50) / 50.0).clamp(0.05, 1.0);

  /// Points nécessaires pour atteindre le niveau suivant.
  int get pointsPourProchainNiveau => 50 - (totalPoints % 50);
}
