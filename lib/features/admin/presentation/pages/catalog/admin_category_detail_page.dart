import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/core/router/app_routes.dart';
import 'package:eveilkid/features/categories/models/categorie.dart';
import 'package:eveilkid/features/categories/providers/categorie_provider.dart';
import 'package:eveilkid/features/jouets/models/jouet.dart';
import 'package:eveilkid/features/jouets/providers/jouet_provider.dart';
import 'package:eveilkid/shared/widgets/app_button.dart';
import 'package:eveilkid/shared/widgets/app_card.dart';
import 'package:eveilkid/shared/widgets/app_dialogs.dart';
import 'package:eveilkid/shared/widgets/app_switch_tile.dart';
import 'package:eveilkid/shared/widgets/app_text_field.dart';

/// Page complète de Détails & Modification de Catégorie.
class AdminCategoryDetailPage extends ConsumerStatefulWidget {
  final Categorie? categorieToEdit;

  const AdminCategoryDetailPage({
    super.key,
    this.categorieToEdit,
  });

  @override
  ConsumerState<AdminCategoryDetailPage> createState() =>
      _AdminCategoryDetailPageState();
}

class _AdminCategoryDetailPageState
    extends ConsumerState<AdminCategoryDetailPage> {
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

  Future<void> _confirmDelete() async {
    final confirmed = await AppDialogs.showConfirmDialog(
      context: context,
      title: "Supprimer la catégorie",
      message:
          "Êtes-vous sûr de vouloir supprimer définitivement la catégorie \"${widget.categorieToEdit!.nom}\" ?",
      confirmText: "Supprimer",
      cancelText: "Annuler",
      isDanger: true,
    );

    if (confirmed == true && mounted) {
      try {
        final repo = ref.read(categorieRepositoryProvider);
        await repo.supprimerCategorie(widget.categorieToEdit!.categorieId);
        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF10B981),
              content: Text("Catégorie supprimée avec succès."),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.error,
              content: Text("Erreur lors de la suppression : $e"),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allProducts = ref.watch(jouetsAdminStreamProvider).value ?? [];
    final associatedProducts = _isEditing
        ? allProducts
            .where((j) => j.categorieId == widget.categorieToEdit!.categorieId)
            .toList()
        : <Jouet>[];

    final theme = Theme.of(context);
    final titleColor = theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface;
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else if (context.mounted) {
          context.go(AppRoutes.adminCategories);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            _isEditing ? "Détails de la catégorie" : "Nouvelle catégorie",
            style: TextStyle(
              color: titleColor,
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
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go(AppRoutes.adminCategories);
              }
            },
          ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
              tooltip: "Supprimer la catégorie",
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── APERÇU DE LA CATÉGORIE ──
              _buildHeaderPreview(context),
              AppSpacing.verticalMd,

              // ── INFORMATIONS PRINCIPALES ──
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Informations générales",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Nom
                    AppTextField(
                      controller: _nomController,
                      label: "Nom de la catégorie *",
                      hintText: "ex: Puzzles & Jeux éducatifs",
                      prefixIcon: Icons.category_outlined,
                      onChanged: (val) => setState(() {}),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Le nom de la catégorie est obligatoire.";
                        }
                        return null;
                      },
                    ),
                    AppSpacing.verticalMd,

                    // URL Icône / Image
                    AppTextField(
                      controller: _iconeUrlController,
                      label: "URL de l'icône ou illustration",
                      hintText: "https://...",
                      prefixIcon: Icons.image_outlined,
                      onChanged: (val) => setState(() {}),
                    ),
                    AppSpacing.verticalMd,

                    // Switch actif
                    AppSwitchTile(
                      title: "Catégorie active",
                      subtitle: "Rendre visible par les utilisateurs dans la boutique",
                      value: _estActive,
                      onChanged: (val) => setState(() => _estActive = val),
                    ),
                  ],
                ),
              ),

              // ── SECTION PRODUITS ASSOCIÉS ──
              if (_isEditing) ...[
                AppSpacing.verticalMd,
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Produits associés (${associatedProducts.length})",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                          ),
                          InkWell(
                            onTap: () => context.push(AppRoutes.adminProductForm),
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_rounded, size: 16, color: theme.colorScheme.primary),
                                  const SizedBox(width: 2),
                                  Text(
                                    "Ajouter",
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (associatedProducts.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          alignment: Alignment.center,
                          child: Text(
                            "Aucun produit dans cette catégorie pour le moment.",
                            style: TextStyle(
                              fontSize: 12.5,
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
                                  AppColors.textSecondary,
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: associatedProducts.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 12, color: dividerColor),
                          itemBuilder: (context, index) {
                            final jouet = associatedProducts[index];
                            return InkWell(
                              onTap: () {
                                context.push(
                                  AppRoutes.adminProductForm,
                                  extra: jouet,
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: theme.brightness == Brightness.dark
                                            ? theme.colorScheme.surfaceContainerHighest
                                            : AppColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: jouet.imagePrincipaleUrl.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: Image.network(
                                                jouet.imagePrincipaleUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Icon(
                                                  Icons.toys_outlined,
                                                  size: 16,
                                                  color: theme.iconTheme.color?.withValues(alpha: 0.5) ??
                                                      AppColors.icon,
                                                ),
                                              ),
                                            )
                                          : Icon(
                                              Icons.toys_outlined,
                                              size: 16,
                                              color: theme.colorScheme.primary,
                                            ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            jouet.nom,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: titleColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "${jouet.prix.toStringAsFixed(0)} ${jouet.devise} • Stock : ${jouet.stockDisponible}",
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
                                                  AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: theme.iconTheme.color?.withValues(alpha: 0.5) ??
                                          AppColors.icon,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],

              AppSpacing.verticalLg,

              // ── BOUTON ENREGISTRER ──
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: _isEditing ? "Enregistrer les modifications" : "Créer la catégorie",
                  isLoading: _isLoading,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  /// Carte d'aperçu d'en-tête dynamique
  Widget _buildHeaderPreview(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);
    final titleColor = theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface;
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);

    final iconUrl = _iconeUrlController.text.trim();
    final hasIcon = iconUrl.isNotEmpty;
    final nomAffiche = _nomController.text.trim().isNotEmpty
        ? _nomController.text.trim()
        : "Nouvelle Catégorie";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dividerColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _estActive
                  ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1)
                  : (isDark ? theme.colorScheme.surfaceContainerHighest : AppColors.surfaceVariant),
              borderRadius: BorderRadius.circular(10),
            ),
            child: hasIcon
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      iconUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.category_outlined,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                  )
                : Icon(
                    Icons.category_outlined,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nomAffiche,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _isEditing
                      ? "${widget.categorieToEdit!.nombreJouetsDenormalise} produit(s) associés"
                      : "Aperçu de la nouvelle catégorie",
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (_estActive ? const Color(0xFF10B981) : textSecondary)
                  .withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _estActive ? "Active" : "Inactive",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _estActive ? const Color(0xFF10B981) : textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
