import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/AppRadius.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/AppTextStyles.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../enums/activite_enums.dart';
import '../../models/question.dart';
import '../../providers/activite_game_provider.dart';
import '../widgets/quiz_option_tile.dart';

/// Page de gameplay interactif pour dérouler les questions d'une activité.
class ActivitesPlayPage extends ConsumerWidget {
  const ActivitesPlayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(activiteGameProvider);
    final gameNotifier = ref.read(activiteGameProvider.notifier);

    final activite = gameState.activiteEnCours;
    final question = gameState.questionActuelle;

    if (activite == null || question == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.help_outline_rounded, size: 56, color: AppColors.textSecondary),
              AppSpacing.verticalMd,
              const Text(
                'Aucune question en cours',
                style: AppTextStyles.headingSmall,
              ),
              AppSpacing.verticalLg,
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.activites),
                child: const Text('Retour aux activités'),
              ),
            ],
          ),
        ),
      );
    }

    final int indexActuel = gameState.indexQuestionActuelle + 1;
    final int totalQuestions = gameState.totalQuestions;
    final double progressionRatio = gameState.progressionRatio;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          gameNotifier.reinitialiserSession();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 24),
            onPressed: () {
              gameNotifier.reinitialiserSession();
              context.pop();
            },
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Question $indexActuel sur $totalQuestions',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 140,
                  height: 6,
                  child: LinearProgressIndicator(
                    value: progressionRatio,
                    backgroundColor: const Color(0xFFEBEBEB),
                    color: const Color(0xFF00A859),
                  ),
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            if (question.audioPath?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  tooltip: 'Écouter la consigne',
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F3F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lecture audio de la consigne...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Énoncé de la question ────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppRadius.card,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    question.enonce,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      height: 1.35,
                    ),
                  ),
                ),

                AppSpacing.verticalLg,

                // ── Options de réponses (Mode Grille ou Liste) ───────────────
                Expanded(
                  child: question.typeAffichage == TypeAffichageQuestion.grille
                      ? _buildGrilleOptions(question, gameState, gameNotifier)
                      : _buildListeOptions(question, gameState, gameNotifier),
                ),

                AppSpacing.verticalMd,

                // ── Bouton de validation ─────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gameState.optionSelectionneeId != null
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.35),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                    onPressed: gameState.optionSelectionneeId == null
                        ? null
                        : () => _validerReponse(context, gameNotifier),
                    child: const Text(
                      'Valider ma réponse',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _validerReponse(BuildContext context, ActiviteGameNotifier notifier) {
    final estFini = notifier.validerReponse();
    if (estFini) {
      context.pushReplacement(AppRoutes.activitesResultat);
    }
  }

  Widget _buildListeOptions(
    Question question,
    ActiviteGameState state,
    ActiviteGameNotifier notifier,
  ) {
    return ListView.separated(
      itemCount: question.options.length,
      separatorBuilder: (_, _) => AppSpacing.verticalSm,
      itemBuilder: (context, index) {
        final option = question.options[index];
        final isSelected = state.optionSelectionneeId == option.id;

        return QuizOptionTile(
          option: option,
          isSelected: isSelected,
          isGrid: false,
          onTap: () => notifier.selectionnerOption(option.id),
        );
      },
    );
  }

  Widget _buildGrilleOptions(
    Question question,
    ActiviteGameState state,
    ActiviteGameNotifier notifier,
  ) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.95,
      ),
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        final option = question.options[index];
        final isSelected = state.optionSelectionneeId == option.id;

        return QuizOptionTile(
          option: option,
          isSelected: isSelected,
          isGrid: true,
          onTap: () => notifier.selectionnerOption(option.id),
        );
      },
    );
  }
}
