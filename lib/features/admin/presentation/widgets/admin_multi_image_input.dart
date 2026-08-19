import 'package:flutter/material.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/shared/widgets/app_button.dart';
import 'package:eveilkid/shared/widgets/app_text_field.dart';

class AdminMultiImageInput extends StatefulWidget {
  final List<String> initialImages;
  final String initialMainImageUrl;
  final Function(List<String> images, String mainImageUrl) onChanged;

  const AdminMultiImageInput({
    super.key,
    required this.initialImages,
    required this.initialMainImageUrl,
    required this.onChanged,
  });

  @override
  State<AdminMultiImageInput> createState() => _AdminMultiImageInputState();
}

class _AdminMultiImageInputState extends State<AdminMultiImageInput> {
  late List<String> _images;
  late String _mainImageUrl;
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _images = List<String>.from(widget.initialImages);
    _mainImageUrl = widget.initialMainImageUrl.isNotEmpty
        ? widget.initialMainImageUrl
        : (_images.isNotEmpty ? _images.first : '');
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _addImage() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      if (!_images.contains(url)) {
        _images.add(url);
        if (_mainImageUrl.isEmpty) {
          _mainImageUrl = url;
        }
      }
      _urlController.clear();
    });
    widget.onChanged(_images, _mainImageUrl);
  }

  void _removeImage(int index) {
    setState(() {
      final removed = _images.removeAt(index);
      if (_mainImageUrl == removed) {
        _mainImageUrl = _images.isNotEmpty ? _images.first : '';
      }
    });
    widget.onChanged(_images, _mainImageUrl);
  }

  void _setAsMain(String url) {
    setState(() {
      _mainImageUrl = url;
    });
    widget.onChanged(_images, _mainImageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.photo_library_outlined, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              "Images du produit",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              "${_images.length} image(s)",
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        AppSpacing.verticalSm,
        // Champ pour ajouter une URL d'image
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: _urlController,
                hintText: "Coller l'URL de l'image (https://...)",
                prefixIcon: Icons.link,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: AppButton(
                text: "Ajouter",
                icon: Icons.add_photo_alternate_outlined,
                isFullWidth: false,
                onPressed: _addImage,
              ),
            ),
          ],
        ),
        AppSpacing.verticalMd,
        // Aperçu et liste des images
        if (_images.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
            ),
            child: const Column(
              children: [
                Icon(Icons.image_outlined, size: 36, color: AppColors.icon),
                SizedBox(height: 8),
                Text(
                  "Aucune image ajoutée pour l'instant",
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final url = _images[index];
                final isMain = url == _mainImageUrl;

                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _setAsMain(url),
                      child: Container(
                        width: 100,
                        height: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isMain ? AppColors.primary : AppColors.border,
                            width: isMain ? 2.5 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.surfaceVariant,
                              child: const Icon(Icons.broken_image, color: AppColors.icon),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Badge "Couverture"
                    if (isMain)
                      Positioned(
                        bottom: 12,
                        left: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "Principale",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    // Bouton de suppression
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 12, color: AppColors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
