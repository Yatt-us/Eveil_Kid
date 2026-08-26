import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/suggestion.dart';
import '../repository/suggestion_repository.dart';

/// Repository Provider
final suggestionRepositoryProvider =
    Provider<SuggestionRepository>((ref) {
  return SuggestionRepository();
});


/// Récupérer toutes les suggestions
/// d'un tutoriel
final suggestionsProvider =
    FutureProvider.family<List<Suggestion>, String>(
  (ref, tutorielId) async {
    final repository =
        ref.read(suggestionRepositoryProvider);

    return repository.getSuggestions(tutorielId);
  },
);