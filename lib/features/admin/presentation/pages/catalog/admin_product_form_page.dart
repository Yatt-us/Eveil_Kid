import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/shared/widgets/app_button.dart';
import 'package:eveilkid/shared/widgets/app_dropdown.dart';
import 'package:eveilkid/shared/widgets/app_switch_tile.dart';
import 'package:eveilkid/shared/widgets/app_text_field.dart';
import '../../widgets/admin_multi_image_input.dart';

class AdminProductFormPage extends ConsumerStatefulWidget {
  final Jouet? jouetToEdit;

  const AdminProductFormPage({
    super.key,
    this.jouetToEdit,
  });

  @override
  ConsumerState<AdminProductFormPage> createState() =>
      _AdminProductFormPageState();
}

class _AdminProductFormPageState extends ConsumerState<AdminProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomController;
  late TextEditingController _descriptionController;
  late TextEditingController _prixController;
  late TextEditingController _deviseController;
  late TextEditingController _stockController;
  late TextEditingController _ageMinController;
  late TextEditingController _ageMaxController;

  String? _selectedCategorieId;
  String _selectedCategorieNom = '';
  List<String> _images = [];
  String _imagePrincipaleUrl = '';
  bool _estActif = true;
  bool _estPopulaire = false;
  bool _isLoading = false;

  bool get _isEditing => widget.jouetToEdit != null;

  @override
  void initState() {
    super.initState();
    final j = widget.jouetToEdit;
    _nomController = TextEditingController(text: j?.nom ?? '');
    _descriptionController = TextEditingController(text: j?.description ?? '');
    _prixController = TextEditingController(
        text: j != null ? j.prix.toStringAsFixed(0) : '');
    _deviseController = TextEditingController(text: j?.devise ?? 'FCFA');
    _stockController = TextEditingController(
        text: j != null ? j.stockDisponible.toString() : '0');
    _ageMinController = TextEditingController(
        text: j != null ? j.ageMinimum.toString() : '1');
    _ageMaxController = TextEditingController(
        text: j != null ? j.ageMaximum.toString() : '6');

    _selectedCategorieId = j?.categorieId;
    _selectedCategorieNom = j?.nomCategorieDenormalise ?? '';
    _images = j != null ? List<String>.from(j.images) : [];
    _imagePrincipaleUrl = j?.imagePrincipaleUrl ?? '';
    _estActif = j?.estActif ?? true;
    _estPopulaire = j?.estPopulaire ?? false;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    _deviseController.dispose();
    _stockController.dispose();
    _ageMinController.dispose();
    _ageMaxController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategorieId == null || _selectedCategorieId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.warning,
          content: Text("Veuillez sélectionner une catégorie."),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(jouetRepositoryProvider);
      final catRepo = ref.read(categorieRepositoryProvider);

      final String id = widget.jouetToEdit?.jouetId ??
          FirebaseFirestore.instance.collection('jouets').doc().id;

      final double prix = double.tryParse(_prixController.text.trim()) ?? 0.0;
      final int stock = int.tryParse(_stockController.text.trim()) ?? 0;
      final int ageMin = int.tryParse(_ageMinController.text.trim()) ?? 0;
      final int ageMax = int.tryParse(_ageMaxController.text.trim()) ?? 99;

      final updatedJouet = Jouet(
        jouetId: id,
        categorieId: _selectedCategorieId!,
        createurId: widget.jouetToEdit?.createurId ?? 'manager_admin',
        nom: _nomController.text.trim(),
        description: _descriptionController.text.trim(),
        nomCategorieDenormalise: _selectedCategorieNom,
        images: _images,
        imagePrincipaleUrl: _imagePrincipaleUrl.isNotEmpty
            ? _imagePrincipaleUrl
            : (_images.isNotEmpty ? _images.first : ''),
        ageMinimum: ageMin,
        ageMaximum: ageMax,
        prix: prix,
        devise: _deviseController.text.trim().isNotEmpty
            ? _deviseController.text.trim()
            : 'FCFA',
        stock: stock,
        stockDisponible: stock,
        noteMoyenneDenormalise:
            widget.jouetToEdit?.noteMoyenneDenormalise ?? 0.0,
        nombreAvisDenormalise: widget.jouetToEdit?.nombreAvisDenormalise ?? 0,
        nbTutorielsAssocies: widget.jouetToEdit?.nbTutorielsAssocies ?? 0,
        estActif: _estActif,
        estPopulaire: _estPopulaire,
        dateCreation: widget.jouetToEdit?.dateCreation ?? Timestamp.now(),
        dateModification: Timestamp.now(),
      );

      if (_isEditing) {
        await repo.modifierJouet(updatedJouet);

        // Si la catégorie a changé, mettre à jour les compteurs
        if (widget.jouetToEdit!.categorieId != _selectedCategorieId) {
          await catRepo.incrementerNombreJouets(
              widget.jouetToEdit!.categorieId, -1);
          await catRepo.incrementerNombreJouets(_selectedCategorieId!, 1);
        }
      } else {
        await repo.ajouterJouet(updatedJouet);
        await catRepo.incrementerNombreJouets(_selectedCategorieId!, 1);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            content: Text(_isEditing
                ? "Produit mis à jour avec succès !"
                : "Nouveau produit ajouté au catalogue !"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.danger,
            content: Text("Erreur lors de l'enregistrement: $e"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesAdminStreamProvider);
    final List<Categorie> categories = categoriesAsync.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditing ? "Modifier le produit" : "Ajouter un produit",
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations Générales
              _buildSectionTitle("Informations Générales"),
              AppSpacing.verticalSm,
              AppTextField(
                controller: _nomController,
                label: "Nom du produit *",
                hintText: "ex: Puzzle en bois Montessori",
                prefixIcon: Icons.shopping_bag_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Le nom est obligatoire.";
                  }
                  return null;
                },
              ),
              AppSpacing.verticalMd,
              // Sélection de la catégorie
              AppDropdown<String>(
                label: "Catégorie du produit *",
                hintText: "Sélectionnez une catégorie",
                value: _selectedCategorieId,
                items: categories
                    .map((cat) => AppDropdownItem(
                          value: cat.categorieId,
                          label: cat.nom,
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    final selected =
                        categories.firstWhere((c) => c.categorieId == val);
                    setState(() {
                      _selectedCategorieId = val;
                      _selectedCategorieNom = selected.nom;
                    });
                  }
                },
              ),
              AppSpacing.verticalMd,
              // Description
              AppTextField(
                controller: _descriptionController,
                label: "Description du produit *",
                hintText: "Description pédagogique, matière, bénéfices pour l'enfant...",
                maxLines: 4,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "La description est obligatoire.";
                  }
                  return null;
                },
              ),
              AppSpacing.verticalLg,

              // Gestion Multi-images
              _buildSectionTitle("Galerie & Visuels"),
              AppSpacing.verticalSm,
              AdminMultiImageInput(
                initialImages: _images,
                initialMainImageUrl: _imagePrincipaleUrl,
                onChanged: (imgs, main) {
                  _images = imgs;
                  _imagePrincipaleUrl = main;
                },
              ),
              AppSpacing.verticalLg,

              // Tarification & Stock
              _buildSectionTitle("Tarification & Disponibilité"),
              AppSpacing.verticalSm,
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppTextField(
                      controller: _prixController,
                      label: "Prix *",
                      hintText: "ex: 12500",
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      prefixIcon: Icons.payments_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Requis.";
                        }
                        if (double.tryParse(val.trim()) == null) {
                          return "Invalide.";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _deviseController,
                      label: "Devise",
                      hintText: "FCFA",
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalMd,
              AppTextField(
                controller: _stockController,
                label: "Quantité en stock *",
                hintText: "ex: 25",
                keyboardType: TextInputType.number,
                prefixIcon: Icons.inventory_2_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return "Requis.";
                  if (int.tryParse(val.trim()) == null) return "Nombre entier.";
                  return null;
                },
              ),
              AppSpacing.verticalLg,

              // Tranche d'Âge
              _buildSectionTitle("Tranche d'âge recommandée"),
              AppSpacing.verticalSm,
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _ageMinController,
                      label: "Âge minimum (ans)",
                      hintText: "ex: 2",
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.child_care,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _ageMaxController,
                      label: "Âge maximum (ans)",
                      hintText: "ex: 6",
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.escalator_warning,
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalLg,

              // Options & Statuts
              _buildSectionTitle("Statut & Mise en avant"),
              AppSpacing.verticalSm,
              AppSwitchTile(
                title: "Produit Actif",
                subtitle: "Visible à l'achat dans la boutique de l'application",
                value: _estActif,
                onChanged: (val) => setState(() => _estActif = val),
              ),
              AppSpacing.verticalSm,
              AppSwitchTile(
                title: "Produit Populaire ⭐",
                subtitle: "Afficher dans les recommandations phares",
                value: _estPopulaire,
                onChanged: (val) => setState(() => _estPopulaire = val),
              ),
              AppSpacing.verticalHuge,

              // Bouton d'enregistrement
              AppButton(
                text: _isEditing ? "Enregistrer les modifications" : "Ajouter le produit",
                icon: Icons.check_circle_outline,
                isLoading: _isLoading,
                size: AppButtonSize.large,
                onPressed: _submit,
              ),
              AppSpacing.verticalXxl,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}
