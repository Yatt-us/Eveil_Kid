// lib/features/parents/presentation/pages/modifier_enfant.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_date_picker.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/app_text_field.dart';
import 'package:eveilkid/features/enfant/model/enfant_model.dart';
import '../../providers/parent_provider.dart';

class ModifierEnfantPage extends ConsumerStatefulWidget {
  final EnfantModel enfant;

  const ModifierEnfantPage({super.key, required this.enfant});

  @override
  ConsumerState<ModifierEnfantPage> createState() => _ModifierEnfantPageState();
}

class _ModifierEnfantPageState extends ConsumerState<ModifierEnfantPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _pinController;

  late DateTime _selectedDate;
  late String _selectedGenre;
  late List<String> _selectedSouhaits;
  String? _selectedAvatarUrl;
  bool _isLoading = false;

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
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.enfant.nom);
    _pinController = TextEditingController(text: widget.enfant.codeSecuriteHash);
    _selectedDate = widget.enfant.dateNaissance;
    _selectedGenre = widget.enfant.genre.isNotEmpty ? widget.enfant.genre : 'Garçon';
    _selectedAvatarUrl = widget.enfant.avatarUrl;
    _selectedSouhaits = List<String>.from(widget.enfant.souhait);
  }

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedChild = widget.enfant.copyWith(
      nom: _nameController.text.trim(),
      dateNaissance: _selectedDate,
      genre: _selectedGenre,
      avatarUrl: _selectedAvatarUrl,
      souhait: widget.enfant.souhait
          .where((s) => !s.contains(' ') && s.isNotEmpty)
          .toList(),
      codeSecuriteHash: _pinController.text.trim(),
      dateModification: DateTime.now(),
    );

    try {
      await ref
          .read(parentNotifierProvider.notifier)
          .modifierEnfant(updatedChild);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profil de ${updatedChild.nom} mis à jour avec succès !',
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteChild() async {
    final confirmed = await AppDialogs.showConfirmDialog(
      context: context,
      title: 'Supprimer ${widget.enfant.nom} ?',
      message: 'Êtes-vous sûr de vouloir supprimer le profil de cet enfant ?',
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
      isDanger: true,
    );

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(parentNotifierProvider.notifier)
            .supprimerEnfant(widget.enfant.enfantId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.enfant.nom} a été supprimé.'),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Fermer les écrans jusqu'à l'accueil/liste
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
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
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Modifier ${widget.enfant.nom}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleMedium?.color ?? theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
            tooltip: 'Supprimer l\'enfant',
            onPressed: _deleteChild,
          ),
          AppSpacing.horizontalSm,
        ],
      ),
      body: SingleChildScrollView(
        padding: AppPadding.screen,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.verticalSm,

              // ── AVATAR ACTUEL ──
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _selectedAvatarUrl != null && _selectedAvatarUrl!.isNotEmpty
                            ? Image.network(
                                _selectedAvatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Center(
                                  child: Icon(
                                    _selectedGenre == 'Fille'
                                        ? Icons.face_3_rounded
                                        : Icons.face_rounded,
                                    size: 60,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  _selectedGenre == 'Fille'
                                      ? Icons.face_3_rounded
                                      : Icons.face_rounded,
                                  size: 60,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.verticalXl,

              // ── PRÉNOM / NOM DE L'ENFANT ──
              AppTextField(
                controller: _nameController,
                label: 'Prénom de l\'enfant',
                prefixIcon: Icons.person_outline_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Prénom requis';
                  }
                  return null;
                },
              ),
              AppSpacing.verticalMd,

              // ── GENRE ──
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

              // ── DATE DE NAISSANCE & ÂGE ──
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
                        'Âge calculé',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleSmall?.color ??
                              theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
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

              // ── PIN SÉCURITÉ ──
              AppTextField(
                controller: _pinController,
                label: 'Code PIN enfant',
                hintText: 'Ex: 1234',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.lock_outline_rounded,
                helperText: 'Code de sécurité pour l\'espace enfant',
              ),
              AppSpacing.verticalXxl,

              // ── BOUTONS D'ACTION ──
              AppButton(
                text: 'Sauvegarder les modifications',
                icon: Icons.check_circle_outline_rounded,
                isLoading: _isLoading,
                onPressed: _submit,
              ),
              AppSpacing.verticalMd,
              AppButton(
                text: 'Supprimer cet enfant',
                variant: AppButtonVariant.danger,
                icon: Icons.delete_outline_rounded,
                onPressed: _deleteChild,
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
        padding: const EdgeInsets.symmetric(vertical: 12),
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
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
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
