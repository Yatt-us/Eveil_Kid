class OptionModel {
  final String id;
  final String texte;
  final String? imagePath;

  const OptionModel({
    required this.id,
    required this.texte,
    this.imagePath,
  });

  factory OptionModel.fromMap(Map<String, dynamic> map) {
    return OptionModel(
      id: map['id'] ?? '',
      texte: map['texte'] ?? '',
      imagePath: map['imagePath'],
    );
  }
}

class QuestionModel {
  final String id;
  final String enonce;
  final String idReponseCorrecte;
  final List<OptionModel> options;

  const QuestionModel({
    required this.id,
    required this.enonce,
    required this.idReponseCorrecte,
    required this.options,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    final rawOptions = map['options'] as List<dynamic>? ?? [];

    return QuestionModel(
      id: map['id'] ?? '',
      enonce: map['enonce'] ?? '',
      idReponseCorrecte: map['idReponseCorrecte'] ?? '',
      options: rawOptions
          .map((opt) => OptionModel.fromMap(opt as Map<String, dynamic>))
          .toList(),
    );
  }
}