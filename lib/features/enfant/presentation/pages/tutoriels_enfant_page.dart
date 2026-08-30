import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';
import 'package:eveilkid/features/enfant/presentation/pages/tutoriel_detail_enfant_page.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/kid_filter_chip.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/presentation/widgets/tutoriel_card_skeleton.dart';
import 'package:eveilkid/features/tutoriels/providers/tutoriel_provider.dart';

class TutorielsEnfantPage extends ConsumerStatefulWidget {
  const TutorielsEnfantPage({super.key});

  @override
  ConsumerState<TutorielsEnfantPage> createState() =>
      _TutorielsEnfantPageState();
}

class _TutorielsEnfantPageState extends ConsumerState<TutorielsEnfantPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedAgeFilter; // null = tous, 2 = 0-2 ans, 5 = 3-5 ans, 8 = 6+ ans

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tutorielsAsync = ref.watch(tutorielsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── APP BAR LUDIQUE ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tutoriels Vidéo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Découvre, construis et apprends !',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: const Icon(
                      Icons.movie_creation_rounded,
                      size: 22,
                      color: Color(0xFFEA580C),
                    ),
                  ),
                ],
              ),
            ),

            // ── RECHERCHE LUDIQUE ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Container(
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
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un tutoriel rigolo...',
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
            ),

            // ── FILTRES D'ÂGE ──
            SizedBox(
              height: 48,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                scrollDirection: Axis.horizontal,
                children: [
                  KidFilterChip(
                    label: 'Tous les âges',
                    icon: Icons.all_inclusive_rounded,
                    isSelected: _selectedAgeFilter == null,
                    onTap: () => setState(() => _selectedAgeFilter = null),
                  ),
                  const SizedBox(width: 8),
                  KidFilterChip(
                    label: '0 - 3 ans',
                    icon: Icons.child_care_rounded,
                    isSelected: _selectedAgeFilter == 2,
                    onTap: () => setState(() => _selectedAgeFilter = 2),
                  ),
                  const SizedBox(width: 8),
                  KidFilterChip(
                    label: '4 - 6 ans',
                    icon: Icons.toys_outlined,
                    isSelected: _selectedAgeFilter == 5,
                    onTap: () => setState(() => _selectedAgeFilter = 5),
                  ),
                  const SizedBox(width: 8),
                  KidFilterChip(
                    label: '7 ans et +',
                    icon: Icons.school_outlined,
                    isSelected: _selectedAgeFilter == 8,
                    onTap: () => setState(() => _selectedAgeFilter = 8),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── LISTE DES TUTORIELS ──
            Expanded(
              child: tutorielsAsync.when(
                data: (tutoriels) {
                  final filtered = _filterTutoriels(tutoriels);

                  if (filtered.isEmpty) {
                    return _buildEmptyState(theme, isDark);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildKidTutorialCard(item, theme, isDark);
                    },
                  );
                },
                loading: () => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                  itemCount: 4,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (_, _) => const KidTutorialCardSkeleton(),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Erreur : $err',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Tutoriel> _filterTutoriels(List<Tutoriel> list) {
    final query = _searchQuery.trim().toLowerCase();

    return list.where((tut) {
      final matchesQuery = query.isEmpty ||
          tut.titre.toLowerCase().contains(query) ||
          tut.description.toLowerCase().contains(query);

      bool matchesAge = true;
      if (_selectedAgeFilter == 2) {
        matchesAge = tut.ageMinimum <= 3;
      } else if (_selectedAgeFilter == 5) {
        matchesAge = tut.ageMinimum <= 6 && tut.ageMaximum >= 4;
      } else if (_selectedAgeFilter == 8) {
        matchesAge = tut.ageMaximum >= 7;
      }

      return matchesQuery && matchesAge;
    }).toList();
  }

  Widget _buildKidTutorialCard(
    Tutoriel tut,
    ThemeData theme,
    bool isDark,
  ) {
    final ageLabel = '${tut.ageMinimum} - ${tut.ageMaximum} ans';
    final targetTutorielId = tut.tutorielId ?? '';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            if (targetTutorielId.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => KidThemeScope(
                    child: TutorielDetailEnfantPage(tutorielId: targetTutorielId),
                  ),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Miniature vidéo avec grand bouton play
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      color: const Color(0xFFFFEDD5),
                      child: tut.miniatureUrl.isNotEmpty
                          ? Image.network(
                              tut.miniatureUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _buildFallbackThumbnail(),
                            )
                          : _buildFallbackThumbnail(),
                    ),
                  ),

                  // Bouton Play festif
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: KidTheme.primaryGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),

                  // Durée
                  Positioned(
                    bottom: 10,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tut.dureeFormatted,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Titre et détails
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            ageLabel,
                            style: const TextStyle(
                              color: KidTheme.primaryGreenDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tut.titre,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tut.description,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackThumbnail() {
    return const Center(
      child: Icon(
        Icons.smart_display_rounded,
        size: 54,
        color: Color(0xFFEA580C),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: KidTheme.primaryGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.video_library_rounded,
                size: 52,
                color: KidTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun tutoriel trouvé',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Essaie de modifier tes filtres ou ta recherche.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
