enum TutorielStatus {
  brouillon,
  publie,
  archive,
}

extension TutorielStatusExtension on TutorielStatus {
  String get value => toString().split('.').last;
  
  String get label {
    switch (this) {
      case TutorielStatus.brouillon:
        return 'Brouillon';
      case TutorielStatus.publie:
        return 'Publié';
      case TutorielStatus.archive:
        return 'Archivé';
    }
  }

  static TutorielStatus fromString(String value) {
    switch (value) {
      case 'publie':
        return TutorielStatus.publie;
      case 'archive':
        return TutorielStatus.archive;
      default:
        return TutorielStatus.brouillon;
    }
  }
}