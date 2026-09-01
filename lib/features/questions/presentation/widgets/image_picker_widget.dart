import 'dart:io';
import 'package:flutter/material.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? selectedImage;
  final String? imageUrl;
  final VoidCallback onImageRemoved;
  final VoidCallback onImageTap;

  const ImagePickerWidget({
    super.key,
    this.selectedImage,
    this.imageUrl,
    required this.onImageRemoved,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.3 : 0.15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Illustration (optionnel)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onImageTap,
          child: Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: dividerColor, width: 1.2),
              borderRadius: BorderRadius.circular(14),
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                  : theme.colorScheme.surface,
            ),
            child: selectedImage != null
                ? _buildFileImage()
                : imageUrl != null && imageUrl!.isNotEmpty
                    ? _buildNetworkImage(theme)
                    : _buildPlaceholder(theme),
          ),
        ),
      ],
    );
  }

  Widget _buildFileImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            selectedImage!,
            fit: BoxFit.cover,
          ),
        ),
        _buildDeleteButton(),
      ],
    );
  }

  Widget _buildNetworkImage(ThemeData theme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Center(
              child: Icon(
                Icons.broken_image_rounded,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                size: 32,
              ),
            ),
          ),
        ),
        _buildDeleteButton(),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: Material(
        color: Colors.black.withValues(alpha: 0.65),
        shape: const CircleBorder(),
        child: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
          onPressed: onImageRemoved,
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
          tooltip: 'Supprimer l\'image',
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_photo_alternate_rounded,
              size: 26,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajouter une illustration',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}