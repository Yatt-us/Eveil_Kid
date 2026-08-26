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
    // ✅ Utiliser le provider au lieu de instancier directement
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
            DropdownButtonFormField<String>(
              initialValue: _controller.selectedCategorieId.isNotEmpty
                  ? _controller.selectedCategorieId
                  : null,
              hint: const Text('Sélectionnez une catégorie'),
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                errorText: _controller.categorieError,
              ),
              items: _controller.categories.map((categorie) {
                return DropdownMenuItem(
                  value: categorie.id,
                  child: Text(categorie.nom),
                );
              }).toList(),
              onChanged: (value) {
                _controller.updateCategorie(value!);
              },
            ),
            const SizedBox(height: 16),

            // Description
            const Text(
              'Description *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller.descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Décrivez le contenu du tutoriel...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                errorText: _controller.descriptionError,
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
              ),
            ),
            const SizedBox(height: 24),

            // Vidéo et Visuel
            const Text(
              'Vidéo et Visuel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // URL Vidéo
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
              ),
            ),
            const SizedBox(height: 16),

            // Image de couverture
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
      ),
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