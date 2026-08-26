import 'package:eveilkid/features/questions/enums/question_type.enum.dart';
import 'package:eveilkid/features/questions/options_questions/option_model.dart';
import 'package:flutter/material.dart';

class Question {
  final String? id;
  final String activiteId;
  final String enonce;
  final QuestionType type;
  final List<OptionQuestion> options;
  final String idReponseCorrecte;
  final int points;
  final int ordre;
  final String? imageUrl;
  final bool estArchive;

  const Question({
    this.id,
    required this.activiteId,
    required this.enonce,
    required this.type,
    this.options = const [],
    required this.idReponseCorrecte,
    this.points = 10,
    this.ordre = 0,
    this.imageUrl,
    this.estArchive= false
  });

  Question copyWith({
    String? id,
    String? activiteId,
    String? enonce,
    QuestionType? type,
    List<OptionQuestion>? options,
    String? idReponseCorrecte,
    int? points,
    int? ordre,
    String? imageUrl,
    bool? estArchive,
  }) {
    return Question(
      id: id ?? this.id,
      activiteId: activiteId ?? this.activiteId,
      enonce: enonce ?? this.enonce,
      type: type ?? this.type,
      options: options ?? this.options,
      idReponseCorrecte: idReponseCorrecte ?? this.idReponseCorrecte,
      points: points ?? this.points,
      ordre: ordre ?? this.ordre,
      imageUrl: imageUrl ?? this.imageUrl,
      estArchive: estArchive ?? this.estArchive,
    );
  }

  String get typeLabel => type.label;
  String get typeDescription => type.description;
  IconData get typeIcon => type.icon;
}