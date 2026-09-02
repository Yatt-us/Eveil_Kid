import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';
import 'package:eveilkid/features/enfant/presentation/pages/liste_jouets.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/duolingo_button.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/duolingo_card.dart';
import 'package:eveilkid/features/enfant/providers/child_mode_provider.dart';
import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';

class ListeSouhaitsEnfantPage extends ConsumerWidget {
  const ListeSouhaitsEnfantPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final childMode = ref.watch(childModeProvider);
    final enfant = childMode.activeChild ??
        ref.watch(
          enfantNotifierProvider.select((state) => state.enfantSelectionne),
        );

    final jouetsAsync = ref.watch(jouetsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── APP BAR LUDIQUE ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  Material(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    elevation: isDark ? 0 : 1,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: theme.dividerColor.withValues(
                              alpha: isDark ? 0.3 : 0.15,
                            ),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: KidTheme.primaryGreenDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Souhaits',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final cleanWishCount = enfant?.souhait
                              .where((s) => !s.contains(' ') && s.isNotEmpty)
                              .length ??
                          0;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCE7F3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFBCFE8)),
                        ),
                        child: Text(
                          '$cleanWishCount souhait${cleanWishCount > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF9D174D),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: jouetsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: KidTheme.primaryGreen),
                ),
                error: (err, _) => Center(
                  child: Text(
                    'Erreur : $err',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
                data: (allJouets) {
                  final wishIds = (enfant?.souhait ?? [])
                      .where((s) => !s.contains(' ') && s.isNotEmpty)
                      .toSet();
                  final wishedToys = allJouets
                      .where((j) => wishIds.contains(j.jouetId))
                      .toList();

                  if (wishedToys.isEmpty) {
                    return _buildEmptyState(context, theme, isDark);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    itemCount: wishedToys.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final jouet = wishedToys[index];
                      return _buildWishCard(
                        context,
                        ref,
                        jouet,
                        enfant?.enfantId ?? '',
                        theme,
                        isDark,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishCard(
    BuildContext context,
    WidgetRef ref,
    Jouet jouet,
    String childId,
    ThemeData theme,
    bool isDark,
  ) {
    final ageLabel =
        '${jouet.ageMinimum} - ${jouet.ageMaximum > 0 ? jouet.ageMaximum : '+'} ans';

    return DuolingoCard(
      borderRadius: 24,
      bottomThickness: 4.0,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 86,
              height: 86,
              color: const Color(0xFFFEF3C7),
              child: jouet.imagePrincipaleUrl.isNotEmpty
                  ? Image.network(
                      jouet.imagePrincipaleUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.smart_toy_rounded,
                        size: 36,
                        color: Color(0xFFD97706),
                      ),
                    )
                  : const Icon(
                      Icons.smart_toy_rounded,
                      size: 36,
                      color: Color(0xFFD97706),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge Souhait de l'enfant
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE7F3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        size: 12,
                        color: Color(0xFFDB2777),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Choisi par l’enfant',
                        style: TextStyle(
                          color: Color(0xFFBE185D),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  jouet.nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ageLabel,
                    style: const TextStyle(
                      color: KidTheme.primaryGreenDark,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  jouet.description.isNotEmpty
                      ? jouet.description
                      : 'Un joli trésor pour jouer et rêver !',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _DuolingoWishRemoveButton(
            onTap: () {
              final parentId = FirebaseAuth.instance.currentUser?.uid;
              if (parentId != null) {
                ref.read(childModeProvider.notifier).toggleWishlist(
                      parentId: parentId,
                      enfantId: childId,
                      jouetId: jouet.jouetId,
                    );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Color(0xFFFCE7F3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                size: 52,
                color: Color(0xFFDB2777),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Aucun souhait pour le moment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore les jouets et clique sur le petit cœur pour les ajouter à ta liste de souhaits !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 24),
            DuolingoButton(
              text: 'Découvrir les jouets',
              icon: Icons.smart_toy_rounded,
              colorType: DuolingoButtonColor.pink,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const KidThemeScope(child: ListeJouetsPage()),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton 3D de retrait des souhaits style Duolingo
class _DuolingoWishRemoveButton extends StatefulWidget {
  final VoidCallback onTap;

  const _DuolingoWishRemoveButton({required this.onTap});

  @override
  State<_DuolingoWishRemoveButton> createState() => _DuolingoWishRemoveButtonState();
}

class _DuolingoWishRemoveButtonState extends State<_DuolingoWishRemoveButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double bottomThickness = 3.0;
    final double verticalShift = _isPressed ? 2.0 : 0.0;
    final double activeBottomEdge = _isPressed ? 1.0 : bottomThickness;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutQuad,
        margin: EdgeInsets.only(
          top: verticalShift,
          bottom: bottomThickness - verticalShift,
        ),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFFCE7F3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF472B6), width: 1.5),
          boxShadow: [
            if (!_isPressed)
              const BoxShadow(
                color: Color(0xFFDB2777),
                blurRadius: 0,
                offset: Offset(0, 3.0),
              ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.favorite_rounded,
            color: Color(0xFFDB2777),
            size: 22,
          ),
        ),
      ),
    );
  }
}
