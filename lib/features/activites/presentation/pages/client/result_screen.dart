import 'package:flutter/material.dart';
import '../../../models/activity.dart';
import '../../../models/client/question_quiz.dart';
import 'corriges_screen.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatelessWidget {
  final Activite activite;
  final List<QuestionQuiz> questions;
  final Map<String, String> reponsesUtilisateur;
  final int score;
  final int bonnesReponses;
  final int mauvaisesReponses;
  final int pointsGagnes;

  const ResultScreen({
    super.key,
    required this.activite,
    required this.questions,
    required this.reponsesUtilisateur,
    required this.score,
    required this.bonnesReponses,
    required this.mauvaisesReponses,
    required this.pointsGagnes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF38A155),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Étoile de célébration
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 130,
                      color: Colors.amber.shade400,
                    ),
                    Positioned(
                      top: 45,
                      child: Row(
                        children: const [
                          Icon(Icons.circle, size: 8, color: Colors.black87),
                          SizedBox(width: 14),
                          Icon(Icons.circle, size: 8, color: Colors.black87),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Félicitations !',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Activité terminée',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),

              const Spacer(flex: 1),

              // Carte des métriques
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            title: 'Score',
                            value: '$score',
                            subValue: '/${questions.length * 10}',
                            valueColor: Colors.black,
                          ),
                        ),
                        Container(width: 1, height: 60, color: Colors.grey.shade200),
                        Expanded(
                          child: _buildMetricTile(
                            title: 'Points gagnés',
                            value: '+$pointsGagnes',
                            valueColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 32, color: Colors.grey.shade200),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            title: 'Bonnes réponses',
                            value: '$bonnesReponses',
                            valueColor: const Color(0xFF2EA650),
                          ),
                        ),
                        Container(width: 1, height: 60, color: Colors.grey.shade200),
                        Expanded(
                          child: _buildMetricTile(
                            title: 'Mauvaises réponses',
                            value: '$mauvaisesReponses',
                            valueColor: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Bouton "Voir le corrigé"
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2EA650),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CorrigesScreen(
                          questions: questions,
                          reponsesUtilisateur: reponsesUtilisateur,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Voir le corrigé',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Bouton "Recommencer"
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(activite: activite),
                    ),
                  );
                },
                child: const Text(
                  'Recommencer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    String? subValue,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: valueColor),
            ),
            if (subValue != null)
              Text(
                subValue,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
          ],
        ),
      ],
    );
  }
}