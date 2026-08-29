import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';
import 'package:eveilkid/features/activites/models/activity.dart';
import 'package:eveilkid/features/enfant/providers/child_mode_provider.dart';
import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';
import 'package:eveilkid/features/questions/models/question_model.dart';
import 'package:eveilkid/features/questions/options_questions/option_model.dart';
import 'package:eveilkid/features/questions/providers/question_provider.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

class QuestionsEnfantPage extends ConsumerStatefulWidget {
  final Activite activite;
  final List<Question>? questionsOverride;

  const QuestionsEnfantPage({
    super.key,
    required this.activite,
    this.questionsOverride,
  });

  @override
  ConsumerState<QuestionsEnfantPage> createState() => _QuestionsEnfantPageState();
}

class _QuestionsEnfantPageState extends ConsumerState<QuestionsEnfantPage> {
  int _currentQuestionIndex = 0;
  String? _selectedOptionId;
  bool _answered = false;
  int _score = 0;

  void _chooseOption(OptionQuestion option, Question currentQuestion) {
    if (_answered) return;

    final isCorrect = option.id == currentQuestion.idReponseCorrecte;

    setState(() {
      _selectedOptionId = option.id;
      _answered = true;
      if (isCorrect) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) return;

      final questions = widget.questionsOverride ??
          ref.read(questionsByActiviteProvider(widget.activite.id ?? '')).value ??
          [];

      if (_currentQuestionIndex + 1 < questions.length) {
        setState(() {
          _currentQuestionIndex++;
          _selectedOptionId = null;
          _answered = false;
        });
      } else {
        _finishQuiz(questions);
      }
    });
  }

  Future<void> _finishQuiz(List<Question> questions) async {
    final pointsGagnes = (_score * (widget.activite.points / (questions.isNotEmpty ? questions.length : 1))).round();
    final childMode = ref.read(childModeProvider);
    final enfant = childMode.activeChild ??
        ref.read(enfantNotifierProvider).enfantSelectionne;

    try {
      if (enfant != null) {
        final currentResults = List<Map<String, dynamic>>.from(
          enfant.resultatsActivite.map((e) => Map<String, dynamic>.from(e as Map)),
        );

        final existingIndex = currentResults.indexWhere(
          (r) => r['activiteId'] == widget.activite.id,
        );

        final newResult = {
          'activiteId': widget.activite.id,
          'activiteTitre': widget.activite.titre,
          'score': _score,
          'totalQuestions': questions.length,
          'pointsGagnes': pointsGagnes,
          'date': DateTime.now().toIso8601String(),
          'termine': true,
          'estReussi': _score >= (questions.length / 2),
        };

        if (existingIndex != -1) {
          currentResults[existingIndex] = newResult;
        } else {
          currentResults.add(newResult);
        }

        final updatedEnfant = enfant.copyWith(
          resultatsActivite: currentResults,
          dateModification: DateTime.now(),
        );

        await ref.read(enfantNotifierProvider.notifier).modifierEnfant(updatedEnfant);
        ref.read(childModeProvider.notifier).switchChild(updatedEnfant);
      }
    } catch (_) {
      // Permettre l'affichage du dialogue même si la sauvegarde échoue
    }

    if (!mounted) return;
    _showSuccessDialog(questions.length, pointsGagnes);
  }

  void _showSuccessDialog(int totalQuestions, int pointsGagnes) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: KidTheme.primaryGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      size: 40,
                      color: KidTheme.primaryGreenDark,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Défi Terminé !',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu as obtenu $_score sur $totalQuestions bonnes réponses.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF78350F).withValues(alpha: 0.4)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: Color(0xFFD97706),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '+$pointsGagnes points gagnés',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            setState(() {
                              _currentQuestionIndex = 0;
                              _selectedOptionId = null;
                              _answered = false;
                              _score = 0;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Rejouer'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KidTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Terminer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.questionsOverride != null) {
      return _buildContent(widget.questionsOverride!, theme, isDark);
    }

    final questionsAsync = ref.watch(
      questionsByActiviteProvider(widget.activite.id ?? ''),
    );

    return questionsAsync.when(
      loading: () => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: AppErrorState(
            title: 'Erreur lors du chargement des questions',
            message: '$err',
            onRetry: () => ref.invalidate(
              questionsByActiviteProvider(widget.activite.id ?? ''),
            ),
          ),
        ),
      ),
      data: (questions) => _buildContent(questions, theme, isDark),
    );
  }

  Widget _buildContent(List<Question> questions, ThemeData theme, bool isDark) {
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: AppEmptyState(
            icon: Icons.quiz_outlined,
            title: 'Aucune question configurée',
            description: 'Cette activité ne contient pas encore de quiz interactif.',
            actionText: 'Retour',
            onActionPressed: () => Navigator.pop(context),
          ),
        ),
      );
    }

    final currentQuestion = questions[_currentQuestionIndex.clamp(0, questions.length - 1)];
    final options = currentQuestion.options;
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                children: [
                  // ── BARRE SUPÉRIEURE ──
                  Row(
                    children: [
                      Material(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: dividerColor),
                            ),
                            child: const Icon(Icons.close_rounded, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.activite.titre,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark
                              ? KidTheme.primaryGreen.withValues(alpha: 0.25)
                              : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: KidTheme.primaryGreen.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${_currentQuestionIndex + 1} / ${questions.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: KidTheme.primaryGreenDark,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── BARRE DE PROGRESSION ──
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentQuestionIndex + 1) / questions.length,
                      minHeight: 7,
                      backgroundColor: KidTheme.primaryGreen.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        KidTheme.primaryGreen,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── ÉNONCÉ & ILLUSTRATION ──
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: KidTheme.primaryGreen.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.2 : 0.04,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                if (currentQuestion.imageUrl != null &&
                                    currentQuestion.imageUrl!.isNotEmpty) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      currentQuestion.imageUrl!,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                ],
                                Text(
                                  currentQuestion.enonce,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.onSurface,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── LISTE DES OPTIONS ──
                          ...options.asMap().entries.map((entry) {
                            final index = entry.key;
                            final option = entry.value;
                            final isSelected = _selectedOptionId == option.id;
                            final isCorrect = option.id == currentQuestion.idReponseCorrecte;

                            Color cardColor = theme.colorScheme.surface;
                            Color borderColor = dividerColor;

                            if (_answered) {
                              if (isCorrect) {
                                cardColor = isDark
                                    ? const Color(0xFF14532D).withValues(alpha: 0.35)
                                    : const Color(0xFFDCFCE7);
                                borderColor = const Color(0xFF16A34A);
                              } else if (isSelected && !isCorrect) {
                                cardColor = isDark
                                    ? const Color(0xFF7F1D1D).withValues(alpha: 0.35)
                                    : const Color(0xFFFEE2E2);
                                borderColor = theme.colorScheme.error;
                              }
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Material(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  onTap: () => _chooseOption(option, currentQuestion),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: borderColor,
                                        width: isSelected || (_answered && isCorrect)
                                            ? 2.0
                                            : 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isCorrect && _answered
                                                ? const Color(0xFF16A34A)
                                                : (isDark
                                                    ? theme.colorScheme.surfaceContainerHighest
                                                    : const Color(0xFFF1F5F9)),
                                          ),
                                          child: Center(
                                            child: Text(
                                              String.fromCharCode(65 + index),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 13,
                                                color: isCorrect && _answered
                                                    ? Colors.white
                                                    : theme.colorScheme.onSurface,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            option.texte,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: isSelected
                                                  ? FontWeight.w800
                                                  : FontWeight.w600,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                        if (_answered && isCorrect)
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            color: Color(0xFF16A34A),
                                            size: 22,
                                          )
                                        else if (_answered && isSelected && !isCorrect)
                                          Icon(
                                            Icons.cancel_rounded,
                                            color: theme.colorScheme.error,
                                            size: 22,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
