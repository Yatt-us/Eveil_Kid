import 'package:flutter/material.dart';

import '../../../models/client/question_quiz.dart';

class CorrigesScreen extends StatelessWidget {
  final List<QuestionQuiz> questions;
  final Map<String, String> reponsesUtilisateur;

  const CorrigesScreen({
    super.key,
    required this.questions,
    required this.reponsesUtilisateur,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.purple),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final reponseUser = reponsesUtilisateur[question.id];
                  final bool estCorrecte = reponseUser == question.reponseCorrecteId;

                  // Récupération du libellé de la bonne réponse
                  final bonneOption = question.options.firstWhere(
                    (opt) => opt.id == question.reponseCorrecteId,
                    orElse: () => OptionQuiz(id: '', libelle: '-'),
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: estCorrecte ? const Color(0xFFF1F9F3) : const Color(0xFFEFF8F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                '${index + 1}. ${question.intitule}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: estCorrecte ? const Color(0xFF2EA650) : Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                estCorrecte ? Icons.check : Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Affiche le bouton vert du choix correct
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: estCorrecte ? const Color(0xFF2EA650) : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              bonneOption.libelle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bouton "Terminer" en bas
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
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
                    // Retourne au premier écran de la pile (Liste des activités)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    'Terminer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}