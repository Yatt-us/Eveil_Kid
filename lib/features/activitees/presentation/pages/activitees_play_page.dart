import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

import '../models/activitees_enums.dart';
import '../models/question_model.dart';
import '../providers/activitees_provider.dart';
import 'activitees_resultat_page.dart';

class ActiviteesPlayPage extends StatelessWidget {
  const ActiviteesPlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ActiviteesProvider>(context);
    final question = provider.questionActuelle;
    final activite = provider.activiteesEnCours;

    if (activite == null || question == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'Aucune question disponible',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final int indexActuel = provider.indexQuestionActuelle + 1;
    final int totalQuestions = activite.questions.isNotEmpty 
        ? activite.questions.length 
        : activite.totalQuestions;
    final double progressionRatio = (indexActuel / totalQuestions).clamp(0.0, 1.0);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Réinitialise la session quand l'utilisateur quitte l'activité
          provider.reinitialiserSession();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 28),
            onPressed: () {
              provider.reinitialiserSession();
              Navigator.pop(context);
            },
          ),
          title: Column(
            children: [
              Text(
                'Question $indexActuel/$totalQuestions',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              AppSpacing.verticalXSmall,
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.circular),
                child: SizedBox(
                  width: 140,
                  height: 8,
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
            Padding(
              padding: const EdgeInsets.only(right: AppPadding.small),
              child: IconButton(
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
                  // Lecture de l'audio de la question via le provider si configuré
                  if (question.cheminAudio != null) {
                    provider.jouerAudioQuestion(question.cheminAudio!);
                  }
                },
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppPadding.medium),
          child: Column(
            crossAlignment: CrossAlignment.start,
            children: [
              AppSpacing.verticalMedium,

              Text(
                question.texteQuestion,
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),

              AppSpacing.verticalLarge,

              Expanded(
                child: question.typeAffichage == TypeAffichageQuestion.grille
                    ? _buildGrilleOptions(question, provider)
                    : _buildListeOptions(question, provider),
              ),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: provider.optionSelectionneeId != null
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.circular),
                    ),
                  ),
                  onPressed: provider.optionSelectionneeId == null
                      ? null
                      : () => _handleValidation(context, provider),
                  child: Text(
                    'Valider',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              AppSpacing.verticalSmall,
            ],
          ),
        ),
      ),
    );
  }

  // --- LOGIQUE DE VALIDATION ET NAVIGATION ---
  void _handleValidation(BuildContext context, ActiviteesProvider provider) {
    final estFini = provider.validerReponse();

    if (estFini) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ActiviteesResultatPage(),
        ),
      );
    }
  }

  // --- MODE LISTE ---
  Widget _buildListeOptions(QuestionModel question, ActiviteesProvider provider) {
    return ListView.separated(
      itemCount: question.options.length,
      separatorBuilder: (_, __) => AppSpacing.verticalMedium,
      itemBuilder: (context, index) {
        final option = question.options[index];
        final estSelectionnee = provider.optionSelectionneeId == option.id;

        return GestureDetector(
          onTap: () => provider.selectionnerOption(option.id),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.medium,
              vertical: AppPadding.small,
            ),
            decoration: BoxDecoration(
              color: estSelectionnee ? const Color(0xFFE8F8F5) : const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(
                color: estSelectionnee ? const Color(0xFF00A859) : const Color(0xFFEEEEEE),
                width: estSelectionnee ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset(
                    option.cheminImage,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 30),
                  ),
                ),
                AppSpacing.horizontalMedium,
                Expanded(
                  child: Text(
                    option.texte,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (estSelectionnee)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF00A859),
                    size: 26,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- MODE GRILLE 2x2 ---
  Widget _buildGrilleOptions(QuestionModel question, ActiviteesProvider provider) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        final option = question.options[index];
        final estSelectionnee = provider.optionSelectionneeId == option.id;

        return GestureDetector(
          onTap: () => provider.selectionnerOption(option.id),
          child: Container(
            padding: const EdgeInsets.all(AppPadding.medium),
            decoration: BoxDecoration(
              color: estSelectionnee ? const Color(0xFFE8F8F5) : const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(
                color: estSelectionnee ? const Color(0xFF00A859) : const Color(0xFFEEEEEE),
                width: estSelectionnee ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          option.cheminImage,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 40),
                        ),
                      ),
                    ),
                    AppSpacing.verticalSmall,
                    Text(
                      option.texte,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                if (estSelectionnee)
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(
                      Icons.check_circle,
                      color: Color(0xFF00A859),
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}