import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';

/// État du mode Espace Enfant
class ChildModeState {
  final bool isChildModeActive;
  final String? activeChildId;
  final EnfantModel? activeChild;
  final bool isInitialized;

  const ChildModeState({
    this.isChildModeActive = false,
    this.activeChildId,
    this.activeChild,
    this.isInitialized = false,
  });

  ChildModeState copyWith({
    bool? isChildModeActive,
    String? activeChildId,
    EnfantModel? activeChild,
    bool? isInitialized,
    bool forceNullChild = false,
    bool forceNullChildId = false,
  }) {
    return ChildModeState(
      isChildModeActive: isChildModeActive ?? this.isChildModeActive,
      activeChildId:
          forceNullChildId ? null : (activeChildId ?? this.activeChildId),
      activeChild: forceNullChild ? null : (activeChild ?? this.activeChild),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Notifier gérant la persistance et l'état global du Mode Enfant
class ChildModeNotifier extends Notifier<ChildModeState> {
  static const String _keyChildModeActive = 'child_mode_is_active';
  static const String _keyActiveChildId = 'child_mode_active_child_id';

  @override
  ChildModeState build() {
    // Initialise le chargement depuis les SharedPreferences
    _loadPersistedState();
    return const ChildModeState();
  }

  Future<void> _loadPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isActive = prefs.getBool(_keyChildModeActive) ?? false;
      final savedChildId = prefs.getString(_keyActiveChildId);

      if (!state.isInitialized) {
        state = state.copyWith(
          isChildModeActive: isActive,
          activeChildId: savedChildId,
          isInitialized: true,
        );

        // Si un enfant était sélectionné, on essaie de le résoudre avec la liste
        if (savedChildId != null && savedChildId.isNotEmpty) {
          _syncActiveChildFromEnfantNotifier(savedChildId);
        }
      }
    } catch (_) {
      if (!state.isInitialized) {
        state = state.copyWith(isInitialized: true);
      }
    }
  }

  void _syncActiveChildFromEnfantNotifier(String childId) {
    try {
      final enfants = ref.read(enfantNotifierProvider).enfants;
      for (final enfant in enfants) {
        if (enfant.enfantId == childId) {
          state = state.copyWith(activeChild: enfant);
          break;
        }
      }
    } catch (_) {}
  }

  /// Active le mode enfant pour l'enfant donné et persiste l'état
  Future<void> enterChildMode({
    required String childId,
    EnfantModel? child,
  }) async {
    state = state.copyWith(
      isChildModeActive: true,
      activeChildId: childId,
      activeChild: child,
      isInitialized: true,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyChildModeActive, true);
      await prefs.setString(_keyActiveChildId, childId);
    } catch (_) {}

    // Met à jour également la sélection dans le notifier enfant
    if (child != null) {
      try {
        ref.read(enfantNotifierProvider.notifier).selectionnerEnfant(child);
      } catch (_) {}
    }
  }

  /// Quitte le mode enfant et nettoie la persistance
  Future<void> exitChildMode() async {
    state = state.copyWith(
      isChildModeActive: false,
      activeChildId: null,
      forceNullChild: true,
      forceNullChildId: true,
      isInitialized: true,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyChildModeActive, false);
      await prefs.remove(_keyActiveChildId);
    } catch (_) {}
  }

  /// Change l'enfant actif au sein de l'espace enfant
  Future<void> switchChild(EnfantModel child) async {
    state = state.copyWith(
      activeChildId: child.enfantId,
      activeChild: child,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyActiveChildId, child.enfantId);
    } catch (_) {}

    try {
      ref.read(enfantNotifierProvider.notifier).selectionnerEnfant(child);
    } catch (_) {}
  }

  /// Met à jour la liste de souhaits de l'enfant dans Firestore et l'état
  Future<void> toggleWishlist({
    required String parentId,
    required String enfantId,
    required String jouetId,
  }) async {
    final currentChild = state.activeChild;
    if (currentChild == null || currentChild.enfantId != enfantId) return;

    final currentWishes = List<String>.from(currentChild.souhait);
    if (currentWishes.contains(jouetId)) {
      currentWishes.remove(jouetId);
    } else {
      currentWishes.add(jouetId);
    }

    final updatedChild = currentChild.copyWith(
      souhait: currentWishes,
      dateModification: DateTime.now(),
    );

    state = state.copyWith(activeChild: updatedChild);
    try {
      await ref.read(enfantNotifierProvider.notifier).modifierEnfant(updatedChild);
    } catch (_) {}
  }
}

/// Provider global du mode enfant
final childModeProvider =
    NotifierProvider<ChildModeNotifier, ChildModeState>(ChildModeNotifier.new);
