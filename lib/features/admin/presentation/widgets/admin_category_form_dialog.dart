import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eveilkid/core/cloudinary/cloudinary_service.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/shared/widgets/app_button.dart';
import 'package:eveilkid/shared/widgets/app_switch_tile.dart';
import 'package:eveilkid/shared/widgets/app_text_field.dart';

class AdminCategoryFormDialog extends ConsumerStatefulWidget {
  final Categorie? categorieToEdit;

  const AdminCategoryFormDialog({
    super.key,
    this.categorieToEdit,
  });

  @override
  ConsumerState<AdminCategoryFormDialog> createState() =>
      _AdminCategoryFormDialogState();
}

class _AdminCategoryFormDialogState
    extends ConsumerState<AdminCategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  String? _imageUrl;
  bool _estActive = true;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  final CloudinaryService _cloudinary = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  bool get _isEditing => widget.categorieToEdit != null;

  @override
  void initState() {
    super.initState();
    final cat = widget.categorieToEdit;
    _nomController = TextEditingController(text: cat?.nom ?? '');
    _imageUrl = cat?.imageUrl ?? cat?.iconeUrl;
    _estActive = cat?.estActive ?? true;
  }

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _isUploadingImage = true);

      final uploadedUrl = await _cloudinary.uploadImage(
        File(picked.path),
        folder: 'categories',
      );

      if (!mounted) return;

      setState(() {
        _isUploadingImage = false;
        _imageUrl = uploadedUrl;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du téléversement : $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(categorieRepositoryProvider);
      final String id = widget.categorieToEdit?.categorieId ??
          FirebaseFirestore.instance.collection('categories').doc().id;

      final updatedCategory = Categorie(
        categorieId: id,
        nom: _nomController.text.trim(),
        iconeUrl: _imageUrl,
        imageUrl: _imageUrl,
        nombreJouetsDenormalise:
            widget.categorieToEdit?.nombreJouetsDenormalise ?? 0,
        nbTutoriels: widget.categorieToEdit?.nbTutoriels ?? 0,
        estActive: _estActive,
        dateCreation: widget.categorieToEdit?.dateCreation ?? Timestamp.now(),
        dateModification: Timestamp.now(),
      );

      if (_isEditing) {
        await repo.modifierCategorie(updatedCategory);
      } else {
        await repo.ajouterCategorie(updatedCategory);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            content: Text(_isEditing
                ? "Catégorie modifiée avec succès !"
                : "Nouvelle catégorie créée avec succès !"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.danger,
            content: Text("Erreur lors de l'enregistrement : $e"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor:
          theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing
                            ? "Modifier la catégorie"
                            : "Nouvelle catégorie",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color ??
                              theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: theme.iconTheme.color?.withValues(alpha: 0.6),
                      ),
                      onPressed: () => context.pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                Divider(height: 20, color: dividerColor),
                AppTextField(
                  controller: _nomController,
                  labelText: "Nom de la catégorie *",
                  hintText: "ex: Puzzles & Éveil logique",
                  prefixIcon: Icons.label_outline,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Le nom de la catégorie est obligatoire.";
                    }
                    return null;
                  },
                ),
                AppSpacing.verticalMd,

                // Sélecteur d'image de la catégorie
                Text(
                  "Image / Icône de la catégorie",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyMedium?.color ??
                        theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                if (_isUploadingImage)
                  Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerHighest
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  )
                else if (_imageUrl != null && _imageUrl!.isNotEmpty)
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _imageUrl!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text("Changer l'image",
                                  style: TextStyle(fontSize: 12)),
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  setState(() => _imageUrl = null),
                              icon: const Icon(Icons.delete_outline,
                                  size: 16, color: Colors.redAccent),
                              label: const Text("Supprimer",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate_rounded,
                        size: 18),
                    label: const Text("Choisir une image depuis la galerie"),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                AppSpacing.verticalMd,
                AppSwitchTile(
                  title: "Catégorie active",
                  subtitle: "Visible par les utilisateurs dans l'application",
                  value: _estActive,
                  onChanged: (val) => setState(() => _estActive = val),
                ),
                AppSpacing.verticalLg,
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: "Annuler",
                        variant: AppButtonVariant.outlined,
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: _isEditing ? "Enregistrer" : "Créer",
                        isLoading: _isLoading,
                        onPressed: _save,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
