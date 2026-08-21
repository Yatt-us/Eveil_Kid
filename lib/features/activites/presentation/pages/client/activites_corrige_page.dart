import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/AppRadius.dart';
import '../../../../../core/constants/AppSpacing.dart';
import '../../../../../core/constants/AppTextStyles.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../models/question.dart';
import '../../../providers/activite_game_provider.dart';

/// Page affichant le corrigé détaillé des questions avec comparaison des réponses.
class ActivitesCorrigePage extends ConsumerWidget {
  const ActivitesCorrigePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(activiteGameProvider);
    final gameNotifier = ref.read(activiteGameProvider.notifier);

    final activite = gameState.activiteEnCours;
    final questions = activite?.questions ?? [];
    final bonnesReponses = gameState.nombreBonnesReponses;
    final totalQuestions = questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Corrigé de l\'Activité',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            AppSpacing.verticalSm,

            // ── Bandeau récapitulatif du score ──────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.assignment_turned_in_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Score final : $bonnesReponses / $totalQuestions',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.verticalMd,

            // ── Liste des questions avec corrigé ─────────────────────────────
            Expanded(
              child: questions.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun détail de question disponible.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: questions.length,
                      separatorBuilder: (_, _) => AppSpacing.verticalMd,
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        final estCorrecte = gameState.estReponseCorrecte(question);
                        final reponseJoueurId = gameState.reponsesJoueur[question.id];

                        final reponseJoueur = question.options.firstWhere(
                          (opt) => opt.id == reponseJoueurId,
                          orElse: () => const OptionQuestion(
                            id: '',
                            texte: 'Non répondue',
                          ),
                        );

                        final reponseCorrecte = question.options.firstWhere(
                          (opt) => opt.id == question.idReponseCorrecte,
                          orElse: () => reponseJoueur,
                        );

                        return _buildCarteQuestionCorrige(
                          index: index + 1,
                          question: question,
                          reponseJoueur: reponseJoueur,
                          reponseCorrecte: reponseCorrecte,
                          estCorrecte: estCorrecte,
                        );
                      },
                    ),
            ),

            // ── Bouton Terminer ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
                onPressed: () {
                  gameNotifier.reinitialiserSession();
                  context.go(AppRoutes.activites);
                },
                child: const Text(
                  'Terminer & Retourner aux activités',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            AppSpacing.verticalMd,
          ],
        ),
      ),
    );
  }

  Widget _buildCarteQuestionCorrige({
    required int index,
    required Question question,
    required OptionQuestion reponseJoueur,
    required OptionQuestion reponseCorrecte,
    required bool estCorrecte,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: estCorrecte ? const Color(0xFF00A859) : AppColors.danger,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (estCorrecte ? const Color(0xFF00A859) : AppColors.danger).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : numéro & badge correct / incorrect
          Row(
            children: [
              Text(
                'Question $index',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: estCorrecte
                      ? const Color(0xFFE8F8F5)
                      : const Color(0xFFFFECEC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      estCorrecte ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: estCorrecte ? const Color(0xFF00A859) : AppColors.danger,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      estCorrecte ? 'Correct' : 'Erreur',
                      style: TextStyle(
                        color: estCorrecte ? const Color(0xFF00A859) : AppColors.danger,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.verticalSm,

          // Énoncé
          Text(
            question.enonce,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          AppSpacing.verticalMd,

          // Réponse de l'enfant
          _buildBoiteReponse(
            label: estCorrecte ? 'Ta réponse' : 'Ta réponse (incorrecte)',
            option: reponseJoueur,
            estCorrecte: estCorrecte,
          ),

          // Bonne réponse si erreur
          if (!estCorrecte) ...[
            const SizedBox(height: 8),
            _buildBoiteReponse(
              label: 'Bonne réponse attendue',
              option: reponseCorrecte,
              estCorrecte: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBoiteReponse({
    required String label,
    required OptionQuestion option,
    required bool estCorrecte,
  }) {
    final borderCol = estCorrecte ? const Color(0xFF00A859) : AppColors.danger;
    final bgCol = estCorrecte ? const Color(0xFFE8F8F5) : const Color(0xFFFFECEC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: borderCol,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bgCol,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderCol.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              if (option.imagePath?.isNotEmpty == true) ...[
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Image.asset(
                    option.imagePath!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(Icons.image, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  option.texte,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
