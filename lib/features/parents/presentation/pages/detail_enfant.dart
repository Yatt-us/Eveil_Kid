// lib/features/parents/presentation/pages/detail_enfant.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import '../../providers/parent_provider.dart';
import 'modifier_enfant.dart';

class DetailEnfantPage extends ConsumerStatefulWidget {
  final EnfantModel enfant;

  const DetailEnfantPage({super.key, required this.enfant});

  @override
  ConsumerState<DetailEnfantPage> createState() => _DetailEnfantPageState();
}

class _DetailEnfantPageState extends ConsumerState<DetailEnfantPage> {
  int _selectedTabIndex = 0; // 0: Progression, 1: Activités, 2: Résultats

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

    // Obtenir la version la plus à jour de l'enfant depuis le provider si disponible
    final currentEnfant = parentAsync.maybeWhen(
      data: (parent) =>
          parent.enfants.where((e) => e.enfantId == widget.enfant.enfantId).firstOrNull ??
          widget.enfant,
      orElse: () => widget.enfant,
    );

    final niveau = _calculateLevel(currentEnfant.age);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.textPrimary,
              size: 24,
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
          AppSpacing.horizontalSm,
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  AppSpacing.verticalSm,

                  // ── AVATAR AVEC BADGE CAMÉRA ──
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE8DEFA),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: currentEnfant.avatarUrl != null &&
                                    currentEnfant.avatarUrl!.isNotEmpty
                                ? Image.network(
                                    currentEnfant.avatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildDefaultAvatar(currentEnfant),
                                  )
                                : _buildDefaultAvatar(currentEnfant),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF763CD1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 16,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppSpacing.verticalMd,

                  // ── NOM DE L'ENFANT ──
                  Text(
                    currentEnfant.nom,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  AppSpacing.verticalXs,

                  // ── ÂGE ET NIVEAU ──
                  Text(
                    '${currentEnfant.age} ans   -   Niveau $niveau',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  AppSpacing.verticalLg,

                  // ── BARRE D'ONGLETS ──
                  _buildCustomTabBar(),

                  AppSpacing.verticalLg,

                  // ── CONTENU DE L'ONGLET SÉLECTIONNÉ ──
                  if (_selectedTabIndex == 0)
                    _buildProgressionTab(currentEnfant)
                  else if (_selectedTabIndex == 1)
                    _buildActivitesTab(currentEnfant)
                  else
                    _buildResultatsTab(currentEnfant),

                  AppSpacing.verticalXl,
                ],
              ),
            ),
          ),

          // ── BOUTON INFÉRIEUR "BASCULER VERS L'ESPACE ENFANT" ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  context.go(AppRoutes.espaceEnfantFor(currentEnfant.enfantId));
                  AppDialogs.showSnackBar(
                    context: context,
                    message:
                        'Bascule vers l\'espace de ${currentEnfant.nom} en cours...',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E2BA8),
                  foregroundColor: AppColors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFF5E2BA8).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Basculer vers l’espace enfant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(EnfantModel enfant) {
    return Center(
      child: Icon(
        enfant.genre.toLowerCase() == 'fille'
            ? Icons.face_3_rounded
            : Icons.face_rounded,
        size: 70,
        color: const Color(0xFF763CD1),
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
        ),
      ),
      child: Row(
        children: [
          _buildTabItem(
            index: 0,
            title: 'Progression',
            icon: Icons.trending_up_rounded,
          ),
          _buildTabItem(
            index: 1,
            title: 'Activités',
            icon: Icons.assignment_outlined,
          ),
          _buildTabItem(
            index: 2,
            title: 'Résultats',
            icon: Icons.notifications_none_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedTabIndex == index;
    const activeColor = Color(0xFF763CD1);
    const inactiveColor = Color(0xFF4B5563);

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressionTab(EnfantModel enfant) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F2F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progression global',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.verticalLg,

          // ── CERCLE DE PROGRESSION & MESSAGE ──
          Row(
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 76,
                      height: 76,
                      child: CircularProgressIndicator(
                        value: 0.75,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: const Color(0xFFEDE9FE),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF6C4AB6),
                        ),
                      ),
                    ),
                    const Text(
                      '75%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Très bien !',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${enfant.nom} progresse bien.',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.verticalLg,
          const Divider(color: Color(0xFFF1F2F6), thickness: 1.2),
          AppSpacing.verticalMd,

          // ── BARRE 1 : ACTIVITÉS COMPLÉTÉES ──
          _buildStatProgressBar(
            label: 'Activités complétées',
            score: '28/40',
            progress: 28 / 40,
            progressColor: const Color(0xFF10B981), // Vert
          ),
          AppSpacing.verticalLg,

          // ── BARRE 2 : DÉFIS RÉUSSIS ──
          _buildStatProgressBar(
            label: 'Défis réussis',
            score: '12/40',
            progress: 12 / 40,
            progressColor: const Color(0xFF3B82F6), // Bleu
          ),
          AppSpacing.verticalLg,

          // ── BARRE 3 : TEMPS D'APPRENTISSAGE ──
          _buildStatProgressBar(
            label: 'Temps d’apprentissage',
            score: '3h 45min',
            progress: 0.55,
            progressColor: const Color(0xFFF97316), // Orange
          ),
        ],
      ),
    );
  }

  Widget _buildStatProgressBar({
    required String label,
    required String score,
    required double progress,
    required Color progressColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              score,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitesTab(EnfantModel enfant) {
    final activites = [
      {
        'title': 'Comptage et chiffres',
        'category': 'Mathématiques',
        'status': 'Terminé',
        'icon': Icons.calculate_outlined,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Reconnaissance des couleurs',
        'category': 'Éveil visuel',
        'status': 'En cours',
        'icon': Icons.palette_outlined,
        'color': const Color(0xFF3B82F6),
      },
      {
        'title': 'Les animaux de la forêt',
        'category': 'Découverte',
        'status': 'À commencer',
        'icon': Icons.pets_outlined,
        'color': const Color(0xFFF59E0B),
      },
    ];

    return Column(
      children: activites.map((act) {
        final iconColor = act['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F2F6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  act['icon'] as IconData,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      act['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      act['category'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  act['status'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultatsTab(EnfantModel enfant) {
    final badges = [
      {
        'title': 'Petit Explorateur',
        'desc': '10 activités terminées',
        'icon': '🌟',
      },
      {
        'title': 'Génie des Puzzles',
        'desc': 'Score parfait sur 5 puzzles',
        'icon': '🧩',
      },
      {
        'title': 'Artiste en herbe',
        'desc': '3 dessins créés',
        'icon': '🎨',
      },
    ];

    return Column(
      children: badges.map((badge) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F2F6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                badge['icon'] as String,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badge['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      badge['desc'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
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
