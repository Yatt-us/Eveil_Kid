import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/activites/formController/activity_form_controller.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_age_selector.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_category_selector.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_difficulty_selector.dart';
import 'package:eveilkid/features/activites/presentation/widgets/activity_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class AddActivityScreen extends ConsumerStatefulWidget {
  final String? activityId;

  const AddActivityScreen({
    super.key,
    this.activityId,
  });

  @override
  ConsumerState<AddActivityScreen> createState() =>
      _AddActivityScreenState();
}

class _AddActivityScreenState
    extends ConsumerState<AddActivityScreen> {

  late ActivityFormController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ref.read(
      activityFormControllerProvider(null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.activityId == null
                  ? 'Ajouter une activité'
                  : 'Modifier l\'activité',
              style: const TextStyle(
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
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [


                ActivityFormWidget(
                  controller:
                      _controller.titreController,
                  label: 'Titre de l\'activité',
                  hint: 'Ex : Les animaux de la ferme',
                  errorText:
                      _controller.titreError,
                ),

                const SizedBox(height: 16),

             

                ActivityFormWidget(
                  controller:
                      _controller.descriptionController,
                  label: 'Description',
                  hint: 'Décrivez cette activité',
                  maxLines: 3,
                  errorText:
                      _controller.descriptionError,
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
                  onMinAgeChanged:
                      _controller.updateAgeMinimum,
                  onMaxAgeChanged:
                      _controller.updateAgeMaximum,
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

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _controller.isLoading
                        ? null
                        : _saveActivity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primary,
                      foregroundColor:
                          Colors.white,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _controller.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.activityId == null
                                ? 'Enregistrer'
                                : 'Mettre à jour',
                            style:
                                const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveActivity() async {
    final success = await _controller.save();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Activité enregistrée avec succès !',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}