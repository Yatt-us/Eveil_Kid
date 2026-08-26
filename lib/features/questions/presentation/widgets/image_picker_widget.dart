import 'package:flutter/material.dart';
import 'dart:io';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Image (optionnel)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onImageTap,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: selectedImage != null
                ? _buildFileImage()
                : imageUrl != null && imageUrl!.isNotEmpty
                    ? _buildNetworkImage()
                    : _buildPlaceholder(),
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
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            selectedImage!,
            fit: BoxFit.cover,
          ),
        ),
        _buildDeleteButton(),
      ],
    );
  }

  Widget _buildNetworkImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
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
      child: CircleAvatar(
        backgroundColor: Colors.black.withOpacity(0.6),
        radius: 16,
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 16),
          onPressed: onImageRemoved,
          padding: EdgeInsets.zero,
        ),
      ),
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
            'Tapez pour ajouter une image',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}