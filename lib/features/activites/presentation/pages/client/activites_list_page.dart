import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/AppPadding.dart';
import '../../../../../core/constants/AppSpacing.dart';
import '../../../../../core/constants/AppTextStyles.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../models/activite.dart';
import '../../../providers/activite_game_provider.dart';
import '../../../providers/activites_provider.dart';
import '../../widgets/activite_card.dart';
import '../../widgets/activite_filter_bar.dart';

/// Page affichant la liste des activités éducatives disponibles avec filtres et progression.
class ActivitesListPage extends ConsumerWidget {
  const ActivitesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activitesProvider);
    final notifier = ref.read(activitesProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 24),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: const Text(
          'Activités d\'Éveil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () => notifier.chargerActivites(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.verticalSm,

          // ── Barre de filtres de statut ─────────────────────────────────────
          ActiviteFilterBar(
            selectedFilter: state.filtreStatut,
            onFilterSelected: (statut) => notifier.changerFiltreStatut(statut),
          ),

          AppSpacing.verticalMd,

          // ── Contenu principal (Chargement / Erreur / Liste) ────────────────
          Expanded(
            child: _buildBody(context, ref, state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ActivitesState state,
    ActivitesNotifier notifier,
  ) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: AppPadding.screen,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.danger),
              AppSpacing.verticalMd,
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              AppSpacing.verticalLg,
              ElevatedButton.icon(
                onPressed: () => notifier.chargerActivites(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final activites = state.activitesFiltrees;

    if (activites.isEmpty) {
      return Center(
        child: Padding(
          padding: AppPadding.screen,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              AppSpacing.verticalLg,
              const Text(
                'Aucune activité trouvée',
                style: AppTextStyles.headingSmall,
              ),
              AppSpacing.verticalXs,
              Text(
                'Aucune activité ne correspond au filtre sélectionné.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifier.chargerActivites(),
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: activites.length,
        separatorBuilder: (_, _) => AppSpacing.verticalMd,
        itemBuilder: (context, index) {
          final activite = activites[index];
          return ActiviteCard(
            activite: activite,
            onTap: () => _lancerActivite(context, ref, activite),
          );
        },
      ),
    );
  }

  void _lancerActivite(BuildContext context, WidgetRef ref, Activite activite) {
    ref.read(activiteGameProvider.notifier).demarrerActivite(activite);
    context.push(AppRoutes.activitesPlay);
  }
}
