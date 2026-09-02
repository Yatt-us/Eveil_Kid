import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/duolingo_button.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/duolingo_card.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/kid_filter_chip.dart';
import 'package:eveilkid/features/enfant/providers/child_mode_provider.dart';
import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';

class ListeJouetsPage extends ConsumerStatefulWidget {
  const ListeJouetsPage({super.key});

  @override
  ConsumerState<ListeJouetsPage> createState() => _ListeJouetsPageState();
}

class _ListeJouetsPageState extends ConsumerState<ListeJouetsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final childMode = ref.watch(childModeProvider);
    final enfant = childMode.activeChild ??
        ref.watch(
          enfantNotifierProvider.select((state) => state.enfantSelectionne),
        );

    final jouetsAsync = ref.watch(jouetsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    final filteredJouets = _filterJouets(
      jouets: jouetsAsync.value ?? const [],
      childAge: enfant?.age ?? 0,
      keyword: _searchQuery,
      categoryId: _selectedCategoryId,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── APP BAR LUDIQUE ──
              Row(
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
                      'Jouets',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE7F3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFBCFE8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          size: 16,
                          color: Color(0xFFDB2777),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${enfant?.souhait.where((s) => !s.contains(' ') && s.isNotEmpty).length ?? 0}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF9D174D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── CHAMP DE RECHERCHE LUDIQUE ──
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.dividerColor.withValues(
                      alpha: isDark ? 0.25 : 0.15,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.03,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un jouet ou jeu...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: KidTheme.primaryGreenDark,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── PUCES DE CATÉGORIES ──
              SizedBox(
                height: 48,
                child: categoriesAsync.when(
                  data: (categories) {
                    final chips = <Widget>[
                      KidFilterChip(
                        label: 'Tous les jouets',
                        icon: Icons.all_inclusive_rounded,
                        isSelected: _selectedCategoryId == null,
                        onTap: () => setState(() => _selectedCategoryId = null),
                      ),
                      ...categories.map(
                        (cat) => KidFilterChip(
                          label: cat.nom,
                          icon: Icons.category_outlined,
                          isSelected: _selectedCategoryId == cat.categorieId,
                          onTap: () {
                            setState(() {
                              _selectedCategoryId =
                                  _selectedCategoryId == cat.categorieId
                                      ? null
                                      : cat.categorieId;
                            });
                          },
                        ),
                      ),
                    ];

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                      scrollDirection: Axis.horizontal,
                      itemCount: chips.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) => chips[index],
                    );
                  },
                  loading: () => const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),

              const SizedBox(height: 14),

              // ── LISTE DES JOUETS ──
              Expanded(
                child: jouetsAsync.when(
                  data: (jouets) {
                    if (filteredJouets.isEmpty) {
                      return _buildEmptyState(theme, isDark);
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: filteredJouets.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final jouet = filteredJouets[index];
                        final isWished =
                            enfant?.souhait.contains(jouet.jouetId) ?? false;

                        return _KidToyCard(
                          jouet: jouet,
                          isWished: isWished,
                          onToggleWishlist: () => _toggleWish(jouet),
                          onTap: () => _showKidToyDetailSheet(jouet, isWished),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: KidTheme.primaryGreen,
                    ),
                  ),
                  error: (error, _) => Center(
                    child: Text(
                      'Erreur : $error',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleWish(Jouet jouet) {
    final parentId = FirebaseAuth.instance.currentUser?.uid;
    final childMode = ref.read(childModeProvider);
    final activeChild = childMode.activeChild ??
        ref.read(enfantNotifierProvider).enfantSelectionne;

    if (parentId == null || activeChild == null) return;

    ref.read(childModeProvider.notifier).toggleWishlist(
          parentId: parentId,
          enfantId: activeChild.enfantId,
          jouetId: jouet.jouetId,
        );

    final isNowWished = !activeChild.souhait.contains(jouet.jouetId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowWished
              ? '"${jouet.nom}" ajouté à ta liste de souhaits !'
              : '"${jouet.nom}" retiré de ta liste de souhaits.',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor:
            isNowWished ? const Color(0xFFDB2777) : Colors.grey.shade800,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showKidToyDetailSheet(Jouet jouet, bool isWished) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 18),
                // Grande image du jouet
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: const Color(0xFFFEF3C7),
                    child: jouet.imagePrincipaleUrl.isNotEmpty
                        ? Image.network(
                            jouet.imagePrincipaleUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.smart_toy_rounded,
                              size: 60,
                              color: Color(0xFFD97706),
                            ),
                          )
                        : const Icon(
                            Icons.smart_toy_rounded,
                            size: 60,
                            color: Color(0xFFD97706),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  jouet.nom,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${jouet.ageMinimum} - ${jouet.ageMaximum > 0 ? jouet.ageMaximum : '+'} ans',
                        style: const TextStyle(
                          color: KidTheme.primaryGreenDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            jouet.noteMoyenneDenormalise > 0
                                ? jouet.noteMoyenneDenormalise
                                    .toStringAsFixed(1)
                                : '4.8',
                            style: const TextStyle(
                              color: Color(0xFF92400E),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  jouet.description.isNotEmpty
                      ? jouet.description
                      : 'Un jouet formidable conçu pour s’amuser, apprendre et créer de beaux souvenirs !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                // Bouton souhait enfant style Duolingo 3D
                DuolingoButton(
                  text: isWished
                      ? 'Dans mes souhaits (Retirer)'
                      : 'Ajouter à mes souhaits',
                  icon: isWished
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  colorType: isWished
                      ? DuolingoButtonColor.neutral
                      : DuolingoButtonColor.pink,
                  isFullWidth: true,
                  onPressed: () {
                    Navigator.pop(ctx);
                    _toggleWish(jouet);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Jouet> _filterJouets({
    required List<Jouet> jouets,
    required int childAge,
    required String keyword,
    required String? categoryId,
  }) {
    final normalizedQuery = keyword.trim().toLowerCase();

    return jouets.where((jouet) {
      final matchesCategory =
          categoryId == null || jouet.categorieId == categoryId;

      final matchesKeyword = normalizedQuery.isEmpty ||
          jouet.nom.toLowerCase().contains(normalizedQuery) ||
          jouet.description.toLowerCase().contains(normalizedQuery);

      // L'enfant peut voir les jouets inférieurs ou égaux à son âge, mais JAMAIS supérieurs
      final matchesAge = childAge <= 0 || jouet.ageMinimum <= childAge;

      return jouet.estActif && matchesCategory && matchesKeyword && matchesAge;
    }).toList();
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Color(0xFFD97706),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun jouet trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Essaie de chercher un autre mot ou une autre catégorie.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}


class _KidToyCard extends StatelessWidget {
  final Jouet jouet;
  final bool isWished;
  final VoidCallback onToggleWishlist;
  final VoidCallback onTap;

  const _KidToyCard({
    required this.jouet,
    required this.isWished,
    required this.onToggleWishlist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = jouet.imagePrincipaleUrl.trim();
    final ageLabel = '${jouet.ageMinimum} - ${jouet.ageMaximum > 0 ? jouet.ageMaximum : '+'} ans';

    return DuolingoCard(
      onTap: onTap,
      borderRadius: 24,
      bottomThickness: 4.0,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Image 3D
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 86,
              height: 86,
              color: const Color(0xFFFEF3C7),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _fallbackImage(),
                    )
                  : _fallbackImage(),
            ),
          ),

          const SizedBox(width: 14),

          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 5),
                Row(
                  children: [
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
                    const SizedBox(width: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFD97706),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          jouet.noteMoyenneDenormalise > 0
                              ? jouet.noteMoyenneDenormalise
                                  .toStringAsFixed(1)
                              : '4.8',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  jouet.description.isNotEmpty
                      ? jouet.description
                      : 'Un super jouet pour apprendre en s’amusant !',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Bouton coeur / souhait 3D style Duolingo
          _DuolingoHeartButton(
            isWished: isWished,
            onTap: onToggleWishlist,
          ),
        ],
      ),
    );
  }

  Widget _fallbackImage() {
    return const Center(
      child: Icon(
        Icons.smart_toy_rounded,
        size: 40,
        color: Color(0xFFD97706),
      ),
    );
  }
}

/// Bouton coeur favori 3D tactile style Duolingo
class _DuolingoHeartButton extends StatefulWidget {
  final bool isWished;
  final VoidCallback onTap;

  const _DuolingoHeartButton({
    required this.isWished,
    required this.onTap,
  });

  @override
  State<_DuolingoHeartButton> createState() => _DuolingoHeartButtonState();
}

class _DuolingoHeartButtonState extends State<_DuolingoHeartButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = widget.isWished
        ? const Color(0xFFFCE7F3)
        : (isDark ? const Color(0xFF222228) : const Color(0xFFF8FAFC));
    final border = widget.isWished
        ? const Color(0xFFF472B6)
        : (isDark ? const Color(0xFF383842) : const Color(0xFFE2E8F0));
    final bottomBorder = widget.isWished
        ? const Color(0xFFDB2777)
        : (isDark ? const Color(0xFF18181C) : const Color(0xFFCBD5E1));

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
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: border,
            width: 1.5,
          ),
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: bottomBorder.withValues(alpha: isDark ? 0.35 : 0.25),
                blurRadius: 0,
                offset: Offset(0, activeBottomEdge),
              ),
          ],
        ),
        child: Center(
          child: Icon(
            widget.isWished
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: widget.isWished
                ? const Color(0xFFDB2777)
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            size: 22,
          ),
        ),
      ),
    );
  }
}
