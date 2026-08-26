import 'package:eveilkid/features/activites/formController/activity_form_controller.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_age_selector.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_category_selector.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_difficulty_selector.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_form_widget.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_image_picker.dart';
import 'package:eveilkid/features/activites/providers/admin/activity_provider.dart';
import 'package:eveilkid/features/activites/models/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditActivityScreen extends ConsumerStatefulWidget {
  final Activite activite;

  const EditActivityScreen({
    super.key,
    required this.activite,
  });

  @override
  ConsumerState<EditActivityScreen> createState() =>
      _EditActivityScreenState();
}

class _EditActivityScreenState
    extends ConsumerState<EditActivityScreen> {

  late ActivityFormController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ref.read(
      activityFormControllerProvider(widget.activite),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modifier l’activité',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        foregroundColor: Colors.black,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),

      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // =========================================================
                // IMAGE
                // =========================================================

                const Text(
                  'Image de l’activité',
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
                  selectedImage:
                      _controller.selectedImage,
                  imageUrl:
                      _controller.imageUrl,
                  onImageSelected:
                      _controller.selectImage,
                  onImageRemoved:
                      _controller.removeImage,
                ),

                const SizedBox(height: 24),

                // =========================================================
                // TITRE
                // =========================================================

                ActivityFormWidget(
                  controller:
                      _controller.titreController,
                  label: 'Titre de l’activité',
                  hint:
                      'Ex : Les animaux de la ferme',
                  errorText:
                      _controller.titreError,
                ),

                const SizedBox(height: 16),

                // =========================================================
                // DESCRIPTION
                // =========================================================

                ActivityFormWidget(
                  controller:
                      _controller.descriptionController,
                  label: 'Description',
                  hint:
                      'Décrivez cette activité',
                  maxLines: 3,
                  errorText:
                      _controller.descriptionError,
                ),

                const SizedBox(height: 16),

                // =========================================================
                // ÂGE
                // =========================================================

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
                  minAge:
                      _controller.ageMinimum,
                  maxAge:
                      _controller.ageMaximum,
                  onMinAgeChanged:
                      _controller.updateAgeMinimum,
                  onMaxAgeChanged:
                      _controller.updateAgeMaximum,
                ),

                const SizedBox(height: 16),

                // =========================================================
                // CATÉGORIE
                // =========================================================

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
                  selectedCategoryId:
                      _controller.selectedCategorieId,
                  onChanged:
                      _controller.updateCategorie,
                ),

                if (_controller.categorieError != null)
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 4),
                    child: Text(
                      _controller.categorieError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // =========================================================
                // DIFFICULTÉ
                // =========================================================

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
                  selectedDifficulty:
                      _controller.selectedDifficulte,
                  onChanged:
                      _controller.updateDifficulte,
                ),

                const SizedBox(height: 16),

                // =========================================================
                // DURÉE + POINTS
                // =========================================================

                Row(
                  children: [

                    Expanded(
                      child: ActivityFormWidget(
                        controller:
                            _controller.dureeController,
                        label: 'Durée estimée',
                        hint: 'Minutes',
                        keyboardType:
                            TextInputType.number,
                        errorText:
                            _controller.dureeError,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: ActivityFormWidget(
                        controller:
                            _controller.pointsController,
                        label: 'Points',
                        hint: 'Ex : 30',
                        keyboardType:
                            TextInputType.number,
                        errorText:
                            _controller.pointsError,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // =========================================================
                // QUESTIONS
                // =========================================================

                SizedBox(
                  width: double.infinity,

                  child: TextButton.icon(
                    onPressed: () {
                      // TODO:
                      // Naviguer vers la gestion des questions
                    },

                    icon: const Icon(
                      Icons.add,
                      color: Colors.blue,
                      size: 20,
                    ),

                    label: const Text(
                      '+ Ajouter des questions',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    style: TextButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      alignment:
                          Alignment.centerLeft,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =========================================================
                // BOUTON MODIFIER
                // =========================================================

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton(
                    onPressed: _controller.isLoading
                        ? null
                        : _updateActivity,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                      ),

                      elevation: 0,
                    ),

                    child: _controller.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Mettre à jour',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                if (_controller.errorMessage != null)
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 12),
                    child: Text(
                      _controller.errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===========================================================
  // MODIFICATION
  // ===========================================================

  Future<void> _updateActivity() async {
    final success = await _controller.save(
      resetAfterSave: false,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Activité modifiée avec succès !',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    }
  }

  // ===========================================================
  // DIALOGUE SUPPRESSION
  // ===========================================================

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer'),

          content: const Text(
            'Êtes-vous sûr de vouloir supprimer '
            'cette activité ?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Annuler'),
            ),

            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await _deleteActivity();
              },

              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),

              child: const Text(
                'Supprimer',
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================
  // SUPPRESSION
  // ===========================================================

  Future<void> _deleteActivity() async {
    if (widget.activite.id == null) {
      return;
    }

    try {
      final notifier = ref.read(
        activityNotifierProvider.notifier,
      );

      await notifier.deleteActivity(
        widget.activite.id!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Activité supprimée',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur : $e',
          ),
          backgroundColor: Colors.red,
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

      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Modifier l’activité'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Erreur lors du chargement de l’activité : $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),

      data: (activite) {
        if (activite == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Activité introuvable',
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