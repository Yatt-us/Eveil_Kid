import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

import '../models/question_model.dart';
import '../providers/activitees_provider.dart';
import 'activitees_list_page.dart';

class ActiviteesCorrigePage extends StatelessWidget {
  const ActiviteesCorrigePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ActiviteesProvider>();
    final activite = provider.activiteesEnCours;
    final questions = activite?.questions ?? [];
    final bonnesReponses = provider.nombreBonnesReponses;
    final totalQuestions = questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Corrigé',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 8.0),

            // --- BANDEAU EN-TÊTE : SCORE GLOBAL ---
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F5),
                borderRadius: BorderRadius.circular(999.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.assignment_turned_in_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Score : $bonnesReponses/$totalQuestions',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16.0),

            // --- LISTE DES QUESTIONS DU CORRIGÉ ---
            Expanded(
              child: questions.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun détail disponible',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: questions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16.0),
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        final estCorrecte = provider.estReponseCorrecte(question);
                        final reponseJoueurId = provider.reponsesJoueur[question.id];

                        final reponseJoueur = question.options.firstWhere(
                          (opt) => opt.id == reponseJoueurId,
                          orElse: () => OptionModel(
                            id: '',
                            texte: 'Non répondue',
                            cheminImage: '',
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

            const SizedBox(height: 16.0),

            // --- BOUTON VIOLET : TERMINER ---
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999.0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const ActiviteesListPage(),
                    ),
                    (route) => false,
                  );
                },
                child: Text(
                  'Terminer',
                  style: AppTextStyles.button.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  // --- CARTE DE CORRIGÉ D'UNE QUESTION ---
  Widget _buildCarteQuestionCorrige({
    required int index,
    required QuestionModel question,
    required OptionModel reponseJoueur,
    required OptionModel reponseCorrecte,
    required bool estCorrecte,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: estCorrecte ? const Color(0xFF00A859) : AppColors.error,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Question $index',
                style: AppTextStyles.caption.copyWith(
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
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      estCorrecte ? Icons.check_circle : Icons.cancel,
                      color: estCorrecte ? const Color(0xFF00A859) : AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      estCorrecte ? 'Correct' : 'Incorrect',
                      style: AppTextStyles.caption.copyWith(
                        color: estCorrecte ? const Color(0xFF00A859) : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8.0),

          Text(
            question.texteQuestion,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 16.0),

          _buildBoiteOption(
            titreLegende: estCorrecte ? 'Ta réponse' : 'Ta réponse (Erreur)',
            option: reponseJoueur,
            estCorrecte: estCorrecte,
          ),

          if (!estCorrecte) ...[
            const SizedBox(height: 8.0),
            _buildBoiteOption(
              titreLegende: 'Bonne réponse',
              option: reponseCorrecte,
              estCorrecte: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBoiteOption({
    required String titreLegende,
    required OptionModel option,
    required bool estCorrecte,
  }) {
    final couleurBordure = estCorrecte ? const Color(0xFF00A859) : AppColors.error;
    final couleurFond = estCorrecte ? const Color(0xFFE8F8F5) : const Color(0xFFFFECEC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titreLegende,
          style: AppTextStyles.caption.copyWith(
            color: couleurBordure,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4.0),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: couleurFond,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: couleurBordure.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              if (option.cheminImage.isNotEmpty) ...[
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Image.asset(
                    option.cheminImage,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 20),
                  ),
                ),
                const SizedBox(width: 8.0),
              ],
              Expanded(
                child: Text(
                  option.texte,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
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