// lib/features/parent/presentation/pages/liste_enfants.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../models/parent_model.dart';
import '../../providers/parent_provider.dart';
import 'ajouter_enfant.dart';
import 'modifier_enfant.dart';

class ListeEnfantsPage extends ConsumerStatefulWidget {
  const ListeEnfantsPage({super.key});

  @override
  ConsumerState<ListeEnfantsPage> createState() => _ListeEnfantsPageState();
}

class _ListeEnfantsPageState extends ConsumerState<ListeEnfantsPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final parentAsync = ref.watch(parentNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Enfants', style: AppTextStyles.headingSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined, color: AppColors.primary),
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
            return e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                e.level.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher un enfant...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.icon),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        fillColor: AppColors.surface,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.input,
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.input,
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                    AppSpacing.verticalSm,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${allEnfants.length} enfant${allEnfants.length > 1 ? 's' : ''} enregistré${allEnfants.length > 1 ? 's' : ''}',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredEnfants.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: AppPadding.allLg,
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceVariant,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.child_care, size: 48, color: AppColors.icon),
                            ),
                            AppSpacing.verticalMd,
                            Text(
                              _searchQuery.isNotEmpty ? 'Aucun résultat trouvé' : 'Aucun enfant enregistré',
                              style: AppTextStyles.headingSmall,
                            ),
                            AppSpacing.verticalXs,
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Essayez une autre recherche'
                                  : 'Ajoutez votre premier enfant pour personnaliser son expérience.',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                            AppSpacing.verticalLg,

                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: AppPadding.screen,
                        itemCount: filteredEnfants.length,
                        separatorBuilder: (_, i) => AppSpacing.verticalMd,
                        itemBuilder: (context, index) {
                          final enfant = filteredEnfants[index];
                          return _buildChildCard(context, enfant);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Erreur: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AjouterEnfantPage()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('Ajouter un enfant', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildChildCard(BuildContext context, EnfantModel enfant) {
    Color badgeBg;
    Color badgeText;

    if (enfant.level.contains('3')) {
      badgeBg = const Color(0xFFEDE7F6);
      badgeText = const Color(0xFF7E57C2);
    } else if (enfant.level.contains('4')) {
      badgeBg = const Color(0xFFE0F2F1);
      badgeText = const Color(0xFF00897B);
    } else {
      badgeBg = const Color(0xFFFFF3E0);
      badgeText = const Color(0xFFFB8C00);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: AppPadding.card,
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.surfaceVariant,
              child: Icon(Icons.face_rounded, size: 36, color: badgeText),
            ),
            AppSpacing.horizontalMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enfant.name,
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  AppSpacing.verticalXs,
                  Text(
                    '${enfant.age} ans',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  AppSpacing.verticalXs,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: AppRadius.badge,
                    ),
                    child: Text(
                      enfant.level,
                      style: TextStyle(
                        color: badgeText,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ModifierEnfantPage(enfant: enfant)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: () async {
                final confirmed = await AppDialogs.showConfirmDialog(
                  context: context,
                  title: 'Supprimer ${enfant.name} ?',
                  message: 'Êtes-vous sûr de vouloir supprimer cet enfant ?',
                  confirmText: 'Supprimer',
                  cancelText: 'Annuler',
                  isDanger: true,
                );
                if (confirmed == true && context.mounted) {
                  await ref.read(parentNotifierProvider.notifier).supprimerEnfant(enfant.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
