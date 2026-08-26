import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/activites/providers/admin/activity_provider.dart';
import 'package:eveilkid/features/questions/models/question_model.dart';
import 'package:eveilkid/features/questions/options_questions/option_model.dart';
import 'package:eveilkid/features/questions/providers/question_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


class QuestionDetailScreen extends ConsumerStatefulWidget {
  final String activityId;
  final String questionId;

  const QuestionDetailScreen({
    super.key,
    required this.activityId,
    required this.questionId,
  });

  @override
  ConsumerState<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends ConsumerState<QuestionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(activiteByIdProvider(widget.activityId));
    
   
    final questionAsync = ref.watch(
      questionByIdProvider(
        (activiteId: widget.activityId, questionId: widget.questionId)
      )
    );
    return Scaffold(
      appBar: AppBar(
        title: activityAsync.when(
          loading: () => const Text('Chargement...'),
          error: (_, _) => const Text('Détail question'),
          data: (activity) => Text(activity?.titre ?? 'Détail question'),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: const Color.fromARGB(255, 43, 42, 42),
        centerTitle: true,
        
      ),
      body: questionAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement de la question...'),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
              const SizedBox(height: 16),
              Text(
                'Erreur: $err',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(
                    questionByIdProvider(
                      (activiteId: widget.activityId, questionId: widget.questionId),
                    ),
                  );
                },
                child: const Text('Réessayer'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
        data: (question) {
          if (question == null) {
            return _buildNotFoundWidget();
          }
          return _buildDetailContent(question);
        },
      ),
    );
  }

  Widget _buildNotFoundWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.question_mark, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Question non trouvée',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'ID: ${widget.questionId}',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent(Question question) {
  return SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                 Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.20),
                blurRadius: 15,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.quiz_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      'Détail de la question',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                question.enonce,
                style: const TextStyle(
                  color: Color.fromARGB(255, 65, 65, 65),
                  fontSize: 20,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                icon: question.typeIcon,
                title: 'Type',
                value: question.typeLabel,
                iconColor: AppColors.primary,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildInfoCard(
                icon: Icons.star_rounded,
                title: 'Points',
                value: '${question.points} pts',
                iconColor: Colors.orange,
              ),
            ),
          ],
        ),

        
        if (question.imageUrl != null &&
            question.imageUrl!.isNotEmpty) ...[
          const SizedBox(height: 18),

          _buildSectionTitle(
            icon: Icons.image_outlined,
            title: 'Illustration',
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                question.imageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Container(
                    height: 220,
                    color: Colors.grey.shade100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 45,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Impossible de charger l’image',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],

        if (question.options.isNotEmpty) ...[
          const SizedBox(height: 24),

          _buildSectionTitle(
            icon: Icons.list_alt_rounded,
            title: 'Réponses possibles',
          ),

          const SizedBox(height: 6),

          Text(
            'La réponse correcte est indiquée ci-dessous.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 14),

          ...question.options.asMap().entries.map(
            (entry) => _buildOptionItem(
              entry.value,
              question.idReponseCorrecte,
              entry.key,
            ),
          ),
        ],

      
        const SizedBox(height: 28),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push(
                  '/admin/activites/${widget.activityId}/questions/edit/${widget.questionId}',
                ),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 19,
                ),
                label: const Text(
                  'Modifier',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _confirmDelete(question),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 19,
                ),
                label: const Text(
                  'Supprimer',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(
                    color: AppColors.danger.withValues(alpha: 0.6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildInfoCard({
  required IconData icon,
  required String title,
  required String value,
  required Color iconColor,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildSectionTitle({
  required IconData icon,
  required String title,
}) {
  return Row(
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 19,
        ),
      ),

      const SizedBox(width: 10),

      Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}
  Widget _buildOptionItem(
  OptionQuestion option,
  String correctId,
  int index,
) {
  final isCorrect = option.id == correctId;

  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isCorrect
          ? AppColors.childPrimary.withValues(alpha: 0.08)
          : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: isCorrect
            ? AppColors.childPrimary
            : Colors.grey.shade200,
        width: isCorrect ? 1.5 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
      
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isCorrect
                ? AppColors.childPrimary
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            String.fromCharCode(65 + index),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isCorrect
                  ? Colors.white
                  : Colors.grey.shade700,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Texte
        Expanded(
          child: Text(
            option.texte,
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              fontWeight: isCorrect
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: isCorrect
                  ? AppColors.childPrimary
                  : Colors.grey.shade800,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Indicateur réponse correcte
        if (isCorrect)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.childPrimary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  'Correcte',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

  void _confirmDelete(Question question) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer la question'),
        content: Text('Supprimer : "${question.enonce}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final notifier = ref.read(questionNotifierProvider.notifier);
                await notifier.archiveQuestion(question.id!);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Question supprimée avec succès'),
                    backgroundColor: AppColors.childPrimary,
                  ),
                );
                Navigator.pop(context, true);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}