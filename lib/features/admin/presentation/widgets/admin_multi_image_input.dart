import 'package:flutter/material.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/shared/widgets/app_button.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';
import 'package:eveilkid/shared/widgets/app_text_field.dart';

/// Composant moderne et ergonomique pour la gestion de l'image principale
/// et de la galerie d'images secondaires d'un produit.
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
  final TextEditingController _mainUrlController = TextEditingController();
  final TextEditingController _secondaryUrlController = TextEditingController();
  bool _isAddingSecondary = false;

  @override
  void initState() {
    super.initState();
    _images = List<String>.from(widget.initialImages);
    _mainImageUrl = widget.initialMainImageUrl.trim().isNotEmpty
        ? widget.initialMainImageUrl.trim()
        : (_images.isNotEmpty ? _images.first : '');

    _mainUrlController.text = _mainImageUrl;
    _mainUrlController.addListener(_onMainUrlChanged);
  }

  @override
  void dispose() {
    _mainUrlController.removeListener(_onMainUrlChanged);
    _mainUrlController.dispose();
    _secondaryUrlController.dispose();
    super.dispose();
  }

  void _onMainUrlChanged() {
    final text = _mainUrlController.text.trim();
    if (text != _mainImageUrl) {
      setState(() {
        _mainImageUrl = text;
        if (text.isNotEmpty && !_images.contains(text)) {
          _images.insert(0, text);
        }
      });
      widget.onChanged(_images, _mainImageUrl);
    }
  }

  void _addSecondaryImage() {
    final url = _secondaryUrlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      if (!_images.contains(url)) {
        _images.add(url);
        if (_mainImageUrl.isEmpty) {
          _mainImageUrl = url;
          _mainUrlController.text = url;
        }
      }
      _secondaryUrlController.clear();
      _isAddingSecondary = false;
    });
    widget.onChanged(_images, _mainImageUrl);
  }

  void _setAsMainImage(String url) {
    setState(() {
      _mainImageUrl = url;
      _mainUrlController.text = url;
      if (!_images.contains(url)) {
        _images.insert(0, url);
      }
    });
    widget.onChanged(_images, _mainImageUrl);
  }

  void _removeSecondaryImage(String url) {
    setState(() {
      _images.remove(url);
      if (_mainImageUrl == url) {
        _mainImageUrl = _images.isNotEmpty ? _images.first : '';
        _mainUrlController.text = _mainImageUrl;
      }
    });
    widget.onChanged(_images, _mainImageUrl);
  }

  List<String> get _secondaryImages =>
      _images.where((img) => img != _mainImageUrl && img.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. CARTE IMAGE PRINCIPALE ──
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
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Image Principale (Couverture)",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
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
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Définie",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Aperçu de l'image principale
              if (_mainImageUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 170,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          _mainImageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.broken_image_rounded,
                                    size: 36, color: AppColors.icon),
                                SizedBox(height: 4),
                                Text(
                                  "URL d'image invalide ou inaccessible",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _images.remove(_mainImageUrl);
                                _mainImageUrl =
                                    _images.isNotEmpty ? _images.first : '';
                                _mainUrlController.text = _mainImageUrl;
                              });
                              widget.onChanged(_images, _mainImageUrl);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Champ d'URL de l'image principale
              AppTextField(
                controller: _mainUrlController,
                hintText: "URL de l'image principale (https://...)",
                prefixIcon: Icons.link_rounded,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── 2. CARTE IMAGES SECONDAIRES ──
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
                      color: AppColors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      size: 16,
                      color: AppColors.teal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Images Secondaires (Galerie)",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${_secondaryImages.length} photo(s)",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
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
                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final url = _secondaryImages[index];

                      return Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: AppColors.surfaceVariant,
                                  child: const Icon(
                                    Icons.broken_image_rounded,
                                    color: AppColors.icon,
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
                                    color: AppColors.textPrimary
                                        .withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "Définir princ.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
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
                                onTap: () => _removeSecondaryImage(url),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: AppColors.danger,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 11,
                                    color: AppColors.white,
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

              // Champ d'ajout d'image secondaire
              if (_isAddingSecondary) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _secondaryUrlController,
                        hintText: "URL de l'image secondaire (https://...)",
                        prefixIcon: Icons.add_link_rounded,
                        onSubmitted: (_) => _addSecondaryImage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 46,
                      child: AppButton(
                        text: "Valider",
                        onPressed: _addSecondaryImage,
                        isFullWidth: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => _isAddingSecondary = false),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text(
                      "Annuler",
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ] else ...[
                OutlinedButton.icon(
                  onPressed: () => setState(() => _isAddingSecondary = true),
                  icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                  label: const Text(
                    "Ajouter une image secondaire",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size.fromHeight(44),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
