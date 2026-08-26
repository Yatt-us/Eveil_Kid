enum PublicationStatus {
  brouillon,
  publie,
  archive,
}

extension PublicationStatusExtension on PublicationStatus {
  String get value => toString().split('.').last;
  
  String get label {
    switch (this) {
      case PublicationStatus.brouillon:
        return 'Brouillon';
      case PublicationStatus.publie:
        return 'Publié';
      case PublicationStatus.archive:
        return 'Archivé';
    }
  }

  static PublicationStatus fromString(String value) {
    switch (value) {
      case 'publie':
        return PublicationStatus.publie;
      case 'archive':
        return PublicationStatus.archive;
      default:
        return PublicationStatus.brouillon;
    }
  }
}