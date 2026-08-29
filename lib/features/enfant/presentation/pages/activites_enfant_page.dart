import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';
import 'package:eveilkid/features/activites/models/activity.dart';
import 'package:eveilkid/features/activites/providers/admin/activity_provider.dart';
import 'package:eveilkid/features/enfant/providers/child_mode_provider.dart';
import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';

class ActivitesEnfantPage extends ConsumerStatefulWidget {
  const ActivitesEnfantPage({super.key});

  @override
  ConsumerState<ActivitesEnfantPage> createState() =>
      _ActivitesEnfantPageState();
}

class _ActivitesEnfantPageState extends ConsumerState<ActivitesEnfantPage> {
  int _filtreStatut = 0; // 0 = Toutes, 1 = En cours, 2 = Terminées
  String _categorieSelectionnee = 'Toutes';

  final List<String> _categories = const [
    'Toutes',
    'Maths 🔢',
    'Animaux 🦁',
    'Couleurs 🎨',
    'Formes 🔷',
    'Éveil 🚀',
  ];

  final List<Map<String, dynamic>> _activitesParDefaut = const [
    {
      'id': '1',
      'titre': 'Le Safari des Animaux',
      'categorie': 'Animaux 🦁',
      'duree': '10 min',
      'emoji': '🦁',
      'progression': 0.80,
      'difficulte': 'Facile',
      'points': 20,
      'description':
          'Reconnais les animaux de la savane et apprends leurs cris rigolos !',
    },
    {
      'id': '2',
      'titre': 'La Ronde des Couleurs',
      'categorie': 'Couleurs 🎨',
      'duree': '8 min',
      'emoji': '🎨',
      'progression': 0.90,
      'difficulte': 'Facile',
      'points': 15,
      'description':
          'Mélange les couleurs primaires et découvre de magnifiques teintes magiques.',
    },
    {
      'id': '3',
      'titre': 'Comptons les Étoiles',
      'categorie': 'Maths 🔢',
      'duree': '12 min',
      'emoji': '🔢',
      'progression': 0.50,
      'difficulte': 'Moyen',
      'points': 25,
      'description':
          'Apprends à compter jusqu’à 10 avec des constellations lumineuses.',
    },
    {
      'id': '4',
      'titre': 'Puzzle des Formes Géométriques',
      'categorie': 'Formes 🔷',
      'duree': '10 min',
      'emoji': '🔷',
      'progression': 0.35,
      'difficulte': 'Moyen',
      'points': 20,
      'description':
          'Assemble les ronds, carrés et triangles pour construire un château.',
    },
    {
      'id': '5',
      'titre': 'Voyage dans l’Espace',
      'categorie': 'Éveil 🚀',
      'duree': '15 min',
      'emoji': '🚀',
      'progression': 0.10,
      'difficulte': 'Champion',
      'points': 30,
      'description':
          'Explore le système solaire et pilote ta propre fusée spatiale !',
    },
    {
      'id': '6',
      'titre': 'Le Panier de Fruits Délicieux',
      'categorie': 'Éveil 🚀',
      'duree': '7 min',
      'emoji': '🍎',
      'progression': 1.0,
      'difficulte': 'Facile',
      'points': 15,
      'description':
          'Nomme les fruits savoureux et découvre leurs vitamines d’énergie.',
    },
  ];

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── APP BAR LUDIQUE ENFANT ──
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
                          'Jeux & Activités 🎮',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Apprends en t’amusant !',
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
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
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
                          '${(enfant?.resultatsActivite.length ?? 0) * 15 + 30} ⭐',
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

            // ── FILTRES D'ÉTAT (Toutes, En cours, Terminées) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStateFilterTab('Toutes', 0, theme, isDark),
                  const SizedBox(width: 8),
                  _buildStateFilterTab('En cours', 1, theme, isDark),
                  const SizedBox(width: 8),
                  _buildStateFilterTab('Terminées 🏆', 2, theme, isDark),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── FILTRES PAR CATÉGORIES LUDIQUES ──
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _categorieSelectionnee == cat;

                  return GestureDetector(
                    onTap: () => setState(() => _categorieSelectionnee = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? KidTheme.primaryGreen
                            : (isDark
                                ? theme.colorScheme.surfaceContainerHighest
                                : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? KidTheme.primaryGreen
                              : theme.dividerColor.withValues(
                                  alpha: isDark ? 0.3 : 0.2,
                                ),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: KidTheme.primaryGreen
                                      .withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── LISTE DES ACTIVITÉS ──
            Expanded(
              child: firestoreActivitesAsync.maybeWhen(
                data: (firestoreActivities) {
                  final listToDisplay = _getFilteredActivities(firestoreActivities);

                  if (listToDisplay.isEmpty) {
                    return _buildEmptyState(theme, isDark);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    itemCount: listToDisplay.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final act = listToDisplay[index];
                      return _buildActivityCard(act, theme, isDark);
                    },
                  );
                },
                orElse: () {
                  final listToDisplay = _getFilteredActivities([]);
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    itemCount: listToDisplay.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final act = listToDisplay[index];
                      return _buildActivityCard(act, theme, isDark);
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

  Widget _buildStateFilterTab(
    String label,
    int index,
    ThemeData theme,
    bool isDark,
  ) {
    final isSelected = _filtreStatut == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filtreStatut = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? KidTheme.primaryGreen.withValues(alpha: isDark ? 0.25 : 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? KidTheme.primaryGreen
                  : theme.dividerColor.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? KidTheme.primaryGreenDark
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredActivities(
    List<Activite> firestoreActivities,
  ) {
    var items = List<Map<String, dynamic>>.from(_activitesParDefaut);

    if (firestoreActivities.isNotEmpty) {
      for (final fa in firestoreActivities) {
        items.add({
          'id': fa.id ?? '',
          'titre': fa.titre,
          'categorie': 'Éveil 🚀',
          'duree': '${fa.dureeEnMinutes} min',
          'emoji': '⭐',
          'progression': 0.0,
          'difficulte': fa.difficulte.isNotEmpty ? fa.difficulte : 'Moyen',
          'points': fa.points,
          'description': fa.description,
        });
      }
    }

    return items.where((act) {
      final prog = (act['progression'] as num).toDouble();

      // Filtre statut
      if (_filtreStatut == 1 && (prog <= 0.0 || prog >= 1.0)) return false;
      if (_filtreStatut == 2 && prog < 1.0) return false;

      // Filtre catégorie
      if (_categorieSelectionnee != 'Toutes' &&
          act['categorie'] != _categorieSelectionnee) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildActivityCard(
    Map<String, dynamic> act,
    ThemeData theme,
    bool isDark,
  ) {
    final prog = (act['progression'] as num).toDouble();
    final isCompleted = prog >= 1.0;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCompleted
              ? KidTheme.primaryGreen.withValues(alpha: 0.5)
              : theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => _showPlayActivitySheet(act),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icône / Emoji ludique
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDark
                        ? KidTheme.primaryGreen.withValues(alpha: 0.2)
                        : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: KidTheme.primaryGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      act['emoji'] ?? '🎮',
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Informations
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              act['titre'],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCompleted)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: KidTheme.primaryGreen,
                              size: 18,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '⏱ ${act['duree']}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '+${act['points']} ⭐',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Barre de progression
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: prog,
                          minHeight: 6,
                          backgroundColor:
                              KidTheme.primaryGreen.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted
                                ? KidTheme.primaryGreen
                                : KidTheme.playfulSky,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Bouton Jouer
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFFDCFCE7)
                        : KidTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.replay_rounded
                        : Icons.play_arrow_rounded,
                    color: isCompleted
                        ? KidTheme.primaryGreenDark
                        : Colors.white,
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

  void _showPlayActivitySheet(Map<String, dynamic> act) {
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
                const SizedBox(height: 20),
                Text(
                  act['emoji'] ?? '🎮',
                  style: const TextStyle(fontSize: 56),
                ),
                const SizedBox(height: 12),
                Text(
                  act['titre'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${act['categorie']} • Durée : ${act['duree']}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: KidTheme.primaryGreenDark,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  act['description'] ??
                      'Une activité captivante pour stimuler ta créativité et ton raisonnement !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '🌟 Défi "${act['titre']}" lancé ! Amuse-toi bien !',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: KidTheme.primaryGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.rocket_launch_rounded),
                    label: const Text(
                      'Commencer l’aventure !',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
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
                Icons.search_off_rounded,
                size: 52,
                color: KidTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune activité trouvée',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Essaie de sélectionner un autre filtre ou une autre catégorie.',
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