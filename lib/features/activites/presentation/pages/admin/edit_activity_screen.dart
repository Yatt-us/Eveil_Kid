import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/features/activites/formController/activity_form_controller.dart';
import 'package:eveilkid/features/activites/models/activity.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_age_selector.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_category_selector.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_difficulty_selector.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_form_widget.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_image_picker.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_status_selector.dart';
import 'package:eveilkid/features/activites/providers/admin/activity_provider.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';

class EditActivityScreen extends ConsumerStatefulWidget {
  final Activite activite;

  const EditActivityScreen({
    super.key,
    required this.activite,
  });

  @override
  ConsumerState<EditActivityScreen> createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends ConsumerState<EditActivityScreen> {
  late ActivityFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ActivityFormController(
      ref,
      initialActivite: widget.activite,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Modifier l\'Activité',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
            tooltip: 'Supprimer l\'activité',
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. SECTION STATUT DE PUBLICATION
                _buildSectionCard(
                  theme: theme,
                  isDark: isDark,
                  icon: Icons.flag_outlined,
                  title: 'Statut de publication',
                  child: ActivityStatusSelector(
                    selectedStatus: _controller.selectedStatut,
                    onChanged: _controller.updateStatut,
                  ),
                ),

                const SizedBox(height: 16),

                // 2. SECTION IMAGE
                _buildSectionCard(
                  theme: theme,
                  isDark: isDark,
                  icon: Icons.image_outlined,
                  title: 'Illustration de l\'activité',
                  subtitle: 'Format 16:9 recommandé pour l\'affichage',
                  child: ActivityImagePicker(
                    selectedImage: _controller.selectedImage,
                    imageUrl: _controller.imageUrl,
                    onImageSelected: _controller.selectImage,
                    onImageRemoved: _controller.removeImage,
                  ),
                ),

                const SizedBox(height: 16),

                // 3. SECTION INFOS GÉNÉRALES
                _buildSectionCard(
                  theme: theme,
                  isDark: isDark,
                  icon: Icons.edit_note_rounded,
                  title: 'Informations Générales',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ActivityFormWidget(
                        controller: _controller.titreController,
                        label: 'Titre de l\'activité',
                        hint: 'Ex : Les animaux de la savane',
                        errorText: _controller.titreError,
                      ),
                      const SizedBox(height: 14),
                      ActivityFormWidget(
                        controller: _controller.descriptionController,
                        label: 'Description pédagogique',
                        hint: 'Décrivez les objectifs et l\'histoire de l\'activité...',
                        maxLines: 3,
                        errorText: _controller.descriptionError,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4. SECTION CRITÈRES PÉDAGOGIQUES
                _buildSectionCard(
                  theme: theme,
                  isDark: isDark,
                  icon: Icons.school_outlined,
                  title: 'Critères Pédagogiques',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catégorie d\'univers',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ActivityCategorySelector(
                        selectedCategoryId: _controller.selectedCategorieId,
                        onChanged: _controller.updateCategorie,
                      ),
                      if (_controller.categorieError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _controller.categorieError!,
                            style: TextStyle(
                              color: theme.colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      ActivityAgeSelector(
                        minAge: _controller.ageMinimum,
                        maxAge: _controller.ageMaximum,
                        onMinAgeChanged: _controller.updateAgeMinimum,
                        onMaxAgeChanged: _controller.updateAgeMaximum,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Niveau de difficulté',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ActivityDifficultySelector(
                        selectedDifficulty: _controller.selectedDifficulte,
                        onChanged: _controller.updateDifficulte,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 5. SECTION PARAMÈTRES DE JEU
                _buildSectionCard(
                  theme: theme,
                  isDark: isDark,
                  icon: Icons.sports_esports_outlined,
                  title: 'Récompenses & Temps',
                  child: Row(
                    children: [
                      Expanded(
                        child: ActivityFormWidget(
                          controller: _controller.dureeController,
                          label: 'Durée estimée',
                          hint: 'En minutes (ex: 15)',
                          keyboardType: TextInputType.number,
                          errorText: _controller.dureeError,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ActivityFormWidget(
                          controller: _controller.pointsController,
                          label: 'Points à gagner',
                          hint: 'Étoiles (ex: 30)',
                          keyboardType: TextInputType.number,
                          errorText: _controller.pointsError,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 6. SECTION ACCÈS QUESTIONS
                if (widget.activite.id != null)
                  _buildSectionCard(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.quiz_outlined,
                    title: 'Questions de l\'activité',
                    subtitle: 'Gérez les quiz et défis interactifs',
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.push(
                            '/admin/activites/${widget.activite.id}/questions',
                          );
                        },
                        icon: Icon(Icons.list_alt_rounded, size: 18, color: theme.colorScheme.primary),
                        label: const Text('Ouvrir la liste des questions'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: theme.colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                if (_controller.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _controller.errorMessage!,
                            style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // BOUTON METTRE À JOUR
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _controller.isLoading ? null : _updateActivity,
                    icon: _controller.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline_rounded, size: 20),
                    label: Text(
                      _controller.isLoading
                          ? 'Mise à jour...'
                          : 'Enregistrer les modifications',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 1,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.12);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 18, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Future<void> _updateActivity() async {
    final success = await _controller.save(resetAfterSave: false);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activité modifiée avec succès !'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer l\'activité'),
          content: const Text('Êtes-vous sûr de vouloir supprimer cette activité ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _deleteActivity();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteActivity() async {
    if (widget.activite.id == null) return;

    try {
      final notifier = ref.read(activityNotifierProvider.notifier);
      await notifier.deleteActivity(widget.activite.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activité supprimée avec succès'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

class EditActivityLoader extends ConsumerWidget {
  final String activityId;

  const EditActivityLoader({
    super.key,
    required this.activityId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(
      activiteByIdProvider(activityId),
    );

    return activityAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Modifier l’activité'),
        ),
        body: Center(
          child: AppErrorState(
            title: 'Erreur de chargement',
            message: '$error',
            onRetry: () => ref.invalidate(activiteByIdProvider(activityId)),
          ),
        ),
      ),
      data: (activite) {
        if (activite == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Modifier l’activité'),
            ),
            body: Center(
              child: AppEmptyState(
                icon: Icons.extension_off_outlined,
                title: 'Activité introuvable',
                description: 'Cette activité a peut-être été supprimée ou archivée.',
                actionText: 'Retour',
                onActionPressed: () => Navigator.pop(context),
              ),
            ),
          );
        }

        return EditActivityScreen(
          activite: activite,
        );
      },
    );
  }
}