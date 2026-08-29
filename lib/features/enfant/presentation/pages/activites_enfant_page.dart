import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';
import 'package:eveilkid/features/activites/models/activity.dart';
import 'package:eveilkid/features/activites/providers/admin/activity_provider.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import 'package:eveilkid/features/enfant/presentation/pages/questions_enfant_page.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/kid_filter_chip.dart';
import 'package:eveilkid/features/enfant/providers/child_mode_provider.dart';
import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

class ActivitesEnfantPage extends ConsumerStatefulWidget {
  const ActivitesEnfantPage({super.key});

  @override
  ConsumerState<ActivitesEnfantPage> createState() => _ActivitesEnfantPageState();
}

class _ActivitesEnfantPageState extends ConsumerState<ActivitesEnfantPage> {
  int _filtreStatut = 0; // 0 = Toutes, 1 = En cours, 2 = Terminées
  String? _selectedCategorieId; // null = Toutes les catégories

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final childMode = ref.watch(childModeProvider);
    final enfant = childMode.activeChild ??
        ref.watch(
          enfantNotifierProvider.select((state) => state.enfantSelectionne),
        );

    final firestoreActivitesAsync = ref.watch(activitesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    final categoriesMap = <String, String>{};
    categoriesAsync.whenData((categories) {
      for (final cat in categories) {
        categoriesMap[cat.categorieId] = cat.nom;
      }
    });

    final totalStars = _calculateTotalStars(enfant);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── BARRE SUPÉRIEURE ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                          'Jeux et Activités',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Défis et apprentissage ludique',
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF78350F).withValues(alpha: 0.4)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Color(0xFFD97706),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$totalStars points',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── BARRE DE FILTRE DE STATUT (SEGMENTED) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: KidFilterSegmentBar(
                items: const ['Toutes', 'En cours', 'Terminées'],
                icons: const [
                  Icons.grid_view_rounded,
                  Icons.play_circle_outline_rounded,
                  Icons.check_circle_outline_rounded,
                ],
                selectedIndex: _filtreStatut,
                onSelected: (idx) => setState(() => _filtreStatut = idx),
              ),
            ),

            const SizedBox(height: 12),

            // ── FILTRES PAR CATÉGORIES (KID FILTER CHIPS) ──
            categoriesAsync.when(
              data: (categories) => _buildCategoriesBar(categories),
              loading: () => const SizedBox(
                height: 42,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 10),

            // ── LISTE RESPONSIVE DES ACTIVITÉS ──
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(activitesProvider);
                  ref.invalidate(categoriesProvider);
                },
                child: firestoreActivitesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (err, _) => Center(
                    child: AppErrorState(
                      title: 'Impossible de charger les activités',
                      message: '$err',
                      onRetry: () => ref.invalidate(activitesProvider),
                    ),
                  ),
                  data: (activities) {
                    final filteredActivities = _filterActivities(activities, enfant);

                    if (filteredActivities.isEmpty) {
                      return _buildEmptyState(theme);
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 960;
                        final isDesktop = constraints.maxWidth >= 960;
                        final horizontalPadding = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);

                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: isDesktop || isTablet
                                ? GridView.builder(
                                    padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 30),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: isDesktop ? 3 : 2,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                      mainAxisExtent: 155,
                                    ),
                                    itemCount: filteredActivities.length,
                                    itemBuilder: (context, index) {
                                      final act = filteredActivities[index];
                                      return _buildActivityCard(
                                        activite: act,
                                        enfant: enfant,
                                        categorieNom: categoriesMap[act.categorieId] ?? 'Activité',
                                        theme: theme,
                                        isDark: isDark,
                                      );
                                    },
                                  )
                                : ListView.separated(
                                    padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 30),
                                    itemCount: filteredActivities.length,
                                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final act = filteredActivities[index];
                                      return _buildActivityCard(
                                        activite: act,
                                        enfant: enfant,
                                        categorieNom: categoriesMap[act.categorieId] ?? 'Activité',
                                        theme: theme,
                                        isDark: isDark,
                                      );
                                    },
                                  ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesBar(List<Categorie> categories) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _selectedCategorieId == null;
            return KidFilterChip(
              label: 'Toutes',
              icon: Icons.all_inclusive_rounded,
              isSelected: isSelected,
              onTap: () => setState(() => _selectedCategorieId = null),
            );
          }

          final cat = categories[index - 1];
          final isSelected = _selectedCategorieId == cat.categorieId;

          return KidFilterChip(
            label: cat.nom,
            icon: Icons.category_outlined,
            isSelected: isSelected,
            onTap: () => setState(() => _selectedCategorieId = cat.categorieId),
          );
        },
      ),
    );
  }

  List<Activite> _filterActivities(List<Activite> allActivities, EnfantModel? enfant) {
    return allActivities.where((act) {
      if (_selectedCategorieId != null && act.categorieId != _selectedCategorieId) {
        return false;
      }

      final progress = _getActivityProgress(act.id, enfant);
      final isCompleted = progress >= 1.0;

      if (_filtreStatut == 1) {
        if (isCompleted || progress == 0.0) return false;
      } else if (_filtreStatut == 2) {
        if (!isCompleted) return false;
      }

      return true;
    }).toList();
  }

  double _getActivityProgress(String? activityId, EnfantModel? enfant) {
    if (activityId == null || enfant == null) return 0.0;
    final results = enfant.resultatsActivite;
    for (final res in results) {
      if (res is Map && res['activiteId'] == activityId) {
        if (res['termine'] == true || res['estReussi'] == true) {
          return 1.0;
        }
        final prog = res['progression'];
        if (prog is num) return prog.toDouble();
        return 0.5;
      }
    }
    return 0.0;
  }

  int _calculateTotalStars(EnfantModel? enfant) {
    if (enfant == null) return 30;
    int total = 30;
    for (final res in enfant.resultatsActivite) {
      if (res is Map) {
        final points = res['pointsGagnes'];
        if (points is num) {
          total += points.toInt();
        } else {
          total += 15;
        }
      }
    }
    return total;
  }

  Widget _buildActivityCard({
    required Activite activite,
    required EnfantModel? enfant,
    required String categorieNom,
    required ThemeData theme,
    required bool isDark,
  }) {
    final progress = _getActivityProgress(activite.id, enfant);
    final isCompleted = progress >= 1.0;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCompleted
              ? KidTheme.primaryGreen.withValues(alpha: 0.6)
              : theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12),
          width: isCompleted ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: () => _showPlayActivitySheet(activite, categorieNom, isCompleted),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // 1. Illustration / Badge Icône
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: isDark
                          ? KidTheme.primaryGreen.withValues(alpha: 0.2)
                          : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: activite.imageUrl != null && activite.imageUrl!.isNotEmpty
                        ? Image.network(
                            activite.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildDefaultActivityIcon(isDark),
                          )
                        : _buildDefaultActivityIcon(isDark),
                  ),
                ),

                const SizedBox(width: 14),

                // 2. Informations de l'activité
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              activite.titre,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCompleted) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.check_circle_rounded,
                              color: KidTheme.primaryGreen,
                              size: 18,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        categorieNom,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: KidTheme.primaryGreenDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 13,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${activite.dureeEnMinutes} min',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF78350F).withValues(alpha: 0.4)
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 13,
                                  color: Color(0xFFD97706),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '+${activite.points} pts',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Barre de progression
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: isCompleted ? 1.0 : progress,
                          minHeight: 5,
                          backgroundColor: KidTheme.primaryGreen.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted ? KidTheme.primaryGreen : KidTheme.playfulSky,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // 3. Bouton Lancer / Rejouer
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? (isDark ? KidTheme.primaryGreen.withValues(alpha: 0.2) : const Color(0xFFDCFCE7))
                        : KidTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.replay_rounded : Icons.play_arrow_rounded,
                    color: isCompleted ? KidTheme.primaryGreenDark : Colors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultActivityIcon(bool isDark) {
    return Center(
      child: Icon(
        Icons.sports_esports_rounded,
        size: 32,
        color: KidTheme.primaryGreenDark,
      ),
    );
  }

  void _showPlayActivitySheet(Activite act, String categorieNom, bool isCompleted) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: KidTheme.primaryGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.sports_esports_rounded,
                        color: KidTheme.primaryGreenDark,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            act.titre,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '$categorieNom • ${act.dureeEnMinutes} min • +${act.points} points',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (act.description.isNotEmpty) ...[
                  Text(
                    act.description,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                if (act.objectifsApprentissage.isNotEmpty) ...[
                  Text(
                    'Objectifs :',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...act.objectifsApprentissage.map(
                    (obj) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: KidTheme.primaryGreen,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              obj,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuestionsEnfantPage(activite: act),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KidTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: Icon(
                      isCompleted ? Icons.replay_rounded : Icons.play_arrow_rounded,
                      size: 22,
                    ),
                    label: Text(
                      isCompleted ? 'Rejouer l\'activité' : 'Commencer le défi',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
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
                Icons.sports_esports_outlined,
                size: 48,
                color: KidTheme.primaryGreenDark,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune activité disponible',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Revenez bientôt pour découvrir de nouveaux jeux et défis.',
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