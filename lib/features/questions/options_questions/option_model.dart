class OptionQuestion {
  final String id;
  final String texte;
  final String? imageUrl;

  const OptionQuestion({
    required this.id,
    required this.texte,
    this.imageUrl,
  });

  factory OptionQuestion.fromMap(Map<String, dynamic> map) {
    return OptionQuestion(
      id: map['id'] ?? '',
      texte: map['texte'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'texte': texte,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  OptionQuestion copyWith({
    String? id,
    String? texte,
    String? imageUrl,
  }) {
    return OptionQuestion(
      id: id ?? this.id,
      texte: texte ?? this.texte,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}