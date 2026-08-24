enum DifficultyLevel {
  facile,
  moyen,
  difficile,
}

extension DifficultyLevelExtension on DifficultyLevel {
  String get value => toString().split('.').last;
  
  String get label {
    switch (this) {
      case DifficultyLevel.facile:
        return 'Facile';
      case DifficultyLevel.moyen:
        return 'Moyen';
      case DifficultyLevel.difficile:
        return 'Difficile';
    }
  }

  static DifficultyLevel fromString(String value) {
    switch (value) {
      case 'facile':
        return DifficultyLevel.facile;
      case 'moyen':
        return DifficultyLevel.moyen;
      case 'difficile':
        return DifficultyLevel.difficile;
      default:
        return DifficultyLevel.facile;
    }
  }
}