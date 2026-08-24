import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/shared/widgets/app_button.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';
import 'package:eveilkid/shared/widgets/app_dropdown.dart';
import 'package:eveilkid/shared/widgets/app_switch_tile.dart';
import 'package:eveilkid/shared/widgets/app_text_field.dart';
import '../../widgets/admin_multi_image_input.dart';

/// Page d'ajout et de modification d'un produit du catalogue.
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
      text: j != null ? j.prix.toStringAsFixed(0) : '',
    );
    _deviseController = TextEditingController(text: j?.devise ?? 'FCFA');
    _stockController = TextEditingController(
      text: j != null ? j.stockDisponible.toString() : '0',
    );
    _ageMinController = TextEditingController(
      text: j != null ? j.ageMinimum.toString() : '1',
    );
    _ageMaxController = TextEditingController(
      text: j != null ? j.ageMaximum.toString() : '6',
    );

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
    if (!_formKey.currentState!.validate()) {
      AppDialogs.showSnackBar(
        context: context,
        message: "Veuillez corriger les champs requis du formulaire.",
      );
      return;
    }

    if (_selectedCategorieId == null || _selectedCategorieId!.isEmpty) {
      AppDialogs.showSnackBar(
        context: context,
        message: "Veuillez sélectionner une catégorie pour le produit.",
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

      // Détermination de l'image principale finale
      final effectiveMainImage = _imagePrincipaleUrl.trim().isNotEmpty
          ? _imagePrincipaleUrl.trim()
          : (_images.isNotEmpty ? _images.first : '');

      // Synchronisation : s'assurer que l'image principale fait partie de la liste
      final effectiveImages = List<String>.from(_images);
      if (effectiveMainImage.isNotEmpty &&
          !effectiveImages.contains(effectiveMainImage)) {
        effectiveImages.insert(0, effectiveMainImage);
      }

      final updatedJouet = Jouet(
        jouetId: id,
        categorieId: _selectedCategorieId!,
        createurId: widget.jouetToEdit?.createurId ?? 'manager_admin',
        nom: _nomController.text.trim(),
        description: _descriptionController.text.trim(),
        nomCategorieDenormalise: _selectedCategorieNom,
        images: effectiveImages,
        imagePrincipaleUrl: effectiveMainImage,
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

        if (widget.jouetToEdit!.categorieId != _selectedCategorieId) {
          await catRepo.incrementerNombreJouets(
            widget.jouetToEdit!.categorieId,
            -1,
          );
          await catRepo.incrementerNombreJouets(_selectedCategorieId!, 1);
        }
      } else {
        await repo.ajouterJouet(updatedJouet);
        await catRepo.incrementerNombreJouets(_selectedCategorieId!, 1);
      }

      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.adminProducts);
        }
        AppDialogs.showSnackBar(
          context: context,
          message: _isEditing
              ? "Produit mis à jour avec succès !"
              : "Nouveau produit ajouté au catalogue !",
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppDialogs.showSnackBar(
          context: context,
          message: "Erreur lors de l'enregistrement : $e",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesAdminStreamProvider);
    final List<Categorie> categories = categoriesAsync.value ?? [];
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? "Modifier le produit" : "Nouveau Produit",
          style: TextStyle(
            color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.adminProducts);
            }
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: isWide
                  ? _buildWideForm(categories)
                  : _buildStandardForm(categories),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStandardForm(List<Categorie> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGeneralInfoSection(categories),
        AppSpacing.verticalMd,
        _buildMediaSection(),
        AppSpacing.verticalMd,
        _buildPricingAndStockSection(),
        AppSpacing.verticalMd,
        _buildAgeSection(),
        AppSpacing.verticalMd,
        _buildStatusSection(),
        AppSpacing.verticalXl,
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildWideForm(List<Categorie> categories) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _buildGeneralInfoSection(categories),
                  AppSpacing.verticalMd,
                  _buildMediaSection(),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _buildPricingAndStockSection(),
                  AppSpacing.verticalMd,
                  _buildAgeSection(),
                  AppSpacing.verticalMd,
                  _buildStatusSection(),
                ],
              ),
            ),
          ],
        ),
        AppSpacing.verticalXl,
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildGeneralInfoSection(List<Categorie> categories) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      title: "1. Informations Générales",
      subtitle: "Nom, catégorie et description détaillée",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: _nomController,
            label: "Nom du produit *",
            hintText: "ex: Tour d'empilement arc-en-ciel",
            prefixIcon: Icons.toys_outlined,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return "Le nom du produit est obligatoire.";
              }
              return null;
            },
          ),
          AppSpacing.verticalMd,
          AppDropdown<String>(
            label: "Catégorie du produit *",
            hintText: "Sélectionnez une catégorie",
            value: _selectedCategorieId,
            items: categories
                .map(
                  (cat) => AppDropdownItem(
                    value: cat.categorieId,
                    label: cat.nom,
                  ),
                )
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
          AppTextField(
            controller: _descriptionController,
            label: "Description du produit *",
            hintText:
                "Matière, bénéfices pour l'enfant, règles de sécurité...",
            maxLines: 4,
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return "La description est obligatoire.";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      title: "2. Visuels & Galerie Photos",
      subtitle: "Image principale (couverture) et images secondaires",
      child: AdminMultiImageInput(
        initialImages: _images,
        initialMainImageUrl: _imagePrincipaleUrl,
        onChanged: (imgs, main) {
          _images = imgs;
          _imagePrincipaleUrl = main;
        },
      ),
    );
  }

  Widget _buildPricingAndStockSection() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      title: "3. Tarification & Stock",
      subtitle: "Prix unitaire et quantité disponible",
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AppTextField(
                  controller: _prixController,
                  label: "Prix *",
                  hintText: "ex: 15000",
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixIcon: Icons.payments_outlined,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Requis.";
                    }
                    if (double.tryParse(val.trim()) == null) {
                      return "Nombre invalide.";
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
            label: "Quantité en stock disponible *",
            hintText: "ex: 20",
            keyboardType: TextInputType.number,
            prefixIcon: Icons.inventory_2_outlined,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return "Requis.";
              if (int.tryParse(val.trim()) == null) return "Nombre entier.";
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAgeSection() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      title: "4. Tranche d'Âge Pédagogique",
      subtitle: "Recommandations selon le développement de l'enfant",
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              controller: _ageMinController,
              label: "Âge minimum (ans)",
              hintText: "ex: 1",
              keyboardType: TextInputType.number,
              prefixIcon: Icons.child_care_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppTextField(
              controller: _ageMaxController,
              label: "Âge maximum (ans)",
              hintText: "ex: 6",
              keyboardType: TextInputType.number,
              prefixIcon: Icons.escalator_warning_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    final theme = Theme.of(context);
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);

    return AppCard(
      padding: const EdgeInsets.all(16),
      title: "5. Paramètres de Publication",
      subtitle: "Visibilité dans le catalogue et mise en vedette",
      child: Column(
        children: [
          AppSwitchTile(
            title: "Produit Actif",
            subtitle: "Visible et achetable dans la boutique par les parents",
            icon: Icons.visibility_rounded,
            value: _estActif,
            onChanged: (val) => setState(() => _estActif = val),
          ),
          Divider(height: 16, color: dividerColor),
          AppSwitchTile(
            title: "Produit Populaire ⭐",
            subtitle: "Afficher dans les sélections phares et recommandations",
            icon: Icons.star_rounded,
            value: _estPopulaire,
            onChanged: (val) => setState(() => _estPopulaire = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AppButton(
      text: _isEditing ? "Enregistrer les modifications" : "Créer le produit",
      icon: Icons.check_circle_outline_rounded,
      isLoading: _isLoading,
      size: AppButtonSize.large,
      onPressed: _submit,
    );
  }
}
