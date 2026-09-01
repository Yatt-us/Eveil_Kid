// lib/features/parents/presentation/pages/ajouter_enfant.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_avatars.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_date_picker.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/app_text_field.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import '../../providers/parent_provider.dart';

class AjouterEnfantPage extends ConsumerStatefulWidget {
  const AjouterEnfantPage({super.key});

  @override
  ConsumerState<AjouterEnfantPage> createState() => _AjouterEnfantPageState();
}

class _AjouterEnfantPageState extends ConsumerState<AjouterEnfantPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();

  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 5));
  String _selectedGenre = 'Garçon';
  String? _selectedAvatarUrl;
  final List<String> _selectedSouhaits = [];
  bool _isLoading = false;

  final List<String> _childPresetAvatars = AppAvatars.childPresets;

  final List<String> _availableSouhaits = [
    '🧩 Puzzles',
    '🤖 Robots & Tech',
    '🎨 Dessin & Arts',
    '📚 Livres & Contes',
    '🎵 Musique & Sons',
    '⚽ Sport & Plein air',
    '🔬 Découvertes',
    '🧱 Construction',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  int get _calculatedAge {
    final now = DateTime.now();
    var age = now.year - _selectedDate.year;
    if (now.month < _selectedDate.month ||
        (now.month == _selectedDate.month && now.day < _selectedDate.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  Future<void> _pickChildImage(ImageSource source) async {
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
          _selectedAvatarUrl = base64String;
        });
      }
    } catch (e) {
      if (mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Impossible de charger la photo: $e',
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
                  'Choisir un avatar enfant',
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
                    itemCount: _childPresetAvatars.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final url = _childPresetAvatars[index];
                      final isSelected = _selectedAvatarUrl == url;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedAvatarUrl = url);
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
                  'Photo de l\'enfant',
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
                  onTap: () => _pickChildImage(ImageSource.camera),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                    child: const Icon(Icons.photo_library_rounded, color: AppColors.secondary),
                  ),
                  title: const Text('Choisir depuis la galerie', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => _pickChildImage(ImageSource.gallery),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber.withValues(alpha: 0.15),
                    child: const Icon(Icons.face_retouching_natural_rounded, color: Colors.amber),
                  ),
                  title: const Text('Choisir parmi les avatars prédéfinis', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: _showAvatarGalleryModal,
                ),
                if (_selectedAvatarUrl != null && _selectedAvatarUrl!.isNotEmpty) ...[
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
                      setState(() => _selectedAvatarUrl = null);
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();

    setState(() => _isLoading = true);

    final newChild = EnfantModel.creerNouveau(
      utilisateurId: '',
      nom: name,
      dateNaissance: _selectedDate,
      genre: _selectedGenre,
      avatarUrl: _selectedAvatarUrl,
    ).copyWith(
      souhait: const [],
      codeSecuriteHash: _pinController.text.trim(),
    );

    try {
      await ref.read(parentNotifierProvider.notifier).ajouterEnfant(newChild);

      if (mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: '$name a été ajouté avec succès !',
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
    final isGirl = _selectedGenre == 'Fille';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ajouter un enfant',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppPadding.screen,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.verticalSm,

              // ── SÉLECTION AVATAR ENFANT ──
              Center(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AppAvatar(
                          imageUrl: _selectedAvatarUrl,
                          name: _nameController.text.isNotEmpty ? _nameController.text : _selectedGenre,
                          radius: 50,
                          defaultIcon: isGirl ? Icons.face_3_rounded : Icons.face_rounded,
                          onTap: _showPhotoOptionsSheet,
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: GestureDetector(
                            onTap: _showPhotoOptionsSheet,
                            child: Container(
                              padding: const EdgeInsets.all(7),
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
                                    blurRadius: 4,
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
                    AppSpacing.verticalXs,
                    TextButton(
                      onPressed: _showPhotoOptionsSheet,
                      child: Text(
                        'Définir la photo de l\'enfant',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.verticalLg,

              // ── PRÉNOM / NOM DE L'ENFANT ──
              AppTextField(
                controller: _nameController,
                label: 'Prénom de l\'enfant',
                hintText: 'Ex: Lucas, Sarah, Noah...',
                prefixIcon: Icons.person_outline_rounded,
                onChanged: (_) => setState(() {}),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Veuillez renseigner le prénom de l\'enfant';
                  }
                  return null;
                },
              ),
              AppSpacing.verticalMd,

              // ── SÉLECTION DU GENRE ──
              Text(
                'Genre',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleSmall?.color ??
                      theme.colorScheme.onSurface,
                ),
              ),
              AppSpacing.verticalXs,
              Row(
                children: [
                  Expanded(
                    child: _buildGenreCard(
                      context: context,
                      label: 'Garçon',
                      icon: Icons.face_rounded,
                      isSelected: _selectedGenre == 'Garçon',
                      onTap: () => setState(() => _selectedGenre = 'Garçon'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGenreCard(
                      context: context,
                      label: 'Fille',
                      icon: Icons.face_3_rounded,
                      isSelected: _selectedGenre == 'Fille',
                      onTap: () => setState(() => _selectedGenre = 'Fille'),
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalMd,

              // ── DATE DE NAISSANCE & ÂGE CALCULÉ ──
              Row(
                children: [
                  Expanded(
                    child: AppDatePicker(
                      label: 'Date de naissance',
                      selectedDate: _selectedDate,
                      onDateSelected: (date) {
                        setState(() => _selectedDate = date);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Âge estimé',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleSmall?.color ??
                              theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          '$_calculatedAge ans',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              AppSpacing.verticalMd,

              // ── CENTRES D'INTÉRÊT & SOUHAITS ──
              Text(
                'Centres d\'intérêt & Préférences',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleSmall?.color ??
                      theme.colorScheme.onSurface,
                ),
              ),
              AppSpacing.verticalXs,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSouhaits.map((item) {
                  final isSelected = _selectedSouhaits.contains(item);
                  return FilterChip(
                    label: Text(item),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSouhaits.add(item);
                        } else {
                          _selectedSouhaits.remove(item);
                        }
                      });
                    },
                    selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                    checkmarkColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.dividerColor.withValues(alpha: 0.2),
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (theme.textTheme.bodyMedium?.color ??
                              theme.colorScheme.onSurface),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  );
                }).toList(),
              ),
              AppSpacing.verticalMd,

              // ── CODE PIN SÉCURITÉ OPTIONNEL ──
              AppTextField(
                controller: _pinController,
                label: 'Code PIN enfant (optionnel)',
                hintText: 'Ex: 1234',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.lock_outline_rounded,
                helperText: 'Permet de sécuriser ou déverrouiller l\'espace enfant',
              ),
              AppSpacing.verticalXxl,

              // ── BOUTON D'ENREGISTREMENT ──
              AppButton(
                text: 'Enregistrer l\'enfant',
                icon: Icons.check_circle_outline_rounded,
                isLoading: _isLoading,
                onPressed: _submit,
              ),
              AppSpacing.verticalLg,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenreCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : (theme.iconTheme.color?.withValues(alpha: 0.6) ??
                      theme.colorScheme.onSurfaceVariant),
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.primary
                    : (theme.textTheme.bodyMedium?.color ??
                        theme.colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
