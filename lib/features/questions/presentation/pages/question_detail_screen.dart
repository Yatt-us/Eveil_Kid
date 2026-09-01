import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/features/activites/providers/admin/activity_provider.dart';
import 'package:eveilkid/features/questions/models/question_model.dart';
import 'package:eveilkid/features/questions/options_questions/option_model.dart';
import 'package:eveilkid/features/questions/providers/question_provider.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

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
        (activiteId: widget.activityId, questionId: widget.questionId),
      ),
    );

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: activityAsync.when(
          loading: () => const Text('Détail question'),
          error: (_, _) => const Text('Détail question'),
          data: (activity) => Column(
            children: [
              Text(
                'Détail Question',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
                ),
              ),
              if (activity != null) ...[
                const SizedBox(height: 2),
                Text(
                  activity.titre,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: questionAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, _) => Center(
          child: AppErrorState(
            title: 'Erreur lors du chargement',
            message: '$err',
            onRetry: () {
              ref.invalidate(
                questionByIdProvider(
                  (activiteId: widget.activityId, questionId: widget.questionId),
                ),
              );
            },
          ),
        ),
        data: (question) {
          if (question == null) {
            return Center(
              child: AppEmptyState(
                icon: Icons.quiz_outlined,
                title: 'Question introuvable',
                description: 'Cette question a peut-être été supprimée.',
                actionText: 'Retour',
                onActionPressed: () => Navigator.pop(context),
              ),
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: _buildDetailContent(question, theme, isDark),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailContent(Question question, ThemeData theme, bool isDark) {
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CARTE ÉNONCÉ HERO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.quiz_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Énoncé du défi',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  question.enonce,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 18,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 2. INFOS TYPE & POINTS
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: question.typeIcon,
                  title: 'Type',
                  value: question.typeLabel,
                  iconColor: theme.colorScheme.primary,
                  theme: theme,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.star_rounded,
                  title: 'Récompense',
                  value: '${question.points} étoiles ⭐',
                  iconColor: const Color(0xFFD97706),
                  theme: theme,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          // 3. ILLUSTRATION
          if (question.imageUrl != null && question.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionHeader(
              icon: Icons.image_outlined,
              title: 'Illustration',
              theme: theme,
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: dividerColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.network(
                  question.imageUrl!,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 150,
                    color: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.grey.shade100,
                    child: Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // 4. OPTIONS DE RÉPONSES
          if (question.options.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSectionHeader(
              icon: Icons.checklist_rounded,
              title: 'Options de réponses',
              theme: theme,
            ),
            const SizedBox(height: 4),
            Text(
              'La bonne réponse est mise en évidence en vert.',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 12),
            ...question.options.asMap().entries.map(
                  (entry) => _buildOptionItem(
                    entry.value,
                    question.idReponseCorrecte,
                    entry.key,
                    theme,
                    isDark,
                  ),
                ),
          ],

          const SizedBox(height: 28),

          // 5. BOUTONS D'ACTIONS (MODIFIER / SUPPRIMER)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(
                    '/admin/activites/${widget.activityId}/questions/edit/${widget.questionId}',
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Modifier'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(question),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Supprimer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
    required ThemeData theme,
    required bool isDark,
  }) {
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.25 : 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
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
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionItem(
    OptionQuestion option,
    String correctId,
    int index,
    ThemeData theme,
    bool isDark,
  ) {
    final isCorrect = option.id == correctId;
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCorrect
            ? (isDark ? const Color(0xFF14532D).withValues(alpha: 0.35) : const Color(0xFFDCFCE7))
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCorrect ? const Color(0xFF16A34A) : dividerColor,
          width: isCorrect ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCorrect
                  ? const Color(0xFF16A34A)
                  : (isDark ? theme.colorScheme.surfaceContainerHighest : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              String.fromCharCode(65 + index),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isCorrect ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              option.texte,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isCorrect ? FontWeight.w700 : FontWeight.w500,
                color: isCorrect
                    ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D))
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (isCorrect) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_rounded, color: Colors.white, size: 12),
                  SizedBox(width: 3),
                  Text(
                    'Correcte',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(Question question) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer la question'),
        content: Text('Êtes-vous sûr de vouloir supprimer :\n"${question.enonce}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final notifier = ref.read(questionNotifierProvider.notifier);
                notifier.setActiviteId(widget.activityId);
                await notifier.archiveQuestion(question.id!);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Question supprimée avec succès'),
                    backgroundColor: Color(0xFF16A34A),
                  ),
                );
                Navigator.pop(context, true);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}