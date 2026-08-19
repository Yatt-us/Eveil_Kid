import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/shared/widgets/app_button.dart';
import 'package:eveilkid/shared/widgets/app_dropdown.dart';
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
  String? _selectedParentId;
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
    _selectedParentId = cat?.parentId;
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
        parentId: _selectedParentId,
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
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
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
            content: Text("Erreur : $e"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allCategories =
        ref.watch(categoriesAdminStreamProvider).value ?? [];
    // Filtrer pour ne pas permettre de choisir la catégorie elle-même comme parent
    final potentialParents = allCategories
        .where((c) =>
            c.parentId == null &&
            (!_isEditing || c.categorieId != widget.categorieToEdit!.categorieId))
        .toList();

    return Dialog(
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
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isEditing
                            ? "Modifier la catégorie"
                            : "Nouvelle catégorie",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Divider(height: 20, color: AppColors.border),
                // Nom de la catégorie
                AppTextField(
                  controller: _nomController,
                  label: "Nom de la catégorie *",
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
                // Catégorie parente optionnelle
                AppDropdown<String?>(
                  label: "Catégorie parente (Optionnelle)",
                  hintText: "Aucune (Catégorie principale)",
                  value: _selectedParentId,
                  items: [
                    const AppDropdownItem(
                      value: null,
                      label: "Aucune (Catégorie principale)",
                    ),
                    ...potentialParents.map(
                      (cat) => AppDropdownItem(
                        value: cat.categorieId,
                        label: cat.nom,
                      ),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedParentId = val),
                ),
                AppSpacing.verticalMd,
                // URL de l'icône
                AppTextField(
                  controller: _iconeUrlController,
                  label: "URL de l'icône (Optionnel)",
                  hintText: "https://...",
                  prefixIcon: Icons.image_outlined,
                ),
                AppSpacing.verticalMd,
                // Statut Actif
                AppSwitchTile(
                  title: "Catégorie active",
                  subtitle: "Visible par les utilisateurs dans l'application",
                  value: _estActive,
                  onChanged: (val) => setState(() => _estActive = val),
                ),
                AppSpacing.verticalLg,
                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: "Annuler",
                        variant: AppButtonVariant.outlined,
                        onPressed: () => Navigator.of(context).pop(),
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
