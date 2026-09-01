import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eveilkid/core/cloudinary/cloudinary_service.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';

/// Composant moderne pour la gestion des photos de produits
/// avec téléversement direct sans saisie manuelle d'URL.
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
  final CloudinaryService _cloudinary = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  late List<String> _images;
  late String _mainImageUrl;

  bool _isUploadingMain = false;
  bool _isUploadingSecondary = false;

  @override
  void initState() {
    super.initState();
    _images = List<String>.from(widget.initialImages);
    _mainImageUrl = widget.initialMainImageUrl.trim().isNotEmpty
        ? widget.initialMainImageUrl.trim()
        : (_images.isNotEmpty ? _images.first : '');
  }

  Future<void> _pickAndUploadMainImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _isUploadingMain = true);

      final uploadedUrl = await _cloudinary.uploadImage(
        File(picked.path),
        folder: 'jouets',
      );

      if (!mounted) return;

      setState(() {
        _isUploadingMain = false;
        _mainImageUrl = uploadedUrl;
        if (!_images.contains(uploadedUrl)) {
          _images.insert(0, uploadedUrl);
        }
      });

      widget.onChanged(_images, _mainImageUrl);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingMain = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du téléversement : $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _pickAndUploadSecondaryImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _isUploadingSecondary = true);

      final uploadedUrl = await _cloudinary.uploadImage(
        File(picked.path),
        folder: 'jouets/galerie',
      );

      if (!mounted) return;

      setState(() {
        _isUploadingSecondary = false;
        if (!_images.contains(uploadedUrl)) {
          _images.add(uploadedUrl);
          if (_mainImageUrl.isEmpty) {
            _mainImageUrl = uploadedUrl;
          }
        }
      });

      widget.onChanged(_images, _mainImageUrl);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingSecondary = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du téléversement : $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _setAsMainImage(String url) {
    setState(() {
      _mainImageUrl = url;
      if (!_images.contains(url)) {
        _images.insert(0, url);
      }
    });
    widget.onChanged(_images, _mainImageUrl);
  }

  void _removeImage(String url) {
    setState(() {
      _images.remove(url);
      if (_mainImageUrl == url) {
        _mainImageUrl = _images.isNotEmpty ? _images.first : '';
      }
    });
    widget.onChanged(_images, _mainImageUrl);
  }

  List<String> get _secondaryImages =>
      _images.where((img) => img != _mainImageUrl && img.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = theme.textTheme.bodySmall?.color
            ?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. IMAGE PRINCIPALE ──
        AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary
                          .withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Image Principale (Couverture)",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleSmall?.color ??
                            theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (_mainImageUrl.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981)
                            .withValues(alpha: isDark ? 0.25 : 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Définie",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (_isUploadingMain)
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.colorScheme.surfaceContainerHighest
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: dividerColor),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Téléversement de l'image...",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_mainImageUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 170,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerHighest
                          : AppColors.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: dividerColor),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          _mainImageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              size: 36,
                              color: theme.iconTheme.color
                                      ?.withValues(alpha: 0.5) ??
                                  AppColors.icon,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _removeImage(_mainImageUrl),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _pickAndUploadMainImage,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text(
                    "Changer l'image principale",
                    style: TextStyle(fontSize: 12.5),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ] else ...[
                GestureDetector(
                  onTap: _pickAndUploadMainImage,
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerHighest
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
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
                            "Sélectionner l'image principale",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Depuis votre galerie photo",
                            style: TextStyle(
                              fontSize: 11,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── 2. IMAGES SECONDAIRES ──
        AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color:
                          AppColors.teal.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      size: 16,
                      color: AppColors.teal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Images Secondaires (Galerie)",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleSmall?.color ??
                            theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerHighest
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${_secondaryImages.length} photo(s)",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Liste horizontale des images secondaires
              if (_secondaryImages.isNotEmpty) ...[
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _secondaryImages.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final url = _secondaryImages[index];

                      return Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: dividerColor),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        Container(
                                  color: isDark
                                      ? theme
                                          .colorScheme.surfaceContainerHighest
                                      : AppColors.surfaceVariant,
                                  child: Icon(
                                    Icons.broken_image_rounded,
                                    color: theme.iconTheme.color
                                            ?.withValues(alpha: 0.5) ??
                                        AppColors.icon,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                            // Bouton Définir Principale
                            Positioned(
                              bottom: 4,
                              left: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _setAsMainImage(url),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "Définir princ.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Bouton Supprimer
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(url),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (_isUploadingSecondary)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Téléversement de l'image secondaire...",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: _pickAndUploadSecondaryImage,
                  icon: const Icon(Icons.add_photo_alternate_rounded,
                      size: 18),
                  label: const Text(
                    "Ajouter une image secondaire",
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(
                        color: theme.colorScheme.primary, width: 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size.fromHeight(44),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
