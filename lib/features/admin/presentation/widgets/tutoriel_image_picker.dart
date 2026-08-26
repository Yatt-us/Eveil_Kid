import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class TutorielImagePicker extends StatelessWidget {
  final File? selectedImage;
  final String? imageUrl;
  final Function(File) onImageSelected;
  final VoidCallback onImageRemoved;
  final String? errorText;

  const TutorielImagePicker({
    super.key,
    this.selectedImage,
    this.imageUrl,
    required this.onImageSelected,
    required this.onImageRemoved,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(
                color: errorText != null ? Colors.red : Colors.grey.shade300,
                width: errorText != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: selectedImage != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      _buildDeleteButton(),
                    ],
                  )
                : imageUrl != null && imageUrl!.isNotEmpty
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _buildPlaceholder(),
                            ),
                          ),
                          _buildDeleteButton(),
                        ],
                      )
                    : _buildPlaceholder(),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionner un fichier image',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: CircleAvatar(
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        radius: 16,
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 16),
          onPressed: onImageRemoved,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        onImageSelected(File(pickedFile.path));
      }
    } catch (e) {
      // Gérer l'erreur
    }
  }
}