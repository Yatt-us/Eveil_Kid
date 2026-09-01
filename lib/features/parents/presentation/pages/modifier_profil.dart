// lib/features/parents/presentation/pages/modifier_profil.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_avatars.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../auth/models/utilisateur.dart';
import '../../providers/parent_provider.dart';

class ModifierProfilPage extends ConsumerStatefulWidget {
  final Utilisateur parent;

  const ModifierProfilPage({super.key, required this.parent});

  @override
  ConsumerState<ModifierProfilPage> createState() => _ModifierProfilPageState();
}

class _ModifierProfilPageState extends ConsumerState<ModifierProfilPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _emailController;
  late TextEditingController _telController;
  late TextEditingController _adresseController;

  String? _photoUrl;
  bool _isLoading = false;

  final List<String> _presetAvatars = AppAvatars.parentPresets;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.parent.name);
    _emailController = TextEditingController(text: widget.parent.email);
    _telController = TextEditingController(text: widget.parent.telephone ?? '');
    _adresseController = TextEditingController(text: widget.parent.adresse ?? '');
    _photoUrl = widget.parent.photoUrl;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Fermer le bottom sheet

    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 360,
        maxHeight: 360,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _photoUrl = base64String;
        });
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Impossible de charger l\'image: $e',
          isError: true,
        );
      }
    }
  }

  void _showAvatarGalleryModal() {
    Navigator.pop(context); // Fermer le menu précédent
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                AppSpacing.verticalMd,
                Text(
                  'Choisir un avatar prédéfini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleMedium?.color ??
                        theme.colorScheme.onSurface,
                  ),
                ),
                AppSpacing.verticalMd,
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presetAvatars.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final url = _presetAvatars[index];
                      final isSelected = _photoUrl == url;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _photoUrl = url);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 34,
                            backgroundImage: NetworkImage(url),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                AppSpacing.verticalMd,
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPhotoOptionsSheet() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                AppSpacing.verticalMd,
                Text(
                  'Photo de profil',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleMedium?.color ??
                        theme.colorScheme.onSurface,
                  ),
                ),
                AppSpacing.verticalMd,
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.camera_alt_rounded, color: theme.colorScheme.primary),
                  ),
                  title: const Text('Prendre une photo', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                    child: const Icon(Icons.photo_library_rounded, color: AppColors.secondary),
                  ),
                  title: const Text('Choisir depuis la galerie', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber.withValues(alpha: 0.15),
                    child: const Icon(Icons.face_retouching_natural_rounded, color: Colors.amber),
                  ),
                  title: const Text('Choisir parmi les avatars prédéfinis', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: _showAvatarGalleryModal,
                ),
                if (_photoUrl != null && _photoUrl!.isNotEmpty) ...[
                  const Divider(),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.error.withValues(alpha: 0.1),
                      child: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                    ),
                    title: Text(
                      'Supprimer la photo actuelle',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      setState(() => _photoUrl = null);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updated = widget.parent.copyWith(
      nom: _nomController.text.trim(),
      email: _emailController.text.trim(),
      telephone: _telController.text.trim(),
      adresse: _adresseController.text.trim(),
      photoUrl: _photoUrl,
    );

    try {
      await ref
          .read(parentNotifierProvider.notifier)
          .updateParentProfile(updated);
      if (mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Profil mis à jour avec succès !',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Erreur: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Modifier mon profil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleMedium?.color ??
                theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppPadding.screenLarge,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppSpacing.verticalSm,

              // --- AVATAR DU PROFIL AVEC BOUTON MODIFICATION ---
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AppAvatar(
                      imageUrl: _photoUrl,
                      name: _nomController.text.isNotEmpty ? _nomController.text : widget.parent.name,
                      radius: 50,
                      onTap: _showPhotoOptionsSheet,
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: GestureDetector(
                        onTap: _showPhotoOptionsSheet,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalXs,
              TextButton(
                onPressed: _showPhotoOptionsSheet,
                child: Text(
                  'Modifier la photo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              AppSpacing.verticalLg,

              // --- CHAMP NOM COMPLET ---
              _buildFieldContainer(
                context: context,
                label: 'Nom complet',
                icon: Icons.person_outline_rounded,
                child: TextFormField(
                  controller: _nomController,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color ??
                        theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Votre nom complet',
                    hintStyle: TextStyle(
                      color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.4) ??
                          theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nom requis' : null,
                ),
              ),
              AppSpacing.verticalMd,

              // --- CHAMP EMAIL ---
              _buildFieldContainer(
                context: context,
                label: 'Adresse email',
                icon: Icons.mail_outline_rounded,
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color ??
                        theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'exemple@email.com',
                    hintStyle: TextStyle(
                      color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.4) ??
                          theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email requis';
                    if (!v.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
              ),
              AppSpacing.verticalMd,

              // --- CHAMP TÉLÉPHONE ---
              _buildFieldContainer(
                context: context,
                label: 'Numéro de téléphone',
                icon: Icons.phone_outlined,
                child: TextFormField(
                  controller: _telController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color ??
                        theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: '+223 ...',
                    hintStyle: TextStyle(
                      color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.4) ??
                          theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              AppSpacing.verticalMd,

              // --- CHAMP ADRESSE DE RÉSIDENCE / LIVRAISON ---
              _buildFieldContainer(
                context: context,
                label: 'Adresse de résidence / livraison',
                icon: Icons.location_on_outlined,
                child: TextFormField(
                  controller: _adresseController,
                  keyboardType: TextInputType.streetAddress,
                  maxLines: 2,
                  minLines: 1,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color ??
                        theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Ex: Bamako, Hamdallaye ACI 2000, Rue 310, Porte 45',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.4) ??
                          theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              AppSpacing.verticalXxl,

              // --- BOUTON ENREGISTRER ---
              AppButton(
                text: 'Enregistrer les modifications',
                size: AppButtonSize.large,
                isLoading: _isLoading,
                onPressed: _save,
              ),
              AppSpacing.verticalXl,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldContainer({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 14),
            child: Icon(
              icon,
              size: 22,
              color: theme.colorScheme.primary.withValues(alpha: 0.8),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.8) ??
                        theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                child,
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
