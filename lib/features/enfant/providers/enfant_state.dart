import 'package:flutter/foundation.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';

@immutable
class EnfantState {
  final List<EnfantModel> enfants;
  final EnfantModel? enfantSelectionne;
  final bool isLoading;
  final String? errorMessage;

  const EnfantState({
    this.enfants = const [],
    this.enfantSelectionne,
    this.isLoading = false,
    this.errorMessage,
  });

  EnfantState copyWith({
    List<EnfantModel>? enfants,
    EnfantModel? enfantSelectionne,
    bool? isLoading,
    String? errorMessage,
    bool forceNullSelection = false,
    bool forceNullError = false,
  }) {
    return EnfantState(
      enfants: enfants ?? this.enfants,
      enfantSelectionne: forceNullSelection
          ? null
          : (enfantSelectionne ?? this.enfantSelectionne),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: forceNullError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
