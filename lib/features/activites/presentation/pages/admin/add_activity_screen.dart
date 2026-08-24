import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/activites/formController/activity_form_controller.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_age_selector.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_category_selector.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_difficulty_selector.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_form_widget.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_image_picker.dart';
import 'package:eveilkid/features/activites/providers/admin/activity_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddActivityScreen extends ConsumerStatefulWidget {
  final String? activityId;

  const AddActivityScreen({super.key, this.activityId});

  @override
  ConsumerState<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends ConsumerState<AddActivityScreen> {
  late final ActivityFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(activityFormControllerProvider(null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.activityId == null ? 'Ajouter une activité' : 'Modifier l\'activité',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.activityId != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: () => _showDeleteDialog(context),
            ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.errorMessage != null) {
            return _buildErrorWidget();
          }

          return _buildForm();
        },
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(
              _controller.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _controller.errorMessage = null,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
          const Text(
            'Ajouter une image',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Format recommandé : 16,9',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ActivityImagePicker(
            selectedImage: _controller.selectedImage,
            imageUrl: _controller.imageUrl,
            onImageSelected: _controller.selectImage,
            onImageRemoved: _controller.removeImage,
          ),
          const SizedBox(height: 24),

         
          ActivityFormWidget(
            controller: _controller.titreController,
            label: 'Titre de l\'activité',
            hint: 'Ex : les animaux de la ferme',
          ),
          const SizedBox(height: 16),

         
          ActivityFormWidget(
            controller: _controller.descriptionController,
            label: 'Description',
            hint: 'Décrivez cette activité',
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          
          const Text(
            'Âge recommandé',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          ActivityAgeSelector(
            minAge: _controller.ageMinimum,
            maxAge: _controller.ageMaximum,
            onMinAgeChanged: _controller.updateAgeMinimum,
            onMaxAgeChanged: _controller.updateAgeMaximum,
          ),
          const SizedBox(height: 16),

          const Text(
            'Catégorie',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          ActivityCategorySelector(
            selectedCategoryId: _controller.selectedCategorieId,
            onChanged: _controller.updateCategorie,
          ),
          const SizedBox(height: 16),

          const Text(
            'Difficulté',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          ActivityDifficultySelector(
            selectedDifficulty: _controller.selectedDifficulte,
            onChanged: _controller.updateDifficulte,
          ),
          const SizedBox(height: 16),

         
          Row(
            children: [
              Expanded(
                child: ActivityFormWidget(
                  controller: _controller.dureeController,
                  label: 'Durée estimée',
                  hint: 'Minutes',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ActivityFormWidget(
                  controller: _controller.pointsController,
                  label: 'Points',
                  hint: 'Ex : 30',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

         
          if (widget.activityId != null)
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: AppColors.primary, size: 20),
                label: const Text(
                  '+ Ajouter des questions',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
          const SizedBox(height: 16),

        
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveActivity,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.activityId == null ? 'Enregistrer' : 'Mettre à jour',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
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
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette activité ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteActivity();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteActivity() async {
    if (widget.activityId == null) return;
    
    try {
      final notifier = ref.read(activityNotifierProvider.notifier);
      await notifier.deleteActivity(widget.activityId!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activité supprimée'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
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
  }
}