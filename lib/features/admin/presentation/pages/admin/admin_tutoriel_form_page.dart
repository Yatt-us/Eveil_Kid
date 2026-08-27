import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  late TutorielFormController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    if (widget.tutorielToEdit != null) {
      _controller = ref.read(tutorielFormControllerProvider(widget.tutorielToEdit));
      _isInitialized = true;
    } else if (widget.tutorielId != null && widget.tutorielId!.isNotEmpty) {
      // Le chargement asynchrone se fera dans didChangeDependencies si besoin
    } else {
      _controller = ref.read(tutorielFormControllerProvider(null));
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si on a un tutorielId mais pas de tutorielToEdit passé en extra
    if (!_isInitialized && widget.tutorielId != null) {
      final tutorielAsync = ref.watch(tutorielByIdProvider(widget.tutorielId!));

      return tutorielAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Chargement...')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Scaffold(
          appBar: AppBar(title: const Text('Erreur')),
          body: Center(child: Text('Erreur: $err')),
        ),
        data: (tutoriel) {
          if (tutoriel == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Introuvable')),
              body: const Center(child: Text('Tutoriel introuvable')),
            );
          }
          _controller = ref.read(tutorielFormControllerProvider(tutoriel));
          _isInitialized = true;
          return _buildFormScaffold(context, isEditing: true);
        },
      );
    }

    final isEditing = widget.tutorielToEdit != null || (widget.tutorielId != null && widget.tutorielId!.isNotEmpty);
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => _buildFormScaffold(context, isEditing: isEditing),
    );
  }

  Widget _buildFormScaffold(BuildContext context, {required bool isEditing}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          isEditing ? 'Modifier le tutoriel' : 'Nouveau tutoriel',
          style: AppTextStyles.headingSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        actions: [
          if (!_controller.isLoading)
            TextButton.icon(
              onPressed: _saveTutoriel,
              icon: const Icon(Icons.check_rounded, color: AppColors.primary),
              label: const Text(
                'Enregistrer',
                style: TextStyle(
                  color: AppColors.primary,
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
            if (_controller.errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _controller.errorMessage!,
                        style: const TextStyle(color: AppColors.danger, fontSize: 13),
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
                    controller: _controller.titreController,
                    errorText: _controller.titreError,
                    prefixIcon: Icons.title_rounded,
                  ),
                  const SizedBox(height: 16),

                  // Catégorie
                  Text(
                    'Catégorie *',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_controller.isLoadingCategories)
                    const LinearProgressIndicator(minHeight: 2)
                  else
                    DropdownButtonFormField<String>(
                      initialValue: _controller.selectedCategorieId.isNotEmpty
                          ? _controller.selectedCategorieId
                          : null,
                      hint: const Text('Sélectionnez une catégorie'),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _controller.categorieError != null
                                ? AppColors.danger
                                : (isDark ? Colors.white24 : Colors.grey.shade300),
                          ),
                        ),
                        errorText: _controller.categorieError,
                        prefixIcon: const Icon(Icons.category_rounded, color: AppColors.primary),
                      ),
                      items: _controller.categories.map((categorie) {
                        return DropdownMenuItem(
                          value: categorie.categorieId,
                          child: Text(categorie.nom),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _controller.updateCategorie(value);
                        }
                      },
                    ),
                  const SizedBox(height: 16),

                  // Description
                  AppTextField(
                    label: 'Description du tutoriel *',
                    hintText: 'Décrivez les étapes et les objectifs pédagogiques...',
                    controller: _controller.descriptionController,
                    errorText: _controller.descriptionError,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 2: Durée & Tranche d'Âge
            _buildSectionCard(
              title: 'Durée & Public cible',
              icon: Icons.timer_rounded,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Durée (mm:ss) *',
                          hintText: '05:30',
                          controller: _controller.dureeController,
                          errorText: _controller.dureeError,
                          prefixIcon: Icons.schedule_rounded,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppTextField(
                          label: 'Âge min (ans)',
                          hintText: '3',
                          controller: _controller.ageMinController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.child_care_rounded,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppTextField(
                          label: 'Âge max (ans)',
                          hintText: '8',
                          controller: _controller.ageMaxController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.child_care_rounded,
                        ),
                      ),
                    ],
                  ),
                  if (_controller.ageError != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _controller.ageError!,
                      style: const TextStyle(color: AppColors.danger, fontSize: 12),
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
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TutorielImagePicker(
                    selectedImage: _controller.selectedImage,
                    imageUrl: _controller.imageUrl,
                    onImageSelected: _controller.selectImage,
                    onImageRemoved: _controller.removeImage,
                    errorText: _controller.imageError,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 4: Vidéo & Upload
            _buildSectionCard(
              title: 'Contenu Vidéo',
              icon: Icons.video_library_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choisissez la source de votre vidéo pour le tutoriel.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Choix de la source vidéo
                  Row(
                    children: [
                      Expanded(
                        child: _buildSourceTab(
                          context,
                          label: 'Fichier Vidéo (Cloudinary)',
                          icon: Icons.cloud_upload_rounded,
                          isSelected: _controller.videoSourceType == VideoSourceType.file,
                          onTap: () => _controller.setVideoSourceType(VideoSourceType.file),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSourceTab(
                          context,
                          label: 'Lien Web (YouTube, etc.)',
                          icon: Icons.link_rounded,
                          isSelected: _controller.videoSourceType == VideoSourceType.url,
                          onTap: () => _controller.setVideoSourceType(VideoSourceType.url),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_controller.videoSourceType == VideoSourceType.file)
                    TutorielVideoPicker(
                      selectedVideo: _controller.selectedVideoFile,
                      videoUrl: _controller.videoUrl,
                      onVideoSelected: _controller.selectVideoFile,
                      onVideoRemoved: _controller.removeVideoFile,
                      errorText: _controller.videoError,
                    )
                  else
                    AppTextField(
                      label: 'URL de la vidéo *',
                      hintText: 'https://www.youtube.com/watch?v=...',
                      controller: _controller.videoUrlController,
                      errorText: _controller.videoError,
                      prefixIcon: Icons.ondemand_video_rounded,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 5: Jouets Associés
            _buildJouetsSection(context),
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
                      isSelected: _controller.statut == TutorielStatus.publie,
                      color: AppColors.success,
                      icon: Icons.visibility_rounded,
                      onTap: () => _controller.setStatut(TutorielStatus.publie),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatusOption(
                      title: 'Brouillon',
                      subtitle: 'Invisible pour les utilisateurs standards',
                      isSelected: _controller.statut == TutorielStatus.brouillon,
                      color: AppColors.warning,
                      icon: Icons.visibility_off_rounded,
                      onTap: () => _controller.setStatut(TutorielStatus.brouillon),
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
              isLoading: _controller.isLoading,
              onPressed: _saveTutoriel,
            ),
            if (_controller.uploadStatusText != null) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _controller.uploadStatusText!,
                  style: TextStyle(
                    color: AppColors.primary,
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
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.headingSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
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

  Widget _buildSourceTab(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.white12 : Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textSecondary),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.textPrimary),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
              : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade50),
          border: Border.all(
            color: isSelected ? color : (isDark ? Colors.white12 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: isSelected ? color : Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? color : (isDark ? Colors.white : AppColors.textPrimary),
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
                color: isDark ? Colors.white60 : Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJouetsSection(BuildContext context) {
    final jouetsAsync = ref.watch(jouetsAdminProvider);

    return _buildSectionCard(
      title: 'Jouets associés (optionnel)',
      icon: Icons.toys_rounded,
      child: jouetsAsync.when(
        loading: () => const LinearProgressIndicator(minHeight: 2),
        error: (err, _) => Text('Impossible de charger les jouets: $err'),
        data: (jouets) {
          if (jouets.isEmpty) {
            return const Text(
              'Aucun jouet disponible dans le catalogue pour l\'association.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Associez des jouets du catalogue pour proposer des suggestions aux parents.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: jouets.map((jouet) {
                  final isSelected = _controller.selectedJouetsIds.contains(jouet.jouetId);
                  return FilterChip(
                    label: Text(jouet.nom),
                    selected: isSelected,
                    onSelected: (_) => _controller.toggleJouet(jouet.jouetId),
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : null,
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

  Future<void> _saveTutoriel() async {
    final success = await _controller.save();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.tutorielToEdit != null || (widget.tutorielId != null && widget.tutorielId!.isNotEmpty)
                ? 'Tutoriel mis à jour avec succès !'
                : 'Tutoriel enregistré avec succès !',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).maybePop(true);
    }
  }
}
