import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
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
  late TextEditingController _iconeUrlController;
  late TextEditingController _imageUrlController;
  bool _estActive = true;
  bool _isLoading = false;

  bool get _isEditing => widget.categorieToEdit != null;

  @override
  void initState() {
    super.initState();
    final cat = widget.categorieToEdit;
    _nomController = TextEditingController(text: cat?.nom ?? '');
    _iconeUrlController = TextEditingController(text: cat?.iconeUrl ?? '');
    _imageUrlController = TextEditingController(text: cat?.imageUrl ?? '');
    _estActive = cat?.estActive ?? true;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _iconeUrlController.dispose();
    _imageUrlController.dispose();
    super.dispose();
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
        iconeUrl: _iconeUrlController.text.trim().isNotEmpty
            ? _iconeUrlController.text.trim()
            : null,
        imageUrl: _imageUrlController.text.trim().isNotEmpty
            ? _imageUrlController.text.trim()
            : null,
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
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text("Erreur : $e"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  children: [
                    Icon(
                      _isEditing ? Icons.edit : Icons.add_circle_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
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
                AppTextField(
                  controller: _iconeUrlController,
                  labelText: "URL de l'icône (Optionnel)",
                  hintText: "https://...",
                  prefixIcon: Icons.image_outlined,
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
