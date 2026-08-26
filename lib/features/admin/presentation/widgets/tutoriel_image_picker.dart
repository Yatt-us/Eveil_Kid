import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/core/constants/app_colors.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasFile = selectedImage != null;
    final hasUrl = imageUrl != null && imageUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showSourceSheet(context),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100,
                border: Border.all(
                  color: errorText != null
                      ? AppColors.danger
                      : (hasFile || hasUrl
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : (isDark ? Colors.white24 : Colors.grey.shade300)),
                  width: errorText != null ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: hasFile
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            selectedImage!,
                            fit: BoxFit.cover,
                          ),
                          _buildOverlayActions(context),
                        ],
                      )
                    : (hasUrl
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _buildPlaceholder(context),
                              ),
                              _buildOverlayActions(context),
                            ],
                          )
                        : _buildPlaceholder(context)),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.danger,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_photo_alternate_rounded,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ajouter une miniature 16:9',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'JPG ou PNG (sera hébergé sur Cloudinary)',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayActions(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: Colors.black.withValues(alpha: 0.6),
            radius: 16,
            child: IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
              tooltip: 'Modifier',
              onPressed: () => _showSourceSheet(context),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.black.withValues(alpha: 0.6),
            radius: 16,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
              tooltip: 'Retirer',
              onPressed: onImageRemoved,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSourceSheet(BuildContext context) async {
    final theme = Theme.of(context);

    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Source de l\'image',
                style: AppTextStyles.headingSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                ),
                title: const Text('Galerie photo'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickImage(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.secondary),
                ),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickImage(context, ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        onImageSelected(File(pickedFile.path));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}