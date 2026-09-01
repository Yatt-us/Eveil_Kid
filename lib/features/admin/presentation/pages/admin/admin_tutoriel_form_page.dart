import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/admin/formcontroller/tutoriel_form_controller.dart';
import 'package:eveilkid/features/admin/presentation/widgets/tutoriel_image_picker.dart';
import 'package:eveilkid/features/admin/presentation/widgets/tutoriel_video_picker.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/features/tutoriels/enums/tutoriel_status.enum.dart';
import 'package:eveilkid/features/tutoriels/models/tutoriel.dart';
import 'package:eveilkid/features/tutoriels/providers/tutoriel_provider.dart';
import 'package:eveilkid/shared/widgets/app_button.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';
import 'package:eveilkid/shared/widgets/app_dropdown.dart';
import 'package:eveilkid/shared/widgets/app_states.dart';
import 'package:eveilkid/shared/widgets/app_text_field.dart';

class AdminTutorielFormPage extends ConsumerStatefulWidget {
  final String? tutorielId;
  final Tutoriel? tutorielToEdit;

  const AdminTutorielFormPage({
    super.key,
    this.tutorielId,
    this.tutorielToEdit,
  });

  @override
  ConsumerState<AdminTutorielFormPage> createState() => _AdminTutorielFormPageState();
}

class _AdminTutorielFormPageState extends ConsumerState<AdminTutorielFormPage> {
  TutorielFormController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.tutorielToEdit != null) {
      _controller = ref.read(tutorielFormControllerProvider(widget.tutorielToEdit));
    } else if (widget.tutorielId == null || widget.tutorielId!.isEmpty) {
      _controller = ref.read(tutorielFormControllerProvider(null));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.tutorielToEdit != null || (widget.tutorielId != null && widget.tutorielId!.isNotEmpty);

    // Si on a un tutorielId sans tutorielToEdit, on charge d'abord le tutoriel
    if (_controller == null && widget.tutorielId != null && widget.tutorielId!.isNotEmpty) {
      final tutorielAsync = ref.watch(tutorielByIdProvider(widget.tutorielId!));

      return tutorielAsync.when(
        loading: () => Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            title: const Text('Chargement du tutoriel...'),
          ),
          body: const Center(child: AppLoadingIndicator()),
        ),
        error: (err, _) => Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            title: const Text('Erreur'),
          ),
          body: AppErrorState(
            message: 'Impossible de charger le tutoriel: $err',
            onRetry: () => ref.invalidate(tutorielByIdProvider(widget.tutorielId!)),
          ),
        ),
        data: (tutoriel) {
          if (tutoriel == null) {
            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                title: const Text('Introuvable'),
              ),
              body: const AppEmptyState(
                icon: Icons.video_library_outlined,
                title: 'Tutoriel introuvable',
                description: 'Le tutoriel demandé n\'existe pas ou a été supprimé.',
              ),
            );
          }

          _controller = ref.read(tutorielFormControllerProvider(tutoriel));
          return ListenableBuilder(
            listenable: _controller!,
            builder: (context, _) => _buildFormScaffold(
              context,
              controller: _controller!,
              isEditing: true,
            ),
          );
        },
      );
    }

    return ListenableBuilder(
      listenable: _controller!,
      builder: (context, _) => _buildFormScaffold(
        context,
        controller: _controller!,
        isEditing: isEditing,
      ),
    );
  }

  Widget _buildFormScaffold(
    BuildContext context, {
    required TutorielFormController controller,
    required bool isEditing,
  }) {
    final theme = Theme.of(context);
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75) ??
        theme.colorScheme.onSurfaceVariant;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.adminTutoriels);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.adminTutoriels);
              }
            },
          ),
          title: Text(
            isEditing ? 'Modifier le tutoriel' : 'Nouveau tutoriel',
            style: AppTextStyles.headingSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.textTheme.titleLarge?.color ?? theme.colorScheme.onSurface,
            ),
          ),
          actions: [
            if (!controller.isLoading)
              TextButton.icon(
                onPressed: () => _saveTutoriel(controller, isEditing),
                icon: Icon(Icons.check_rounded, color: theme.colorScheme.primary),
                label: Text(
                  'Enregistrer',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          controller.errorMessage!,
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
                const SizedBox(height: 16),
              ],

              // Section 1: Informations Principales
              _buildSectionCard(
                title: 'Informations générales',
                icon: Icons.article_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'Titre du tutoriel *',
                      hintText: 'Ex: Découverte des formes et couleurs',
                      controller: controller.titreController,
                      errorText: controller.titreError,
                      prefixIcon: Icons.title_rounded,
                    ),
                    const SizedBox(height: 16),

                    // Catégorie via AppDropdown
                    if (controller.isLoadingCategories)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: LinearProgressIndicator(minHeight: 2),
                      )
                    else ...[
                      AppDropdown<String>(
                        label: 'Catégorie *',
                        value: controller.selectedCategorieId.isNotEmpty
                            ? controller.selectedCategorieId
                            : null,
                        hintText: 'Sélectionnez une catégorie',
                        prefixIcon: Icons.category_rounded,
                        items: controller.categories.map((categorie) {
                          return AppDropdownItem<String>(
                            value: categorie.categorieId,
                            label: categorie.nom,
                            icon: Icons.category_outlined,
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.updateCategorie(value);
                          }
                        },
                      ),
                      if (controller.categorieError != null) ...[
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            controller.categorieError!,
                            style: TextStyle(
                              color: theme.colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 16),

                    // Description
                    AppTextField(
                      label: 'Description du tutoriel *',
                      hintText:
                          'Décrivez les étapes et les objectifs pédagogiques...',
                      controller: controller.descriptionController,
                      errorText: controller.descriptionError,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 2: Tranche d'Âge (Public cible)
              _buildSectionCard(
                title: 'Public cible (Tranche d\'âge)',
                icon: Icons.child_care_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Âge min (ans)',
                            hintText: '3',
                            controller: controller.ageMinController,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.child_care_rounded,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: AppTextField(
                            label: 'Âge max (ans)',
                            hintText: '8',
                            controller: controller.ageMaxController,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.child_care_rounded,
                          ),
                        ),
                      ],
                    ),
                    if (controller.ageError != null) ...[
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          controller.ageError!,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 3: Miniature / Visuel
              _buildSectionCard(
                title: 'Miniature de couverture',
                icon: Icons.image_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ajoutez une image attractive au format 16:9 qui sera affichée sur la carte vidéo.',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TutorielImagePicker(
                      selectedImage: controller.selectedImage,
                      imageUrl: controller.imageUrl,
                      onImageSelected: controller.selectImage,
                      onImageRemoved: controller.removeImage,
                      errorText: controller.imageError,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 4: Vidéo du tutoriel
              _buildSectionCard(
                title: 'Vidéo du tutoriel',
                icon: Icons.video_library_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sélectionnez le fichier vidéo du tutoriel depuis votre galerie.',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TutorielVideoPicker(
                      selectedVideo: controller.selectedVideoFile,
                      videoUrl: controller.videoUrl,
                      onVideoSelected: controller.selectVideoFile,
                      onVideoRemoved: controller.removeVideoFile,
                      errorText: controller.videoError,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 5: Jouets Associés
              _buildJouetsSection(context, controller),
              const SizedBox(height: 20),

              // Section 6: Statut de Publication
              _buildSectionCard(
                title: 'Statut de publication',
                icon: Icons.publish_rounded,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatusOption(
                        title: 'Publié',
                        subtitle: 'Visible immédiatement par tous les utilisateurs',
                        isSelected: controller.statut == TutorielStatus.publie,
                        color: AppColors.success,
                        icon: Icons.visibility_rounded,
                        onTap: () => controller.setStatut(TutorielStatus.publie),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatusOption(
                        title: 'Brouillon',
                        subtitle: 'Invisible pour les utilisateurs standards',
                        isSelected: controller.statut == TutorielStatus.brouillon,
                        color: AppColors.warning,
                        icon: Icons.visibility_off_rounded,
                        onTap: () => controller.setStatut(TutorielStatus.brouillon),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Bouton Enregistrer Principal
              AppButton(
                text: isEditing ? 'Mettre à jour le tutoriel' : 'Enregistrer le tutoriel',
                icon: Icons.save_rounded,
                isLoading: controller.isLoading,
                onPressed: () => _saveTutoriel(controller, isEditing),
              ),
              if (controller.uploadStatusText != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    controller.uploadStatusText!,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(18),
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
                child: Icon(icon, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStatusOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.2 : 0.08)
              : (isDark
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : theme.colorScheme.surface),
          border: Border.all(
            color: isSelected
                ? color
                : theme.dividerColor.withValues(alpha: isDark ? 0.3 : 0.6),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? color
                      : theme.iconTheme.color?.withValues(alpha: 0.6) ??
                          theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? color
                        : theme.textTheme.titleSmall?.color ??
                            theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.7) ??
                    theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJouetsSection(BuildContext context, TutorielFormController controller) {
    final theme = Theme.of(context);
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75) ??
        theme.colorScheme.onSurfaceVariant;
    final jouetsAsync = ref.watch(jouetsAdminProvider);

    return _buildSectionCard(
      title: 'Jouets associés (optionnel)',
      icon: Icons.toys_rounded,
      child: jouetsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: LinearProgressIndicator(minHeight: 2),
        ),
        error: (err, _) => Text(
          'Impossible de charger les jouets: $err',
          style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
        ),
        data: (jouets) {
          if (jouets.isEmpty) {
            return Text(
              'Aucun jouet disponible dans le catalogue pour l\'association.',
              style: TextStyle(color: textSecondary, fontSize: 13),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Associez des jouets du catalogue pour proposer des suggestions aux parents.',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: jouets.map((jouet) {
                  final isSelected = controller.selectedJouetsIds.contains(jouet.jouetId);
                  return FilterChip(
                    label: Text(jouet.nom),
                    selected: isSelected,
                    onSelected: (_) => controller.toggleJouet(jouet.jouetId),
                    selectedColor: theme.colorScheme.primary.withValues(alpha: 0.18),
                    checkmarkColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.surface,
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.dividerColor.withValues(alpha: 0.4),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyMedium?.color ??
                              theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveTutoriel(TutorielFormController controller, bool isEditing) async {
    FocusScope.of(context).unfocus();

    final success = await controller.save();
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Tutoriel mis à jour avec succès !'
                : 'Tutoriel enregistré avec succès !',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go(AppRoutes.adminTutoriels);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.errorMessage ??
                'Veuillez corriger les erreurs dans le formulaire.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}
