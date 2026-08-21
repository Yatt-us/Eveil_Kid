import '../enums/activite_enums.dart';

/// Modèle d'une option de réponse pour une question de quiz.
class OptionQuestion {
  final String id;
  final String texte;
  final String? imagePath;
  final String? audioPath;

  const OptionQuestion({
    required this.id,
    required this.texte,
    this.imagePath,
    this.audioPath,
  });

  /// Getter facilitant pour les interfaces
  String get cheminImage => imagePath ?? '';

  factory OptionQuestion.fromMap(Map<String, dynamic> map, {int index = 0}) {
    return OptionQuestion(
      id: map['id']?.toString() ?? 'opt_$index',
      texte: map['texte']?.toString() ?? map['label']?.toString() ?? '',
      imagePath: map['imagePath']?.toString() ?? map['cheminImage']?.toString(),
      audioPath: map['audioPath']?.toString() ?? map['cheminAudio']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'texte': texte,
      if (imagePath != null) 'imagePath': imagePath,
      if (audioPath != null) 'audioPath': audioPath,
    };
  }

  OptionQuestion copyWith({
    String? id,
    String? texte,
    String? imagePath,
    String? audioPath,
  }) {
    return OptionQuestion(
      id: id ?? this.id,
      texte: texte ?? this.texte,
      imagePath: imagePath ?? this.imagePath,
      audioPath: audioPath ?? this.audioPath,
    );
  }
}

/// Modèle représentant une question d'activité/quiz.
class Question {
  final String id;
  final String enonce;
  final String idReponseCorrecte;
  final List<OptionQuestion> options;
  final TypeAffichageQuestion typeAffichage;
  final TypeQuestion type;
  final String? audioPath;
  final String? explication;
  final int points;
  final int ordre;

  const Question({
    required this.id,
    required this.enonce,
    required this.idReponseCorrecte,
    required this.options,
    this.typeAffichage = TypeAffichageQuestion.liste,
    this.type = TypeQuestion.choixMultiple,
    this.audioPath,
    this.explication,
    this.points = 10,
    this.ordre = 0,
  });

  /// Alias de compatibilité pour l'interface
  String get texteQuestion => enonce;
  String? get cheminAudio => audioPath;

  factory Question.fromMap(Map<String, dynamic> map, {int index = 0}) {
    final rawOptions = map['options'] as List<dynamic>? ?? [];
    final parsedOptions = <OptionQuestion>[];

    for (int i = 0; i < rawOptions.length; i++) {
      final opt = rawOptions[i];
      if (opt is Map<String, dynamic>) {
        parsedOptions.add(OptionQuestion.fromMap(opt, index: i));
      } else if (opt is String) {
        parsedOptions.add(OptionQuestion(id: 'opt_$i', texte: opt));
      }
    }

    String correctId = map['idReponseCorrecte']?.toString() ?? '';
    if (correctId.isEmpty && map.containsKey('indexBonneReponse')) {
      final idx = (map['indexBonneReponse'] as num?)?.toInt() ?? 0;
      if (idx >= 0 && idx < parsedOptions.length) {
        correctId = parsedOptions[idx].id;
      }
    }

    // Auto-détection du mode d'affichage : grille si des images sont présentes et 4 options
    TypeAffichageQuestion affichage = TypeAffichageQuestion.fromString(map['typeAffichage']?.toString());
    if (!map.containsKey('typeAffichage') && parsedOptions.isNotEmpty) {
      final hasImages = parsedOptions.any((opt) => opt.imagePath?.isNotEmpty == true);
      if (hasImages && parsedOptions.length <= 4) {
        affichage = TypeAffichageQuestion.grille;
      }
    }

    return Question(
      id: map['id']?.toString() ?? 'q_$index',
      enonce: map['enonce']?.toString() ?? map['texte']?.toString() ?? map['texteQuestion']?.toString() ?? '',
      idReponseCorrecte: correctId,
      options: parsedOptions,
      typeAffichage: affichage,
      type: TypeQuestion.fromString(map['type']?.toString()),
      audioPath: map['audioPath']?.toString() ?? map['cheminAudio']?.toString(),
      explication: map['explication']?.toString(),
      points: (map['points'] as num?)?.toInt() ?? 10,
      ordre: (map['ordre'] as num?)?.toInt() ?? index,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'enonce': enonce,
      'idReponseCorrecte': idReponseCorrecte,
      'options': options.map((opt) => opt.toMap()).toList(),
      'typeAffichage': typeAffichage.name,
      'type': type.name,
      if (audioPath != null) 'audioPath': audioPath,
      if (explication != null) 'explication': explication,
      'points': points,
      'ordre': ordre,
    };
  }

  Question copyWith({
    String? id,
    String? enonce,
    String? idReponseCorrecte,
    List<OptionQuestion>? options,
    TypeAffichageQuestion? typeAffichage,
    TypeQuestion? type,
    String? audioPath,
    String? explication,
    int? points,
    int? ordre,
  }) {
    return Question(
      id: id ?? this.id,
      enonce: enonce ?? this.enonce,
      idReponseCorrecte: idReponseCorrecte ?? this.idReponseCorrecte,
      options: options ?? this.options,
      typeAffichage: typeAffichage ?? this.typeAffichage,
      type: type ?? this.type,
      audioPath: audioPath ?? this.audioPath,
      explication: explication ?? this.explication,
      points: points ?? this.points,
      ordre: ordre ?? this.ordre,
    );
  }
}
