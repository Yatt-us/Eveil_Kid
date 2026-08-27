// lib/features/parents/presentation/pages/liste_enfants.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import '../../providers/parent_provider.dart';
import 'ajouter_enfant.dart';
import 'detail_enfant.dart';
import 'modifier_enfant.dart';

class ListeEnfantsPage extends ConsumerStatefulWidget {
  const ListeEnfantsPage({super.key});

  @override
  ConsumerState<ListeEnfantsPage> createState() => _ListeEnfantsPageState();
}

class _ListeEnfantsPageState extends ConsumerState<ListeEnfantsPage> {
  String _searchQuery = '';
  String _selectedFilter = 'Tous';

  final List<String> _filters = const [
    'Tous',
    'Garçons',
    'Filles',
    '0 - 3 ans',
    '4 - 6 ans',
    '7+ ans',
  ];

  bool _matchesFilter(EnfantModel enfant) {
    switch (_selectedFilter) {
      case 'Garçons':
        return enfant.genre.trim().toLowerCase() == 'garçon' ||
            enfant.genre.trim().toLowerCase() == 'garcon';
      case 'Filles':
        return enfant.genre.trim().toLowerCase() == 'fille';
      case '0 - 3 ans':
        return (enfant.age) <= 3;
      case '4 - 6 ans':
        return (enfant.age) >= 4 && (enfant.age) <= 6;
      case '7+ ans':
        return (enfant.age) >= 7;
      case 'Tous':
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final parentAsync = ref.watch(parentNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mes Enfants',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color ?? theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.person_add_alt_1_rounded,
              color: theme.colorScheme.primary,
            ),
            tooltip: 'Ajouter un enfant',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AjouterEnfantPage()),
              );
            },
          ),
          AppSpacing.horizontalSm,
        ],
      ),
      body: parentAsync.when(
        data: (parent) {
          final allEnfants = parent.enfants;
          final filteredEnfants = allEnfants.where((e) {
            final matchesQuery = _searchQuery.isEmpty ||
                e.nom.toLowerCase().contains(_searchQuery.toLowerCase());
            return matchesQuery && _matchesFilter(e);
          }).toList();

          return Column(
            children: [
              // ── Barre de recherche & Filtres ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSearchBar(
                      hintText: 'Rechercher un enfant...',
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                    AppSpacing.verticalSm,
                    // Filtres horizontaux
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final filter = _filters[index];
                          final isSelected = _selectedFilter == filter;

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.dividerColor.withValues(alpha: 0.25),
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Text(
                                filter,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : (theme.textTheme.bodyMedium?.color
                                              ?.withValues(alpha: 0.7) ??
                                          theme.colorScheme.onSurfaceVariant),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    AppSpacing.verticalSm,
                    // Compteur d'enfants
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          filteredEnfants.length == allEnfants.length
                              ? '${allEnfants.length} enfant${allEnfants.length > 1 ? 's' : ''} enregistré${allEnfants.length > 1 ? 's' : ''}'
                              : '${filteredEnfants.length} sur ${allEnfants.length} enfant${allEnfants.length > 1 ? 's' : ''}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.7) ??
                                theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_selectedFilter != 'Tous' || _searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilter = 'Tous';
                                _searchQuery = '';
                              });
                            },
                            child: Text(
                              'Réinitialiser',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Liste ou État Vide ──
              Expanded(
                child: filteredEnfants.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _searchQuery.isNotEmpty || _selectedFilter != 'Tous'
                                      ? Icons.search_off_rounded
                                      : Icons.child_care_rounded,
                                  size: 56,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              AppSpacing.verticalMd,
                              Text(
                                _searchQuery.isNotEmpty || _selectedFilter != 'Tous'
                                    ? 'Aucun résultat trouvé'
                                    : 'Aucun enfant enregistré',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textTheme.titleMedium?.color ??
                                      theme.colorScheme.onSurface,
                                ),
                              ),
                              AppSpacing.verticalXs,
                              Text(
                                _searchQuery.isNotEmpty || _selectedFilter != 'Tous'
                                    ? 'Modifiez votre recherche ou sélectionnez un autre filtre.'
                                    : 'Utilisez le bouton ci-dessous pour ajouter votre premier enfant et personnaliser son apprentissage.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: theme.textTheme.bodyMedium?.color
                                          ?.withValues(alpha: 0.7) ??
                                      theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: filteredEnfants.length,
                        separatorBuilder: (context, index) => AppSpacing.verticalMd,
                        itemBuilder: (context, index) {
                          final enfant = filteredEnfants[index];
                          return _buildChildCard(context, enfant, theme, isDark);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Erreur : $err',
              style: TextStyle(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AjouterEnfantPage()),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Ajouter un enfant',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildChildCard(
    BuildContext context,
    EnfantModel enfant,
    ThemeData theme,
    bool isDark,
  ) {
    final isGirl = enfant.genre.trim().toLowerCase() == 'fille';
    final badgeBg = isGirl
        ? (isDark ? const Color(0xFF4A154B) : const Color(0xFFFDE8F3))
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFEBF3FE));
    final badgeText = isGirl
        ? (isDark ? const Color(0xFFF472B6) : const Color(0xFFD81B60))
        : (isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E88E5));
    final avatarBg = isGirl
        ? (isDark ? const Color(0xFF3B123C) : const Color(0xFFFFEEF6))
        : (isDark ? const Color(0xFF172554) : const Color(0xFFEEF5FD));

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.textPrimary)
                .withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailEnfantPage(enfant: enfant),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              AppAvatar(
                imageUrl: enfant.avatarUrl,
                name: enfant.nom,
                radius: 29,
                defaultIcon: isGirl ? Icons.face_3_rounded : Icons.face_rounded,
              ),
              AppSpacing.horizontalMd,
              // Infos Enfant
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enfant.nom,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.titleMedium?.color ??
                            theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${enfant.age} an${enfant.age > 1 ? 's' : ''}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.7) ??
                                theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isGirl ? 'Fille' : 'Garçon',
                            style: TextStyle(
                              color: badgeText,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Bouton Modifier
              IconButton(
                icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                tooltip: 'Modifier',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ModifierEnfantPage(enfant: enfant),
                    ),
                  );
                },
              ),
              // Bouton Supprimer
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    color: theme.colorScheme.error),
                tooltip: 'Supprimer',
                onPressed: () async {
                  final confirmed = await AppDialogs.showConfirmDialog(
                    context: context,
                    title: 'Supprimer ${enfant.nom} ?',
                    message:
                        'Êtes-vous sûr de vouloir supprimer le profil de cet enfant ?',
                    confirmText: 'Supprimer',
                    cancelText: 'Annuler',
                    isDanger: true,
                  );
                  if (confirmed == true && context.mounted) {
                    await ref
                        .read(parentNotifierProvider.notifier)
                        .supprimerEnfant(enfant.enfantId);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
