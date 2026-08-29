import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/themes/kid_theme.dart';

class QuestionsEnfantPage extends ConsumerStatefulWidget {
  final String titreActivite;
  final List<Map<String, dynamic>> questions;

  const QuestionsEnfantPage({
    super.key,
    this.titreActivite = 'Défi Quiz',
    this.questions = const [
      {
        'question': 'Quel est le cri du lion ? 🦁',
        'options': ['Miaou', 'Rugissement  roar !', 'Coin-coin', 'Meuh'],
        'bonneReponse': 1,
      },
      {
        'question': 'Quelle est la couleur du soleil ? ☀️',
        'options': ['Bleu', 'Vert', 'Jaune', 'Violet'],
        'bonneReponse': 2,
      },
      {
        'question': 'Combien de pattes a le petit chien ? 🐶',
        'options': ['2 pattes', '4 pattes', '6 pattes', '8 pattes'],
        'bonneReponse': 1,
      },
    ],
  });

  @override
  ConsumerState<QuestionsEnfantPage> createState() =>
      _QuestionsEnfantPageState();
}

class _QuestionsEnfantPageState extends ConsumerState<QuestionsEnfantPage> {
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _answered = false;
  int _score = 0;

  void _chooseOption(int index) {
    if (_answered) return;

    final currentQuestion = widget.questions[_currentQuestionIndex];
    final isCorrect = index == currentQuestion['bonneReponse'];

    setState(() {
      _selectedOptionIndex = index;
      _answered = true;
      if (isCorrect) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      if (_currentQuestionIndex + 1 < widget.questions.length) {
        setState(() {
          _currentQuestionIndex++;
          _selectedOptionIndex = null;
          _answered = false;
        });
      } else {
        _showSuccessDialog();
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 12),
                const Text(
                  'Bravo Champion ! 🏆',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF14532D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu as réussi $_score sur ${widget.questions.length} questions !',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+${_score * 10} étoiles gagnées ! ⭐',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: const Text('Super ! 🎈'),
                  ),
                ),
              ],
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
    final currentQ = widget.questions[_currentQuestionIndex];
    final options = (currentQ['options'] as List<dynamic>).cast<String>();
    final correctAnswer = currentQ['bonneReponse'] as int;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              // ── APP BAR ──
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 24),
                  ),
                  Expanded(
                    child: Text(
                      widget.titreActivite,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${_currentQuestionIndex + 1}/${widget.questions.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: KidTheme.primaryGreenDark,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── PROGRESS BAR ──
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / widget.questions.length,
                  minHeight: 8,
                  backgroundColor: KidTheme.primaryGreen.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    KidTheme.primaryGreen,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ── CARTE QUESTION ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: KidTheme.primaryGreen.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.25 : 0.04,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  currentQ['question'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                    height: 1.35,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── OPTIONS DE RÉPONSES ──
              Expanded(
                child: ListView.separated(
                  itemCount: options.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedOptionIndex == index;
                    final isCorrect = index == correctAnswer;

                    Color cardColor = theme.colorScheme.surface;
                    Color borderColor = theme.dividerColor.withValues(alpha: 0.2);

                    if (_answered) {
                      if (isCorrect) {
                        cardColor = const Color(0xFFDCFCE7);
                        borderColor = KidTheme.primaryGreen;
                      } else if (isSelected && !isCorrect) {
                        cardColor = const Color(0xFFFEE2E2);
                        borderColor = Colors.redAccent;
                      }
                    }

                    return Material(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(22),
                      child: InkWell(
                        onTap: () => _chooseOption(index),
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: borderColor,
                              width: isSelected || (_answered && isCorrect)
                                  ? 2.0
                                  : 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: KidTheme.primaryGreen
                                      .withValues(alpha: 0.15),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: KidTheme.primaryGreenDark,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  options[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if (_answered && isCorrect)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: KidTheme.primaryGreen,
                                )
                              else if (_answered && isSelected && !isCorrect)
                                const Icon(
                                  Icons.cancel_rounded,
                                  color: Colors.redAccent,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
