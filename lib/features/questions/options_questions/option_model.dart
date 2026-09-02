class OptionQuestion {
  final String id;
  final String texte;
  final String? imageUrl;

  const OptionQuestion({
    required this.id,
    required this.texte,
    this.imageUrl,
  });

  factory OptionQuestion.fromMap(dynamic data, {int index = 0}) {
    if (data is String) {
      return OptionQuestion(
        id: 'opt_${index + 1}',
        texte: data,
      );
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final id = map['id']?.toString() ??
          map['optionId']?.toString() ??
          map['code']?.toString() ??
          'opt_${index + 1}';
      final texte = map['texte']?.toString() ??
          map['libelle']?.toString() ??
          map['text']?.toString() ??
          map['valeur']?.toString() ??
          map['titre']?.toString() ??
          map['label']?.toString() ??
          '';
      final imageUrl = map['imageUrl']?.toString() ??
          map['image']?.toString() ??
          map['photoUrl']?.toString();

      return OptionQuestion(
        id: id.isNotEmpty ? id : 'opt_${index + 1}',
        texte: texte,
        imageUrl: imageUrl,
      );
    }
    return OptionQuestion(
      id: 'opt_${index + 1}',
      texte: data?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'texte': texte,
      'libelle': texte,
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