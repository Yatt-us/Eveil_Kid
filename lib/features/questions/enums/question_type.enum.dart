import 'package:flutter/material.dart';

enum QuestionType {
  choixMultiple,
  vraiFaux,
  association,
  classement,
}

extension QuestionTypeExtension on QuestionType {
  String get value => toString().split('.').last;
  
  String get label {
    switch (this) {
      case QuestionType.choixMultiple:
        return 'Choix multiple';
      case QuestionType.vraiFaux:
        return 'Vrai/Faux';
      case QuestionType.association:
        return 'Association';
      case QuestionType.classement:
        return 'Classement';
    }
  }

  String get description {
    switch (this) {
      case QuestionType.choixMultiple:
        return 'Une seule bonne réponse';
      case QuestionType.vraiFaux:
        return 'Réponse vrai ou faux';
      case QuestionType.association:
        return 'Associer des éléments';
      case QuestionType.classement:
        return 'Remettre dans le bon ordre';
    }
  }

  IconData get icon {
    switch (this) {
      case QuestionType.choixMultiple:
        return Icons.radio_button_checked;
      case QuestionType.vraiFaux:
        return Icons.check_circle_outline;
      case QuestionType.association:
        return Icons.link;
      case QuestionType.classement:
        return Icons.sort;
    }
  }

  static QuestionType fromString(String value) {
    switch (value) {
      case 'vraiFaux':
        return QuestionType.vraiFaux;
      case 'association':
        return QuestionType.association;
      case 'classement':
        return QuestionType.classement;
      default:
        return QuestionType.choixMultiple;
    }
  }
}