import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/activites/formController/activity_form_controller.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_age_selector.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_category_selector.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_difficulty_selector.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_form_widget.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_image_picker.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_status_selector.dart';

class AddActivityScreen extends ConsumerStatefulWidget {
  const AddActivityScreen({super.key});

  @override
  ConsumerState<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends ConsumerState<AddActivityScreen> {
  late ActivityFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ActivityFormController(ref);
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else if (context.mounted) {
          context.go(AppRoutes.adminActivites);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Nouvelle Activité',
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
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go(AppRoutes.adminActivites);
              }
            },
          ),
        ),
        body: ListenableBuilder(
          listenable: _controller,
          builder: (context, child) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. SECTION STATUT
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
                              hint: 'Expliquez l\'objectif et l\'histoire de cette activité...',
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
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // BOUTON ENREGISTRER
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _controller.isLoading ? null : _saveActivity,
                          icon: _controller.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.check_rounded),
                          label: Text(
                            _controller.isLoading ? 'Enregistrement...' : 'Créer l\'activité',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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

  Future<void> _saveActivity() async {
    final success = await _controller.save();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activité enregistrée avec succès !'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context, true);
      } else {
        context.go(AppRoutes.adminActivites);
      }
    }
  }
}