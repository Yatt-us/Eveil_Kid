// lib/features/parent/presentation/pages/modifier_profil.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppPadding.dart';
import '../../../../core/constants/AppSpacing.dart';
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
  late TextEditingController _dateNaissanceController;

  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(
      text: widget.parent.name.isNotEmpty
          ? widget.parent.name
          : 'Aminata DIARRA',
    );
    _emailController = TextEditingController(
      text: widget.parent.email.isNotEmpty
          ? widget.parent.email
          : 'aminata.diarra@gmail.com',
    );
    _telController = TextEditingController(
      text: widget.parent.telephone ?? '+223 70 12 34 56',
    );
    _adresseController = TextEditingController(text: 'Bamako, Mali');
    _selectedDate = DateTime(1990, 5, 15);
    _dateNaissanceController = TextEditingController(text: '15 / 05 / 1990');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telController.dispose();
    _adresseController.dispose();
    _dateNaissanceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateNaissanceController.text =
            '${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updated = widget.parent.copyWith(
      nom: _nomController.text.trim(),
      email: _emailController.text.trim(),
      telephone: _telController.text.trim(),
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
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Modifier mon profil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
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

              // --- AVATAR DU PROFIL AVEC BADGE CAMÉRA ---
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceVariant,
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: ClipOval(
                        child:
                            widget.parent.photoUrl != null &&
                                widget.parent.photoUrl!.isNotEmpty
                            ? Image.network(
                                widget.parent.photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: AppColors.primary,
                                    ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.primary,
                              ),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: GestureDetector(
                        onTap: () {
                          AppDialogs.showSnackBar(
                            context: context,
                            message: 'Sélecteur de photo bientôt disponible.',
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalXxl,

              // --- CHAMP NOM COMPLET ---
              _buildFieldContainer(
                label: 'Nom complet',
                child: TextFormField(
                  controller: _nomController,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nom requis' : null,
                ),
              ),
              AppSpacing.verticalMd,

              // --- CHAMP EMAIL ---
              _buildFieldContainer(
                label: 'Email',
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
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
                label: 'Téléphone',
                child: TextFormField(
                  controller: _telController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              AppSpacing.verticalMd,

              // --- CHAMP ADRESSE ---
              _buildFieldContainer(
                label: 'Adresse',
                child: TextFormField(
                  controller: _adresseController,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              AppSpacing.verticalMd,

              // --- CHAMP DATE DE NAISSANCE ---
              _buildFieldContainer(
                label: 'Date de naissance',
                trailing: GestureDetector(
                  onTap: _pickDate,
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ),
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Text(
                    _dateNaissanceController.text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              AppSpacing.verticalXxl,

              // --- BOUTON ENREGISTRER ---
              AppButton(
                text: 'Enregistrer',
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
    required String label,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textPrimary.withValues(alpha: 0.7),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
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
