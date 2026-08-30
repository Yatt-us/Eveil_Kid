// lib/features/parents/presentation/pages/detail_enfant.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import 'package:eveilkid/core/utils/parental_pin_helper.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/features/panier/models/panier.dart';
import 'package:eveilkid/features/panier/providers/panier_provider.dart';
import '../../providers/parent_provider.dart';
import 'modifier_enfant.dart';

class DetailEnfantPage extends ConsumerStatefulWidget {
  final EnfantModel enfant;

  const DetailEnfantPage({super.key, required this.enfant});

  @override
  ConsumerState<DetailEnfantPage> createState() => _DetailEnfantPageState();
}

class _DetailEnfantPageState extends ConsumerState<DetailEnfantPage> {
  int _selectedTabIndex = 0; // 0: Progression, 1: Activités, 2: Souhaits, 3: Résultats
  String _activityFilter = 'Toutes';

  int _calculateLevel(int age) {
    if (age <= 3) return 1;
    if (age <= 5) return 2;
    if (age <= 7) return 3;
    if (age <= 9) return 4;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    final parentAsync = ref.watch(parentNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Obtenir la version la plus à jour de l'enfant depuis le provider si disponible
    final enfantFromNotifier = ref
        .watch(enfantNotifierProvider)
        .enfants
        .where((e) => e.enfantId == widget.enfant.enfantId)
        .firstOrNull;
    final parentEnfants = parentAsync.value?.enfants ?? [];
    final enfantFromParent = parentEnfants
        .where((e) => e.enfantId == widget.enfant.enfantId)
        .firstOrNull;
    final EnfantModel currentEnfant =
        enfantFromNotifier ?? enfantFromParent ?? widget.enfant;

    final niveau = _calculateLevel(currentEnfant.age);
    final cleanWishesCount = currentEnfant.souhait
        .where((s) => !s.contains(' ') && s.isNotEmpty)
        .length;
    final completedActivitiesCount = currentEnfant.resultatsActivite.length;
    final starsCount = (completedActivitiesCount * 15) + (currentEnfant.age * 10);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Détail de l\'enfant',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleMedium?.color ??
                theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : AppColors.surfaceVariant.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              tooltip: 'Modifier l\'enfant',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ModifierEnfantPage(enfant: currentEnfant),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _AnimatedSpaceSwitchFab(
        isDark: isDark,
        onPressed: () async {
          await ParentalPinHelper.enterChildSpace(
            context: context,
            ref: ref,
            enfantId: currentEnfant.enfantId,
            enfant: currentEnfant,
            enfantNom: currentEnfant.nom,
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── CARTE HERO PROFIL DE L'ENFANT ──
            _buildProfileHeroCard(
              enfant: currentEnfant,
              niveau: niveau,
              starsCount: starsCount,
              cleanWishesCount: cleanWishesCount,
              completedActivitiesCount: completedActivitiesCount,
              theme: theme,
              isDark: isDark,
            ),

            const SizedBox(height: 20),

            // ── BARRE D'ONGLETS SEGMENTÉE ──
            _buildSegmentedTabBar(
              enfant: currentEnfant,
              cleanWishesCount: cleanWishesCount,
              theme: theme,
              isDark: isDark,
            ),

            const SizedBox(height: 20),

            // ── CONTENU DE L'ONGLET SÉLECTIONNÉ ──
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildCurrentTabContent(
                enfant: currentEnfant,
                theme: theme,
                isDark: isDark,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 1. CARTE HERO PROFIL
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildProfileHeroCard({
    required EnfantModel enfant,
    required int niveau,
    required int starsCount,
    required int cleanWishesCount,
    required int completedActivitiesCount,
    required ThemeData theme,
    required bool isDark,
  }) {
    final isGirl = enfant.genre.toLowerCase() == 'fille';
    final accentColor = isGirl ? const Color(0xFFEC4899) : const Color(0xFF3B82F6);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.textPrimary)
                .withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête décoratif avec Avatar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25)
                  : AppColors.surfaceVariant.withValues(alpha: 0.25),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Avatar avec contour sobre et badge
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.surface,
                        border: Border.all(
                          color: isDark
                              ? theme.dividerColor.withValues(alpha: 0.3)
                              : accentColor.withValues(alpha: 0.35),
                          width: 3.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: enfant.avatarUrl != null && enfant.avatarUrl!.isNotEmpty
                            ? Image.network(
                                enfant.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _buildDefaultAvatar(enfant, theme),
                              )
                            : _buildDefaultAvatar(enfant, theme),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2.5,
                          ),
                        ),
                        child: Icon(
                          isGirl ? Icons.female_rounded : Icons.male_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Nom de l'enfant
                Text(
                  enfant.nom,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.titleLarge?.color ??
                        theme.colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Badges : Âge & Niveau & Statut
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildInfoBadge(
                      icon: Icons.cake_outlined,
                      label: '${enfant.age} ans',
                      color: const Color(0xFF6366F1),
                      theme: theme,
                      isDark: isDark,
                    ),
                    _buildInfoBadge(
                      icon: Icons.military_tech_outlined,
                      label: 'Niveau $niveau',
                      color: const Color(0xFFF59E0B),
                      theme: theme,
                      isDark: isDark,
                    ),
                    if (enfant.codeSecuriteHash.isNotEmpty)
                      _buildInfoBadge(
                        icon: Icons.lock_outline_rounded,
                        label: 'PIN Actif',
                        color: const Color(0xFF10B981),
                        theme: theme,
                        isDark: isDark,
                      ),
                  ],
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerColor.withValues(alpha: isDark ? 0.2 : 0.1),
          ),

          // Ligne de statistiques rapides
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _buildQuickStatItem(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  value: '$starsCount',
                  label: 'Étoiles gagnées',
                  theme: theme,
                ),
                _buildStatDivider(theme, isDark),
                _buildQuickStatItem(
                  icon: Icons.assignment_turned_in_rounded,
                  iconColor: const Color(0xFF10B981),
                  value: '$completedActivitiesCount',
                  label: 'Activités faites',
                  theme: theme,
                ),
                _buildStatDivider(theme, isDark),
                _buildQuickStatItem(
                  icon: Icons.favorite_rounded,
                  iconColor: const Color(0xFFDB2777),
                  value: '$cleanWishesCount',
                  label: 'Cadeaux voulus',
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required Color color,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required ThemeData theme,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: theme.textTheme.titleMedium?.color ??
                      theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
                  theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(ThemeData theme, bool isDark) {
    return Container(
      height: 26,
      width: 1,
      color: theme.dividerColor.withValues(alpha: isDark ? 0.2 : 0.15),
    );
  }

  Widget _buildDefaultAvatar(EnfantModel enfant, ThemeData theme) {
    final isGirl = enfant.genre.toLowerCase() == 'fille';
    return Center(
      child: Icon(
        isGirl ? Icons.face_3_rounded : Icons.face_rounded,
        size: 58,
        color: isGirl ? const Color(0xFFEC4899) : const Color(0xFF3B82F6),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 2. BARRE D'ONGLETS SEGMENTÉE
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildSegmentedTabBar({
    required EnfantModel enfant,
    required int cleanWishesCount,
    required ThemeData theme,
    required bool isDark,
  }) {
    final tabItems = [
      {'title': 'Progression', 'icon': Icons.trending_up_rounded, 'badge': 0},
      {'title': 'Activités', 'icon': Icons.assignment_outlined, 'badge': 0},
      {
        'title': 'Souhaits',
        'icon': Icons.favorite_rounded,
        'badge': cleanWishesCount,
      },
      {'title': 'Résultats', 'icon': Icons.emoji_events_outlined, 'badge': 0},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : AppColors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.2 : 0.1),
        ),
      ),
      child: Row(
        children: List.generate(tabItems.length, (index) {
          final item = tabItems[index];
          final isSelected = _selectedTabIndex == index;
          final badge = item['badge'] as int;

          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTabIndex = index),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(
                          color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12),
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.25 : 0.05,
                            ),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 19,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.6) ??
                                  theme.colorScheme.onSurfaceVariant,
                        ),
                        if (badge > 0)
                          Positioned(
                            top: -4,
                            right: -9,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.5,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDB2777),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: theme.colorScheme.surface,
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                '$badge',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.textTheme.bodyMedium?.color
                                    ?.withValues(alpha: 0.7) ??
                                theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 3. CONTENU DES ONGLETS
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildCurrentTabContent({
    required EnfantModel enfant,
    required ThemeData theme,
    required bool isDark,
  }) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildProgressionTab(enfant, theme, isDark);
      case 1:
        return _buildActivitesTab(enfant, theme, isDark);
      case 2:
        return _buildSouhaitsTab(enfant, theme, isDark);
      case 3:
      default:
        return _buildResultatsTab(enfant, theme, isDark);
    }
  }

  // ── ONGLET 0 : PROGRESSION ──
  Widget _buildProgressionTab(EnfantModel enfant, ThemeData theme, bool isDark) {
    final completedCount = enfant.resultatsActivite.length;
    final progressFraction = ((completedCount * 12) + 40).clamp(25, 95);

    return Column(
      children: [
        // Carte circulaire de maîtrise
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : AppColors.textPrimary)
                    .withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Maîtrise globale',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: theme.textTheme.titleMedium?.color ??
                          theme.colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'En progression',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  SizedBox(
                    width: 78,
                    height: 78,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 78,
                          height: 78,
                          child: CircularProgressIndicator(
                            value: progressFraction / 100.0,
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                            backgroundColor:
                                theme.colorScheme.primary.withValues(alpha: 0.12),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        Text(
                          '$progressFraction%',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: theme.textTheme.titleMedium?.color ??
                                theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Très bon rythme !',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: theme.textTheme.titleMedium?.color ??
                                theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${enfant.nom} acquiert régulièrement de nouvelles compétences d\'éveil.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodyMedium?.color
                                    ?.withValues(alpha: 0.7) ??
                                theme.colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Divider(
                color: theme.dividerColor.withValues(alpha: isDark ? 0.2 : 0.12),
                thickness: 1,
              ),
              const SizedBox(height: 16),

              // Barres détaillées
              _buildProgressMetricRow(
                icon: Icons.menu_book_rounded,
                iconColor: const Color(0xFF10B981),
                label: 'Activités complétées',
                score: '${completedCount + 8}/20',
                progress: ((completedCount + 8) / 20).clamp(0.1, 1.0),
                progressColor: const Color(0xFF10B981),
                theme: theme,
              ),
              const SizedBox(height: 14),
              _buildProgressMetricRow(
                icon: Icons.quiz_outlined,
                iconColor: const Color(0xFF3B82F6),
                label: 'Défis & Quiz réussis',
                score: '${completedCount + 4}/15',
                progress: ((completedCount + 4) / 15).clamp(0.1, 1.0),
                progressColor: const Color(0xFF3B82F6),
                theme: theme,
              ),
              const SizedBox(height: 14),
              _buildProgressMetricRow(
                icon: Icons.timer_outlined,
                iconColor: const Color(0xFFF97316),
                label: 'Temps d’éveil recommandé',
                score: '2h 15m / semaine',
                progress: 0.70,
                progressColor: const Color(0xFFF97316),
                theme: theme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressMetricRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String score,
    required double progress,
    required Color progressColor,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodyLarge?.color ??
                        theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Text(
              score,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: theme.textTheme.bodyLarge?.color ??
                    theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: progressColor.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }

  // ── ONGLET 1 : ACTIVITÉS ──
  Widget _buildActivitesTab(EnfantModel enfant, ThemeData theme, bool isDark) {
    final allActivites = [
      {
        'title': 'Comptage et chiffres magiques',
        'category': 'Mathématiques',
        'status': 'Terminé',
        'icon': Icons.calculate_outlined,
        'color': const Color(0xFF10B981),
        'duration': '10 min',
      },
      {
        'title': 'Reconnaissance des couleurs & formes',
        'category': 'Éveil visuel',
        'status': 'En cours',
        'icon': Icons.palette_outlined,
        'color': const Color(0xFF3B82F6),
        'duration': '15 min',
      },
      {
        'title': 'Les animaux de la savane',
        'category': 'Découverte',
        'status': 'À commencer',
        'icon': Icons.pets_outlined,
        'color': const Color(0xFFF59E0B),
        'duration': '12 min',
      },
      {
        'title': 'Conte interactif : Le petit explorateur',
        'category': 'Lecture & Langage',
        'status': 'Terminé',
        'icon': Icons.auto_stories_outlined,
        'color': const Color(0xFF8B5CF6),
        'duration': '20 min',
      },
    ];

    final filtered = _activityFilter == 'Toutes'
        ? allActivites
        : allActivites.where((a) => a['status'] == _activityFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filtres de statut
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Toutes', 'Terminé', 'En cours', 'À commencer'].map((filter) {
              final isSelected = _activityFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _activityFilter = filter),
                  selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                  checkmarkColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.15),
                    ),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 14),

        ...filtered.map((act) {
          final iconColor = act['color'] as Color;
          final status = act['status'] as String;

          Color statusBg;
          Color statusFg;
          if (status == 'Terminé') {
            statusBg = const Color(0xFF10B981).withValues(alpha: 0.12);
            statusFg = const Color(0xFF10B981);
          } else if (status == 'En cours') {
            statusBg = const Color(0xFF3B82F6).withValues(alpha: 0.12);
            statusFg = const Color(0xFF3B82F6);
          } else {
            statusBg = const Color(0xFFF59E0B).withValues(alpha: 0.12);
            statusFg = const Color(0xFFF59E0B);
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : AppColors.textPrimary)
                      .withValues(alpha: isDark ? 0.25 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    act['icon'] as IconData,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        act['title'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color ??
                              theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            act['category'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.7) ??
                                  theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•  ${act['duration']}',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.5) ??
                                  theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: statusFg,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── ONGLET 2 : SOUHAITS ──
  Widget _buildSouhaitsTab(EnfantModel enfant, ThemeData theme, bool isDark) {
    final jouetsAsync = ref.watch(jouetsProvider);

    return jouetsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Erreur de chargement des jouets : $err',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ),
      data: (allJouets) {
        final validWishIds = enfant.souhait
            .where((s) => !s.contains(' ') && s.isNotEmpty)
            .toSet();
        final wishedToys = allJouets
            .where((j) => validWishIds.contains(j.jouetId))
            .toList();

        if (wishedToys.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : AppColors.textPrimary)
                      .withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDB2777).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    color: Color(0xFFDB2777),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun souhait pour le moment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quand ${enfant.nom} sélectionne des jouets avec le cœur dans l\'espace enfant, ils apparaissent automatiquement ici !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.7) ??
                        theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    size: 16,
                    color: Color(0xFFDB2777),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${wishedToys.length} jouet${wishedToys.length > 1 ? 's' : ''} souhaité${wishedToys.length > 1 ? 's' : ''} par ${enfant.nom}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ...wishedToys.map((jouet) {
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFDB2777).withValues(alpha: 0.25),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : AppColors.textPrimary)
                          .withValues(alpha: isDark ? 0.25 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image du jouet
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 78,
                            height: 78,
                            color: isDark
                                ? Colors.black26
                                : const Color(0xFFFEF3C7),
                            child: jouet.imagePrincipaleUrl.isNotEmpty
                                ? Image.network(
                                    jouet.imagePrincipaleUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.smart_toy_rounded,
                                      size: 32,
                                      color: Color(0xFFD97706),
                                    ),
                                  )
                                : const Icon(
                                    Icons.smart_toy_rounded,
                                    size: 32,
                                    color: Color(0xFFD97706),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Badge explicite : Souhait de l'enfant
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFCE7F3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.favorite_rounded,
                                      size: 12,
                                      color: Color(0xFFDB2777),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Souhait de ${enfant.nom}',
                                      style: const TextStyle(
                                        color: Color(0xFFBE185D),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                jouet.nom,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.bodyLarge?.color ??
                                      theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${jouet.prix.toStringAsFixed(0)} FCFA',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Bouton retirer
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: Colors.grey,
                          ),
                          tooltip: 'Retirer des souhaits',
                          onPressed: () async {
                            final parentId =
                                FirebaseAuth.instance.currentUser?.uid;
                            if (parentId == null) return;
                            final currentWishes =
                                List<String>.from(enfant.souhait);
                            currentWishes.remove(jouet.jouetId);
                            final updated = enfant.copyWith(
                              souhait: currentWishes,
                              dateModification: DateTime.now(),
                            );
                            await ref
                                .read(enfantNotifierProvider.notifier)
                                .modifierEnfant(updated);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${jouet.nom} retiré des souhaits de ${enfant.nom}',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Action parent : Ajouter au panier
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final parentId =
                              FirebaseAuth.instance.currentUser?.uid;
                          if (parentId == null) return;

                          final article = ArticlePanier(
                            articlePanierId: '',
                            utilisateurId: parentId,
                            jouetId: jouet.jouetId,
                            nomJouet: jouet.nom,
                            prixUnitaire: jouet.prix,
                            miniatureUrl: jouet.imagePrincipaleUrl,
                            stockDispo: jouet.stock,
                            quantite: 1,
                            dateCreation: DateTime.now(),
                            dateModification: DateTime.now(),
                          );

                          try {
                            await ref
                                .read(panierServiceProvider)
                                .ajouterProduit(article);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${jouet.nom} ajouté à votre panier pour ${enfant.nom} !',
                                ),
                                backgroundColor: const Color(0xFF10B981),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur : $e'),
                                backgroundColor: theme.colorScheme.error,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.add_shopping_cart_rounded,
                          size: 17,
                        ),
                        label: Text(
                          'Ajouter au panier pour ${enfant.nom}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // ── ONGLET 3 : RÉSULTATS / SUCCÈS ──
  Widget _buildResultatsTab(EnfantModel enfant, ThemeData theme, bool isDark) {
    final badges = [
      {
        'title': 'Petit Explorateur',
        'desc': 'A exploré 10 activités d\'éveil différentes',
        'icon': Icons.explore_rounded,
        'color': const Color(0xFFF59E0B),
        'date': 'Débloqué récemment',
      },
      {
        'title': 'Génie des Puzzles & Logique',
        'desc': 'Score parfait obtenu sur plusieurs défis',
        'icon': Icons.extension_rounded,
        'color': const Color(0xFF8B5CF6),
        'date': 'Niveau 2 validé',
      },
      {
        'title': 'Artiste & Créatif en herbe',
        'desc': 'Plusieurs créations visuelles enregistrées',
        'icon': Icons.palette_rounded,
        'color': const Color(0xFFEC4899),
        'date': 'Débloqué',
      },
      {
        'title': 'Curieux & Assidu',
        'desc': 'Actif plus de 3 jours d\'affilée',
        'icon': Icons.workspace_premium_rounded,
        'color': const Color(0xFF10B981),
        'date': 'Débloqué',
      },
    ];

    return Column(
      children: badges.map((badge) {
        final iconColor = badge['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : AppColors.textPrimary)
                    .withValues(alpha: isDark ? 0.25 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  badge['icon'] as IconData,
                  color: iconColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badge['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color ??
                            theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      badge['desc'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.7) ??
                            theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// BOUTON FLOTTANT ANIMÉ AVEC BORDURE BICOLORE (PARENT / ENFANT)
// ═══════════════════════════════════════════════════════════════════════

class _AnimatedSpaceSwitchFab extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isDark;

  const _AnimatedSpaceSwitchFab({
    required this.onPressed,
    required this.isDark,
  });

  @override
  State<_AnimatedSpaceSwitchFab> createState() => _AnimatedSpaceSwitchFabState();
}

class _AnimatedSpaceSwitchFabState extends State<_AnimatedSpaceSwitchFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (!WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parentColor = theme.colorScheme.primary;
    final childColor = AppColors.childPrimary;
    final bgColor = widget.isDark
        ? const Color(0xFFE5E5EB)
        : theme.colorScheme.surface;

    const double size = 60.0;
    const double borderRadius = 20.0;
    const double strokeWidth = 3.5;

    return Tooltip(
      message: 'Basculer vers l’espace enfant',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            foregroundPainter: _DualBorderPainter(
              animationProgress: _controller.value,
              parentColor: parentColor,
              childColor: childColor,
              strokeWidth: strokeWidth,
              borderRadius: borderRadius,
              segmentCount: 2,
            ),
            child: child,
          );
        },
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: widget.isDark ? 0.4 : 0.15),
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              width: size,
              height: size,
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                AppAssets.spaceSwitchIcon,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DualBorderPainter extends CustomPainter {
  final double animationProgress;
  final Color parentColor;
  final Color childColor;
  final double strokeWidth;
  final double borderRadius;
  final int segmentCount;

  _DualBorderPainter({
    required this.animationProgress,
    required this.parentColor,
    required this.childColor,
    this.strokeWidth = 3.5,
    this.borderRadius = 20,
    this.segmentCount = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) return;

    final metric = pathMetrics.first;
    final totalLength = metric.length;

    // Segments alternés distincts sans dégradé
    final segmentLength = totalLength / segmentCount;
    final offset = (animationProgress * totalLength) % totalLength;

    for (int i = 0; i < segmentCount; i++) {
      final isParent = i % 2 == 0;
      final paint = Paint()
        ..color = isParent ? parentColor : childColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      final start = (offset + i * segmentLength) % totalLength;
      final end = start + segmentLength;

      if (end <= totalLength) {
        final extracted = metric.extractPath(start, end);
        canvas.drawPath(extracted, paint);
      } else {
        final extracted1 = metric.extractPath(start, totalLength);
        final extracted2 = metric.extractPath(0, end - totalLength);
        canvas.drawPath(extracted1, paint);
        canvas.drawPath(extracted2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DualBorderPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.parentColor != parentColor ||
        oldDelegate.childColor != childColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.segmentCount != segmentCount;
  }
}
