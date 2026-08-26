import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/admin/formcontroller/tutoriel_form_controller.dart';
import 'package:eveilkid/features/admin/presentation/widgets/tutoriel_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddTutorielScreen extends ConsumerStatefulWidget {
  const AddTutorielScreen({super.key});

  @override
  ConsumerState<AddTutorielScreen> createState() => _AddTutorielScreenState();
}

class _AddTutorielScreenState extends ConsumerState<AddTutorielScreen> {
  late TutorielFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(tutorielFormControllerProvider(null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter un tutoriel',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _saveTutoriel,
            icon: const Icon(Icons.save, color: Colors.black),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre
                        const Text(
                          'Titre du tutoriel *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _controller.titreController,
                          decoration: InputDecoration(
                            hintText: 'Ex: Comment fabriquer un puzzle en bois',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            errorText: _controller.titreError,
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Catégorie
                        const Text(
                          'Catégorie tutoriel *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _controller.isLoadingCategories
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : DropdownButtonFormField<String>(
                                value: _controller.selectedCategorieId.isNotEmpty
                                    ? _controller.selectedCategorieId
                                    : null,
                                hint: const Text('Sélectionnez une catégorie'),
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(8)),
                                  ),
                                  errorText: _controller.categorieError,
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                items: _controller.categories.map((categorie) {
                                  return DropdownMenuItem<String>(
                                    value: categorie.categorieId,
                                    child: Text(categorie.nom),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    _controller.updateCategorie(value);
                                  }
                                },
                                icon: const Icon(Icons.arrow_drop_down),
                              ),
                        const SizedBox(height: 16),

                        // Description avec éditeur
                        const Text(
                          'Description *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildEditorButton(Icons.format_bold),
                                _buildEditorButton(Icons.format_italic),
                                _buildEditorButton(Icons.format_underline),
                                _buildEditorButton(Icons.format_list_bulleted),
                                _buildEditorButton(Icons.format_list_numbered),
                                const SizedBox(width: 8),
                                Container(
                                  width: 1,
                                  height: 20,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(width: 8),
                                _buildEditorButton(Icons.insert_emoticon),
                                _buildEditorButton(Icons.format_quote),
                                _buildEditorButton(Icons.format_align_left),
                                _buildEditorButton(Icons.format_align_center),
                                _buildEditorButton(Icons.format_align_right),
                              ],
                            ),
                          ),
                        ),
                        TextField(
                          controller: _controller.descriptionController,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: 'Décrivez le contenu du tutoriel...',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            errorText: _controller.descriptionError,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Durée
                        const Text(
                          'Durée (mm:ss) *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _controller.dureeController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Ex: 05:24',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            errorText: _controller.dureeError,
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

            
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vidéo et Visuel',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'URL de la vidéo (YouTube, Vimeo...) *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _controller.videoUrlController,
                          decoration: InputDecoration(
                            hintText: 'https://www.youtube.com/watch?v=...',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            errorText: _controller.videoUrlError,
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Image de couverture *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TutorielImagePicker(
                          selectedImage: _controller.selectedImage,
                          imageUrl: _controller.imageUrl,
                          onImageSelected: _controller.selectImage,
                          onImageRemoved: _controller.removeImage,
                          errorText: _controller.imageError,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'PNG, JPG jusqu\'à 5 Mo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton Enregistrer
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveTutoriel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Enregistrer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildEditorButton(IconData icon) {
    return IconButton(
      icon: Icon(icon, size: 16, color: Colors.grey.shade700),
      onPressed: () {},
      padding: const EdgeInsets.all(2),
      constraints: const BoxConstraints(
        minWidth: 28,
        minHeight: 28,
      ),
      splashRadius: 14,
    );
  }

  Future<void> _saveTutoriel() async {
    final success = await _controller.save();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tutoriel enregistré avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }
}