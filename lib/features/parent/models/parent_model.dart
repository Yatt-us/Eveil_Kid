// lib/features/parent/models/parent_model.dart

class EnfantModel {
  final String id;
  final String name;
  final int age;
  final String level;
  final String? photoUrl;

  EnfantModel({
    required this.id,
    required this.name,
    required this.age,
    required this.level,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'level': level,
      'photoUrl': photoUrl,
    };
  }

  factory EnfantModel.fromMap(Map<String, dynamic> map, String id) {
    return EnfantModel(
      id: id,
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      level: map['level'] ?? '',
      photoUrl: map['photoUrl'],
    );
  }
}

class ParentModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final List<EnfantModel> enfants;

  ParentModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.enfants = const [],
  });

  ParentModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    List<EnfantModel>? enfants,
  }) {
    return ParentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      enfants: enfants ?? this.enfants,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'enfants': enfants.map((e) => e.toMap()).toList(),
    };
  }

  factory ParentModel.fromMap(Map<String, dynamic> map, String id) {
    return ParentModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      enfants: (map['enfants'] as List<dynamic>?)
          ?.map((e) => EnfantModel.fromMap(e as Map<String, dynamic>, e['id'] ?? ''))
          .toList() ??
          [],
    );
  }
}