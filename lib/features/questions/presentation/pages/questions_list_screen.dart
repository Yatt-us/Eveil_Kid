import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/activites/providers/admin/activity_provider.dart';
import 'package:eveilkid/features/questions/models/question_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/question_provider.dart';
import '../widgets/question_card.dart';

class QuestionsListScreen extends ConsumerStatefulWidget {
  final String activityId;

  const QuestionsListScreen({super.key, required this.activityId});

  @override
  ConsumerState<QuestionsListScreen> createState() => _QuestionsListScreenState();
}

class _QuestionsListScreenState extends ConsumerState<QuestionsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(questionNotifierProvider.notifier);
      notifier.setActiviteId(widget.activityId);
      notifier.loadQuestions(widget.activityId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(activiteByIdProvider(widget.activityId));
    final questionsAsync = ref.watch(questionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        
        title: activityAsync.when(
          loading: () => const Text('Chargement...'),
          error: (_, __) => const Text('Erreur'),
          data: (activity) => Text(
            activity?.titre ?? 'Questions',
            style: const TextStyle(
              fontSize: 20,
            
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        
      ),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
              const SizedBox(height: 16),
              Text('Erreur: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final notifier = ref.read(questionNotifierProvider.notifier);
                  notifier.loadQuestions(widget.activityId);
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (questions) {
          if (questions.isEmpty) {
            return _buildEmptyState();
          }
          return _buildQuestionList(questions);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.question_mark, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Aucune question',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez une question en appuyant sur le bouton +',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push(
              '/admin/activites/${widget.activityId}/questions/choose-type'
            ),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une question'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionList(List<Question> questions) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              final notifier = ref.read(questionNotifierProvider.notifier);
              await notifier.loadQuestions(widget.activityId);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return QuestionCard(
                  question: question,
                  activityId: widget.activityId,
                  onEdit: () => context.push(
                    '/admin/activites/${widget.activityId}/questions/edit/${question.id}'
                  ),
                  onDelete: () => _confirmDelete(question),
                );
              },
            ),
          ),
        ),
        // ✅ Bouton "Ajouter une question" en bas
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: TextButton(
              onPressed: () => context.push(
                '/admin/activites/${widget.activityId}/questions/choose-type'
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                
                ),
              ),
              child: const Text(
                'Ajouter une question',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
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
            onPressed: () {
              if (Navigator.canPop(dialogContext)) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              if (Navigator.canPop(dialogContext)) {
                Navigator.pop(dialogContext);
              }
              await Future.delayed(const Duration(milliseconds: 100));
              if (!mounted) return;
              try {
                final notifier = ref.read(questionNotifierProvider.notifier);
                await notifier.archiveQuestion(question.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Question supprimée avec succès'),
                      backgroundColor: AppColors.childPrimary,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
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