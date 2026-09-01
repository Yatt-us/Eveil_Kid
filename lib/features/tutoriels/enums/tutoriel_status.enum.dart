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
    final lower = value.trim().toLowerCase();
    switch (lower) {
      case 'publie':
      case 'publié':
      case 'published':
      case 'true':
        return TutorielStatus.publie;
      case 'archive':
      case 'archivé':
      case 'archived':
        return TutorielStatus.archive;
      case 'brouillon':
      case 'draft':
      case 'false':
      default:
        return TutorielStatus.brouillon;
    }
  }
}