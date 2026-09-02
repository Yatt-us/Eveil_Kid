import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';
import 'package:eveilkid/features/questions/options_questions/option_model.dart';
import 'duolingo_option_tile.dart';

class DuolingoOrderedAssociationWidget extends StatelessWidget {
  final List<OptionQuestion> allOptions;
  final List<String> currentOrderedIds;
  final List<String> correctOrderedIds;
  final bool isAnswered;
  final Function(List<String>) onOrderChanged;

  const DuolingoOrderedAssociationWidget({
    super.key,
    required this.allOptions,
    required this.currentOrderedIds,
    required this.correctOrderedIds,
    required this.isAnswered,
    required this.onOrderChanged,
  });

  void _addItem(String id) {
    if (isAnswered) return;
    if (currentOrderedIds.contains(id)) return;
    HapticFeedback.selectionClick();
    final updated = List<String>.from(currentOrderedIds)..add(id);
    onOrderChanged(updated);
  }

  void _removeItem(String id) {
    if (isAnswered) return;
    HapticFeedback.lightImpact();
    final updated = List<String>.from(currentOrderedIds)..remove(id);
    onOrderChanged(updated);
  }

  void _resetAll() {
    if (isAnswered) return;
    HapticFeedback.mediumImpact();
    onOrderChanged([]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final optionsMap = {for (var o in allOptions) o.id: o};
    final isComplete = currentOrderedIds.length == allOptions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. EN-TÊTE RÉCEPTACLES D'ORDRE ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: KidTheme.playfulSky.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.format_list_numbered_rounded,
                    size: 18,
                    color: KidTheme.playfulSky,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Ordre des étapes :',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            if (currentOrderedIds.isNotEmpty && !isAnswered)
              TextButton.icon(
                onPressed: _resetAll,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  foregroundColor: theme.colorScheme.error,
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text(
                  'Effacer',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),

        const SizedBox(height: 10),

        // ── 2. ZONE DE RÉCEPTACLES ORDONNÉS (CIBLES 1, 2, 3...) ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? theme.dividerColor.withValues(alpha: 0.25)
                  : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
          ),
          child: Column(
            children: List.generate(allOptions.length, (slotIndex) {
              final isFilled = slotIndex < currentOrderedIds.length;
              final filledId = isFilled ? currentOrderedIds[slotIndex] : null;
              final option = filledId != null ? optionsMap[filledId] : null;

              if (isFilled && option != null) {
                DuolingoTileState tileState = DuolingoTileState.selected;
                if (isAnswered) {
                  final isSlotCorrect = slotIndex < correctOrderedIds.length &&
                      filledId == correctOrderedIds[slotIndex];
                  tileState = isSlotCorrect
                      ? DuolingoTileState.correct
                      : DuolingoTileState.incorrect;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DuolingoOptionTile(
                    text: option.texte,
                    badgeText: '${slotIndex + 1}',
                    imageUrl: option.imageUrl,
                    state: tileState,
                    isCompact: true,
                    onTap: isAnswered ? null : () => _removeItem(option.id),
                  ),
                );
              }

              // Emplacement vide avec silhouette pointillée
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${slotIndex + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Étape ${slotIndex + 1}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 20),

        // ── 3. BANQUE DES ÉLÉMENTS DISPONIBLES (STYLE WORD BANK DUOLINGO) ──
        Text(
          'Touche pour ajouter dans l\'ordre :',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 10),

        ...allOptions.map((opt) {
          final isPlaced = currentOrderedIds.contains(opt.id);

          if (isPlaced) {
            // Silhouette fantôme pour préserver la disposition
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 52,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.02)
                    : const Color(0xFFF1F5F9).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155).withValues(alpha: 0.5)
                      : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DuolingoOptionTile(
              text: opt.texte,
              imageUrl: opt.imageUrl,
              state: DuolingoTileState.neutral,
              onTap: isAnswered || isComplete ? null : () => _addItem(opt.id),
            ),
          );
        }),
      ],
    );
  }
}
