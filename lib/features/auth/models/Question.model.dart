import 'package:cloud_firestore/cloud_firestore.dart';


enum TypeQuestion {
  choix_multiple,   
  vrai_faux,       
}

class Question {
  final String? id;
  final String activiteId;  
  final String texte;       
  final TypeQuestion type;  
  final List<String> options; // Les options proposées
  final int indexBonneReponse; // L'index de la bonne réponse
  final int points;         
  final int ordre;          
  final String? explication;
  final DateTime dateCreation;
  final DateTime dateModification;

  Question({
    this.id,
    required this.activiteId,
    required this.texte,
    required this.type,
    this.options = const [],
    required this.indexBonneReponse,
    required this.points,
    required this.ordre,
    this.explication,
    required this.dateCreation,
    required this.dateModification,
  });

  // Créer une question depuis Firestore
  factory Question.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Question(
      id: doc.id,
      activiteId: data['activiteId'] ?? '',
      texte: data['texte'] ?? '',
      type: _getTypeFromString(data['type']),
      options: List<String>.from(data['options'] ?? []),
      indexBonneReponse: data['indexBonneReponse'] ?? 0,
      points: data['points'] ?? 0,
      ordre: data['ordre'] ?? 0,
      explication: data['explication'],
      dateCreation: (data['dateCreation'] as Timestamp).toDate(),
      dateModification: (data['dateModification'] as Timestamp).toDate(),
    );
  }

  // Convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'activiteId': activiteId,
      'texte': texte,
      'type': type.toString().split('.').last,
      'options': options,
      'indexBonneReponse': indexBonneReponse,
      'points': points,
      'ordre': ordre,
      'explication': explication,
      'dateCreation': Timestamp.fromDate(dateCreation),
      'dateModification': Timestamp.fromDate(dateModification),
    };
  }

  static TypeQuestion _getTypeFromString(String value) {
    switch (value) {
      case 'choix_multiple':
        return TypeQuestion.choix_multiple;
      case 'vrai_faux':
        return TypeQuestion.vrai_faux;
      default:
        return TypeQuestion.choix_multiple;
    }
  }

  Question copyWith({
    String? id,
    String? activiteId,
    String? texte,
    TypeQuestion? type,
    List<String>? options,
    int? indexBonneReponse,
    int? points,
    int? ordre,
    String? explication,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Question(
      id: id ?? this.id,
      activiteId: activiteId ?? this.activiteId,
      texte: texte ?? this.texte,
      type: type ?? this.type,
      options: options ?? this.options,
      indexBonneReponse: indexBonneReponse ?? this.indexBonneReponse,
      points: points ?? this.points,
      ordre: ordre ?? this.ordre,
      explication: explication ?? this.explication,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }
}