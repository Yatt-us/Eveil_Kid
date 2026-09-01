import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/features/activites/providers/admin/activity_provider.dart';
import 'package:eveilkid/features/questions/models/question_model.dart';
import 'package:eveilkid/features/questions/presentation/widgets/question_card.dart';
import 'package:eveilkid/features/questions/providers/question_provider.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: activityAsync.when(
          loading: () => const Text('Questions...'),
          error: (_, _) => const Text('Questions'),
          data: (activity) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                activity?.titre ?? 'Questions',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Quiz & Activité',
                style: TextStyle(
                  fontSize: 11.5,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser',
            onPressed: () {
              final notifier = ref.read(questionNotifierProvider.notifier);
              notifier.setActiviteId(widget.activityId);
              notifier.loadQuestions(widget.activityId);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ajouter une question'),
        onPressed: () async {
          final result = await context.push(
            '/admin/activites/${widget.activityId}/questions/choose-type',
          );
          if (result == true) {
            final notifier = ref.read(questionNotifierProvider.notifier);
            notifier.setActiviteId(widget.activityId);
            notifier.loadQuestions(widget.activityId);
          }
        },
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 950;
          final isDesktop = constraints.maxWidth >= 950;
          final horizontalPadding = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: questionsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, _) => Center(
                  child: AppErrorState(
                    title: 'Impossible de charger les questions',
                    message: '$err',
                    onRetry: () {
                      final notifier = ref.read(questionNotifierProvider.notifier);
                      notifier.setActiviteId(widget.activityId);
                      notifier.loadQuestions(widget.activityId);
                    },
                  ),
                ),
                data: (questions) {
                  if (questions.isEmpty) {
                    return Center(
                      child: AppEmptyState(
                        icon: Icons.quiz_outlined,
                        title: 'Aucune question configurée',
                        description: 'Cette activité ne contient pas encore de quiz. Ajoutez la première question pour permettre aux enfants de jouer.',
                        actionText: 'Créer une question',
                        onActionPressed: () => context.push(
                          '/admin/activites/${widget.activityId}/questions/choose-type',
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      final notifier = ref.read(questionNotifierProvider.notifier);
                      notifier.setActiviteId(widget.activityId);
                      await notifier.loadQuestions(widget.activityId);
                    },
                    child: _buildResponsiveQuestionsView(
                      questions: questions,
                      isTablet: isTablet,
                      isDesktop: isDesktop,
                      horizontalPadding: horizontalPadding,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResponsiveQuestionsView({
    required List<Question> questions,
    required bool isTablet,
    required bool isDesktop,
    required double horizontalPadding,
  }) {
    if (isDesktop || isTablet) {
      final crossAxisCount = isDesktop ? 3 : 2;
      return GridView.builder(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 85),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 14,
          mainAxisSpacing: 12,
          mainAxisExtent: 140,
        ),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          return QuestionCard(
            question: question,
            activityId: widget.activityId,
            margin: EdgeInsets.zero,
            onEdit: () async {
              final res = await context.push(
                '/admin/activites/${widget.activityId}/questions/edit/${question.id}',
              );
              if (res == true) {
                final notifier = ref.read(questionNotifierProvider.notifier);
                notifier.setActiviteId(widget.activityId);
                notifier.loadQuestions(widget.activityId);
              }
            },
            onDelete: () => _confirmDelete(question),
          );
        },
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 85),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        return QuestionCard(
          question: question,
          activityId: widget.activityId,
          margin: const EdgeInsets.symmetric(vertical: 5),
          onEdit: () async {
            final res = await context.push(
              '/admin/activites/${widget.activityId}/questions/edit/${question.id}',
            );
            if (res == true) {
              final notifier = ref.read(questionNotifierProvider.notifier);
              notifier.setActiviteId(widget.activityId);
              notifier.loadQuestions(widget.activityId);
            }
          },
          onDelete: () => _confirmDelete(question),
        );
      },
    );
  }

  void _confirmDelete(Question question) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer la question'),
        content: Text('Êtes-vous sûr de vouloir supprimer la question :\n"${question.enonce}" ?'),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.canPop(dialogContext)) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (Navigator.canPop(dialogContext)) {
                Navigator.pop(dialogContext);
              }
              await Future.delayed(const Duration(milliseconds: 100));
              if (!mounted) return;
              try {
                final notifier = ref.read(questionNotifierProvider.notifier);
                notifier.setActiviteId(widget.activityId);
                await notifier.archiveQuestion(question.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Question supprimée avec succès'),
                      backgroundColor: Color(0xFF16A34A),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}