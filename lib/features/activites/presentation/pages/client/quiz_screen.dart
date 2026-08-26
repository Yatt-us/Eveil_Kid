import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/activity.dart';
import '../../../models/client/question_quiz.dart';
import '../../../providers/client/question.dart';
import 'result_screen.dart'; // Étape suivante

class QuizScreen extends ConsumerStatefulWidget {
  final Activite activite;

  const QuizScreen({super.key, required this.activite});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;
  String? _selectedOptionId;
  int _score = 0;
  int _bonnesReponses = 0;
  int _mauvaisesReponses = 0;

  void _validerReponse(List<QuestionQuiz> questions) {
    if (_selectedOptionId == null) return;

    final currentQuestion = questions[_currentIndex];
    final bool estCorrect = _selectedOptionId == currentQuestion.reponseCorrecteId;

    if (estCorrect) {
      _score += 10;
      _bonnesReponses++;
    } else {
      _mauvaisesReponses++;
    }

    if (_currentIndex < questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionId = null;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            score: _score,
            totalQuestions: questions.length,
            bonnesReponses: _bonnesReponses,
            mauvaisesReponses: _mauvaisesReponses,
            pointsGagnes: _score * 10,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsStreamProvider(widget.activite.id ?? ''));

    return Scaffold(
      backgroundColor: Colors.white,
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: Text(widget.activite.titre)),
              body: const Center(
                child: Text('Aucune question disponible pour cette activité.'),
              ),
            );
          }

          final currentQuestion = questions[_currentIndex];
          final double progress = (_currentIndex + 1) / questions.length;

          return SafeArea(
            child: Column(
              children: [
                // En-tête
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        'Activités ${_currentIndex + 1}/${questions.length}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Barre de progression
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2EA650)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Question + Audio
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          currentQuestion.intitule,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.volume_up_rounded, color: Colors.black87),
                          onPressed: () {
                            // Syntaxe audio si audioUrl n'est pas null
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Grille 2x2 ou Liste d'options
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: currentQuestion.isGrid
                        ? _buildGridOptions(currentQuestion)
                        : _buildListOptions(currentQuestion),
                  ),
                ),

                // Bouton Valider
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2EA650),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 0,
                      ),
                      onPressed: _selectedOptionId != null ? () => _validerReponse(questions) : null,
                      child: const Text(
                        'Valider',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Erreur de chargement Firestore : $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildListOptions(QuestionQuiz question) {
    return ListView.builder(
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        final option = question.options[index];
        final isSelected = _selectedOptionId == option.id;

        return GestureDetector(
          onTap: () => setState(() => _selectedOptionId = option.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE8F5E9) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF2EA650) : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                if (option.imageUrl != null && option.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      option.imageUrl!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => const Icon(Icons.image, size: 40),
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option.libelle,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                if (isSelected)
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF2EA650),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.check, color: Colors.white, size: 18),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridOptions(QuestionQuiz question) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        final option = question.options[index];
        final isSelected = _selectedOptionId == option.id;

        return GestureDetector(
          onTap: () => setState(() => _selectedOptionId = option.id),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE8F5E9) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF2EA650) : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (option.imageUrl != null && option.imageUrl!.isNotEmpty)
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            option.imageUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, err, stack) => const Icon(Icons.image, size: 50),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      option.libelle,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF2EA650),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.check, color: Colors.white, size: 16),
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