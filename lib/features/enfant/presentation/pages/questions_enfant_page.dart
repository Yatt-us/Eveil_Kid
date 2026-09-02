import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';
import 'package:eveilkid/features/activites/models/activity.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/duolingo_association_widget.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/duolingo_feedback_bottom_bar.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/duolingo_option_tile.dart';
import 'package:eveilkid/features/enfant/presentation/widgets/duolingo_ordered_association_widget.dart';
import 'package:eveilkid/features/enfant/providers/child_mode_provider.dart';
import 'package:eveilkid/features/enfant/providers/enfant_providers.dart';
import 'package:eveilkid/features/questions/enums/question_type.enum.dart';
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
  int _score = 0;

  // État de sélection pour Choix Multiple et Vrai/Faux
  String? _selectedOptionId;

  // État pour Association Ordonnée (Classement)
  List<String> _orderedOptionIds = [];

  // État pour Association de paires
  bool _isAssociationCompleted = false;

  // États de validation
  bool _isAnswered = false;
  bool _isCurrentCorrect = false;
  String? _correctExplanation;

  void _resetCurrentQuestionState() {
    setState(() {
      _selectedOptionId = null;
      _orderedOptionIds = [];
      _isAssociationCompleted = false;
      _isAnswered = false;
      _isCurrentCorrect = false;
      _correctExplanation = null;
    });
  }

  List<OptionQuestion> _getSafeOptions(Question question) {
    if (question.options.isNotEmpty) {
      return question.options;
    }
    if (question.type == QuestionType.vraiFaux) {
      return const [
        OptionQuestion(id: 'opt_vrai', texte: 'Vrai'),
        OptionQuestion(id: 'opt_faux', texte: 'Faux'),
      ];
    }
    return const [
      OptionQuestion(id: 'opt_1', texte: 'Option A'),
      OptionQuestion(id: 'opt_2', texte: 'Option B'),
    ];
  }

  bool _isReadyToVerify(Question question) {
    if (_isAnswered) return false;

    switch (question.type) {
      case QuestionType.choixMultiple:
      case QuestionType.vraiFaux:
        return _selectedOptionId != null && _selectedOptionId!.isNotEmpty;

      case QuestionType.classement:
        final options = _getSafeOptions(question);
        return _orderedOptionIds.length == options.length && options.isNotEmpty;

      case QuestionType.association:
        return _isAssociationCompleted;
    }
  }

  void _verifyAnswer(Question question) {
    if (_isAnswered) return;

    final options = _getSafeOptions(question);
    bool isCorrect = false;
    String? explanation;

    switch (question.type) {
      case QuestionType.choixMultiple:
      case QuestionType.vraiFaux:
        isCorrect = _selectedOptionId == question.idReponseCorrecte;
        if (!isCorrect) {
          final correctOpt = options.cast<OptionQuestion?>().firstWhere(
                (o) => o?.id == question.idReponseCorrecte,
                orElse: () => null,
              );
          explanation = correctOpt?.texte ?? question.idReponseCorrecte;
        }
        break;

      case QuestionType.classement:
        final expectedIds = options.map((o) => o.id).toList();
        isCorrect = true;
        for (int i = 0; i < expectedIds.length; i++) {
          if (i >= _orderedOptionIds.length || _orderedOptionIds[i] != expectedIds[i]) {
            isCorrect = false;
            break;
          }
        }
        if (!isCorrect) {
          explanation = options.map((o) => o.texte).join(' ➔ ');
        }
        break;

      case QuestionType.association:
        isCorrect = _isAssociationCompleted;
        if (!isCorrect) {
          explanation = 'Toutes les paires doivent être reliées';
        }
        break;
    }

    setState(() {
      _isAnswered = true;
      _isCurrentCorrect = isCorrect;
      _correctExplanation = explanation;
      if (isCorrect) {
        _score++;
      }
    });
  }

  void _skipQuestion(Question question) {
    if (_isAnswered) return;
    final options = _getSafeOptions(question);
    String? explanation;

    switch (question.type) {
      case QuestionType.choixMultiple:
      case QuestionType.vraiFaux:
        final correctOpt = options.cast<OptionQuestion?>().firstWhere(
              (o) => o?.id == question.idReponseCorrecte,
              orElse: () => null,
            );
        explanation = correctOpt?.texte;
        break;
      case QuestionType.classement:
        explanation = options.map((o) => o.texte).join(' ➔ ');
        break;
      case QuestionType.association:
        explanation = 'Paires à associer';
        break;
    }

    setState(() {
      _isAnswered = true;
      _isCurrentCorrect = false;
      _correctExplanation = explanation;
    });
  }

  void _nextStep(List<Question> questions) {
    if (_currentQuestionIndex + 1 < questions.length) {
      setState(() {
        _currentQuestionIndex++;
      });
      _resetCurrentQuestionState();
    } else {
      _finishQuiz(questions);
    }
  }

  Future<void> _finishQuiz(List<Question> questions) async {
    final totalCount = questions.isNotEmpty ? questions.length : 1;
    final basePoints = widget.activite.points > 0 ? widget.activite.points : 20;
    final pointsGagnes = _score > 0
        ? ((_score / totalCount) * basePoints).round().clamp(5, basePoints)
        : 0;
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
      // Permettre l'affichage de la victoire même en cas d'erreur de cache
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
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: KidTheme.primaryGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      size: 44,
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
                    'Tu as réussi $_score sur $totalQuestions défis avec brio !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          size: 20,
                          color: Color(0xFFD97706),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '+$pointsGagnes points gagnés',
                          style: const TextStyle(
                            fontSize: 14,
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
                              _score = 0;
                            });
                            _resetCurrentQuestionState();
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
    return KidThemeScope(
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          if (widget.questionsOverride != null) {
            return _buildScaffoldContent(widget.questionsOverride!, theme, isDark);
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
            data: (questions) => _buildScaffoldContent(questions, theme, isDark),
          );
        },
      ),
    );
  }

  Widget _buildScaffoldContent(List<Question> questions, ThemeData theme, bool isDark) {
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
            description: 'Cette activité ne contient pas encore d\'exercices interactifs.',
            actionText: 'Retour',
            onActionPressed: () => Navigator.pop(context),
          ),
        ),
      );
    }

    final currentQuestion = questions[_currentQuestionIndex.clamp(0, questions.length - 1)];
    final isLast = _currentQuestionIndex == questions.length - 1;
    final isReady = _isReadyToVerify(currentQuestion);
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12);

    final String questionText = currentQuestion.enonce.trim().isNotEmpty
        ? currentQuestion.enonce.trim()
        : widget.activite.titre;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: DuolingoFeedbackBottomBar(
        isAnswered: _isAnswered,
        isCorrect: _isCurrentCorrect,
        isReadyToVerify: isReady,
        isLastStep: isLast,
        correctAnswerText: _correctExplanation,
        onVerify: () => _verifyAnswer(currentQuestion),
        onNextStep: () => _nextStep(questions),
        onSkip: () => _skipQuestion(currentQuestion),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  // ── 1. BARRE SUPÉRIEURE (FERMER, TITRE, COMPTEUR) ──
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

                  const SizedBox(height: 14),

                  // ── 2. BARRE DE PROGRESSION DUOLINGO ──
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentQuestionIndex + 1) / questions.length,
                      minHeight: 8,
                      backgroundColor: KidTheme.primaryGreen.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        KidTheme.primaryGreen,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── 3. CORPS DU DÉFI & INTERACTION ──
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          // Carte Énoncé avec illustration
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark
                                    ? theme.dividerColor.withValues(alpha: 0.25)
                                    : KidTheme.primaryGreen.withValues(alpha: 0.3),
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
                                      height: 160,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                Text(
                                  questionText,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.onSurface,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Rendu spécifique selon le modèle de question
                          _buildQuestionBody(currentQuestion),
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

  Widget _buildQuestionBody(Question question) {
    final options = _getSafeOptions(question);

    switch (question.type) {
      case QuestionType.classement:
        return DuolingoOrderedAssociationWidget(
          allOptions: options,
          currentOrderedIds: _orderedOptionIds,
          correctOrderedIds: options.map((o) => o.id).toList(),
          isAnswered: _isAnswered,
          onOrderChanged: (newOrder) {
            setState(() {
              _orderedOptionIds = newOrder;
            });
          },
        );

      case QuestionType.association:
        return DuolingoAssociationWidget(
          options: options,
          isAnswered: _isAnswered,
          onCompletionChanged: (isCompleted) {
            setState(() {
              _isAssociationCompleted = isCompleted;
            });
          },
        );

      case QuestionType.choixMultiple:
      case QuestionType.vraiFaux:
        return Column(
          children: options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _selectedOptionId == option.id;
            final isCorrectOption = option.id == question.idReponseCorrecte;

            DuolingoTileState tileState = DuolingoTileState.neutral;
            if (_isAnswered) {
              if (isCorrectOption) {
                tileState = DuolingoTileState.correct;
              } else if (isSelected && !isCorrectOption) {
                tileState = DuolingoTileState.incorrect;
              } else {
                tileState = DuolingoTileState.disabled;
              }
            } else if (isSelected) {
              tileState = DuolingoTileState.selected;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DuolingoOptionTile(
                text: option.texte,
                badgeText: question.type == QuestionType.vraiFaux
                    ? null
                    : String.fromCharCode(65 + index),
                badgeIcon: question.type == QuestionType.vraiFaux
                    ? (option.id == 'opt_vrai' || option.texte.toLowerCase() == 'vrai'
                        ? Icons.check_circle_outline_rounded
                        : Icons.cancel_outlined)
                    : null,
                imageUrl: option.imageUrl,
                state: tileState,
                onTap: _isAnswered
                    ? null
                    : () {
                        setState(() {
                          _selectedOptionId = option.id;
                        });
                      },
              ),
            );
          }).toList(),
        );
    }
  }
}
