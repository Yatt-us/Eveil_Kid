import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'shared/widgets/app_avatar.dart';
import 'shared/widgets/app_button.dart';
import 'shared/widgets/app_card.dart';
import 'shared/widgets/app_chip.dart';
import 'shared/widgets/app_date_picker.dart';
import 'shared/widgets/app_dialogs.dart';
import 'shared/widgets/app_dropdown.dart';
import 'shared/widgets/app_icon_button.dart';
import 'shared/widgets/app_list_tile.dart';
import 'shared/widgets/app_search_bar.dart';
import 'shared/widgets/app_section_header.dart';
import 'shared/widgets/app_states.dart';
import 'shared/widgets/app_switch_tile.dart';
import 'shared/widgets/app_text_field.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EveilKidApp());
}

class EveilKidApp extends StatelessWidget {
  const EveilKidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ÉveilKid - Design System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.teal,
          surface: AppColors.surface,
          error: AppColors.danger,
        ),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const ComponentShowcasePage(),
    );
  }
}

class ComponentShowcasePage extends StatefulWidget {
  const ComponentShowcasePage({super.key});

  @override
  State<ComponentShowcasePage> createState() => _ComponentShowcasePageState();
}

class _ComponentShowcasePageState extends State<ComponentShowcasePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _buttonLoading = false;
  bool _switchVal = true;
  bool _checkboxVal = false;
  DateTime? _selectedDate = DateTime.now();
  String? _dropdownVal = 'Activité';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.child_care_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'ÉveilKid Design System',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Palette & Couleurs'),
            Tab(text: 'Saisies & Inputs'),
            Tab(text: 'Boutons & Actions'),
            Tab(text: 'Modales & Dialogues'),
            Tab(text: 'Cartes & Listes'),
            Tab(text: 'Badges & États'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPaletteTab(),
          _buildInputsTab(),
          _buildButtonsTab(),
          _buildModalsTab(),
          _buildCardsTab(),
          _buildStatesTab(),
        ],
      ),
    );
  }

  // --- TAB 1: Palette & Couleurs ---
  Widget _buildPaletteTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const AppSectionHeader(
          title: 'Charte Graphique ÉveilKid',
          subtitle:
              'Palette dans AppColors (lib/core/constants/app_colors.dart)',
        ),
        const SizedBox(height: 12),
        _buildColorCard(
          title: 'Primaire (Violet Royal)',
          hex: '#763CD1',
          color: AppColors.primary,
          role: 'Branding principal, boutons primaires, éléments actifs',
        ),
        _buildColorCard(
          title: 'Accent (Jaune Ambré)',
          hex: '#F8B727',
          color: AppColors.accent,
          role: 'Highlights, étoiles, avertissements, touches ludiques',
        ),
        _buildColorCard(
          title: 'Secondaire (Bleu Ciel)',
          hex: '#358CED',
          color: AppColors.secondary,
          role: 'Informations, badges d\'activités, boutons secondaires',
        ),
        _buildColorCard(
          title: 'Tertiaire (Vert Menthe / Turquoise)',
          hex: '#39C0AD',
          color: AppColors.teal,
          role: 'Succès, validation, indicateurs de santé et progrès',
        ),
        _buildColorCard(
          title: 'Quaternaire (Indigo Sombre)',
          hex: '#422B95',
          color: AppColors.indigo,
          role: 'Titres, en-têtes contrastés, composants sombres',
        ),
      ],
    );
  }

  Widget _buildColorCard({
    required String title,
    required String hex,
    required Color color,
    required String role,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        hex,
                        style: TextStyle(
                          color: color == AppColors.accent
                              ? Colors.amber[900]
                              : color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: Saisies & Inputs ---
  Widget _buildInputsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const AppSectionHeader(
          title: 'Barre de recherche',
          subtitle: 'Champ de recherche avec filtres et réinitialisation',
        ),
        AppSearchBar(
          hintText: 'Rechercher un enfant ou une activité...',
          onChanged: (text) {},
          onFilterTap: () {
            AppDialogs.showSnackBar(
              context: context,
              message: 'Filtres cliqués !',
            );
          },
        ),
        const SizedBox(height: 24),
        const AppSectionHeader(
          title: 'Champs de texte',
          subtitle: 'Variantes avec étiquettes, préfixes et mots de passe',
        ),
        const AppTextField(
          label: 'Nom de l\'enfant',
          hintText: 'ex: Lucas Dupont',
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        const AppTextField(
          label: 'Mot de passe',
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 16),
        const AppTextField(
          label: 'Observations',
          hintText: 'Saisissez vos remarques sur la journée...',
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        const AppSectionHeader(
          title: 'Sélecteurs & Formulaires',
          subtitle: 'Dropdowns modaux, DatePickers et Interrupteurs',
        ),
        AppDropdown<String>(
          label: 'Catégorie d\'activité',
          value: _dropdownVal,
          prefixIcon: Icons.category_outlined,
          items: const [
            AppDropdownItem(
              value: 'Activité',
              label: 'Activité créative',
              subtitle: 'Dessin, peinture, pâte à modeler',
              icon: Icons.palette_outlined,
              iconColor: AppColors.primary,
            ),
            AppDropdownItem(
              value: 'Sommeil',
              label: 'Sieste & Sommeil',
              subtitle: 'Temps calme et repos de l\'après-midi',
              icon: Icons.bedtime_outlined,
              iconColor: AppColors.secondary,
            ),
            AppDropdownItem(
              value: 'Repas',
              label: 'Repas & Goûter',
              subtitle: 'Déjeuner, biberons et encas',
              icon: Icons.restaurant_outlined,
              iconColor: AppColors.teal,
            ),
            AppDropdownItem(
              value: 'Santé',
              label: 'Soins & Santé',
              subtitle: 'Prise de médicaments, soins légers',
              icon: Icons.medical_services_outlined,
              iconColor: AppColors.danger,
            ),
          ],
          onChanged: (val) => setState(() => _dropdownVal = val),
        ),
        const SizedBox(height: 16),
        AppDatePicker(
          label: 'Date de l\'événement',
          selectedDate: _selectedDate,
          onDateSelected: (date) => setState(() => _selectedDate = date),
        ),
        const SizedBox(height: 16),
        AppSwitchTile(
          title: 'Notifications quotidiennes',
          subtitle: 'Recevoir le résumé de la journée à 18h',
          icon: Icons.notifications_active_outlined,
          value: _switchVal,
          onChanged: (val) => setState(() => _switchVal = val),
        ),
        const SizedBox(height: 12),
        AppCheckboxTile(
          title: 'J\'accepte le règlement d\'intérieur',
          subtitle: 'Conditions de fonctionnement de la structure',
          value: _checkboxVal,
          onChanged: (val) => setState(() => _checkboxVal = val ?? false),
        ),
      ],
    );
  }

  // --- TAB 3: Boutons & Actions ---
  Widget _buildButtonsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const AppSectionHeader(
          title: 'Variantes de Boutons',
          subtitle: 'Boutons principaux, contours, texte et danger',
        ),
        AppButton(
          text: 'Bouton Principal (Violet #763CD1)',
          icon: Icons.check_circle_outline,
          isLoading: _buttonLoading,
          onPressed: () {
            setState(() => _buttonLoading = true);
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) setState(() => _buttonLoading = false);
            });
          },
        ),
        const SizedBox(height: 12),
        AppButton(
          text: 'Bouton Contour (Outlined)',
          variant: AppButtonVariant.outlined,
          icon: Icons.edit_outlined,
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        AppButton(
          text: 'Bouton Texte (Text)',
          variant: AppButtonVariant.text,
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        AppButton(
          text: 'Bouton Danger (Supprimer)',
          variant: AppButtonVariant.danger,
          icon: Icons.delete_outline,
          onPressed: () {},
        ),
        const SizedBox(height: 24),
        const AppSectionHeader(
          title: 'Boutons d\'Icônes (AppIconButton)',
          subtitle: 'Boutons avec fond thématique et badges',
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AppIconButton(
              icon: Icons.star_rounded,
              color: Colors.amber[800],
              backgroundColor: AppColors.accent.withValues(alpha: 0.2),
              tooltip: 'Favori',
              onPressed: () {},
            ),
            AppIconButton(
              icon: Icons.notifications_outlined,
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              tooltip: 'Notifications',
              hasBadge: true,
              badgeText: '3',
              onPressed: () {},
            ),
            AppIconButton(
              icon: Icons.info_outline_rounded,
              color: AppColors.secondary,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
              tooltip: 'Info',
              onPressed: () {},
            ),
            AppIconButton(
              icon: Icons.health_and_safety_outlined,
              color: AppColors.teal,
              backgroundColor: AppColors.teal.withValues(alpha: 0.15),
              tooltip: 'Santé',
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  // --- TAB 4: Modales & Dialogues ---
  Widget _buildModalsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const AppSectionHeader(
          title: 'Boîtes de dialogue',
          subtitle: 'Dialogues de confirmation et d\'action critique',
        ),
        AppButton(
          text: 'Ouvrir Dialogue de Confirmation',
          icon: Icons.help_outline,
          variant: AppButtonVariant.outlined,
          onPressed: () async {
            final result = await AppDialogs.showConfirmDialog(
              context: context,
              title: 'Enregistrer la fiche ?',
              message: 'Voulez-vous enregistrer les informations pour Lucas ?',
              confirmText: 'Enregistrer',
            );
            if (result == true && mounted) {
              AppDialogs.showSnackBar(
                context: context,
                message: 'Fiche enregistrée !',
              );
            }
          },
        ),
        const SizedBox(height: 12),
        AppButton(
          text: 'Ouvrir Dialogue Critique',
          icon: Icons.warning_amber_rounded,
          variant: AppButtonVariant.danger,
          onPressed: () async {
            final result = await AppDialogs.showConfirmDialog(
              context: context,
              title: 'Supprimer l\'activité ?',
              message: 'Cette action est irréversible.',
              confirmText: 'Supprimer',
              isDanger: true,
            );
            if (result == true && mounted) {
              AppDialogs.showSnackBar(
                context: context,
                message: 'Activité supprimée',
                isError: true,
              );
            }
          },
        ),
        const SizedBox(height: 24),
        const AppSectionHeader(title: 'Feuille inférieure (Bottom Sheet)'),
        AppButton(
          text: 'Ouvrir Bottom Sheet',
          icon: Icons.keyboard_arrow_up_rounded,
          onPressed: () {
            AppDialogs.showBottomSheet(
              context: context,
              title: 'Nouvelle Observation',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppTextField(
                    label: 'Titre de l\'observation',
                    hintText: 'ex: Sieste calme',
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Valider',
                    onPressed: () {
                      Navigator.pop(context);
                      AppDialogs.showSnackBar(
                        context: context,
                        message: 'Observation ajoutée !',
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // --- TAB 5: Cartes & Listes ---
  Widget _buildCardsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const AppSectionHeader(
          title: 'Cartes interactives (AppCard)',
          subtitle: 'Conteneurs stylisés avec thématique couleur',
        ),
        AppCard(
          title: 'Fiche Enfant : Emma Martin',
          subtitle: 'Section des Petits • 2 ans',
          trailing: const AppChip(
            label: 'Présent',
            variant: AppChipVariant.success,
          ),
          footer: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Dernière sieste : 14h00',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
            ],
          ),
          onTap: () {},
          child: Row(
            children: const [
              AppAvatar(name: 'Emma Martin', radius: 26, isOnline: true),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'A participé activement à l\'atelier peinture ce matin. Très bon appétit au déjeuner.',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const AppSectionHeader(title: 'Listes réutilisables (AppListTile)'),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              AppListTile(
                title: 'Lucas Bernard',
                subtitle: 'Arrivé à 08h30',
                leading: const AppAvatar(name: 'Lucas Bernard'),
                showDivider: true,
                onTap: () {},
              ),
              AppListTile(
                title: 'Chloé Morel',
                subtitle: 'Régime sans gluten',
                leading: const AppAvatar(name: 'Chloé Morel'),
                trailing: const AppChip(
                  label: 'Allergie',
                  variant: AppChipVariant.warning,
                ),
                showDivider: true,
                onTap: () {},
              ),
              AppListTile(
                title: 'Paramètres de la section',
                subtitle: 'Gérer les autorisations',
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.settings_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 6: Badges & États ---
  Widget _buildStatesTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const AppSectionHeader(
          title: 'Puces & Badges de couleur (AppChip)',
          subtitle: 'Badges associés à la nouvelle palette',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            AppChip(label: 'Violet (#763CD1)', variant: AppChipVariant.primary),
            AppChip(
              label: 'Vert Menthe (#39C0AD)',
              icon: Icons.check,
              variant: AppChipVariant.success,
            ),
            AppChip(
              label: 'Ambré (#F8B727)',
              icon: Icons.star,
              variant: AppChipVariant.warning,
            ),
            AppChip(
              label: 'Bleu Ciel (#358CED)',
              icon: Icons.info_outline,
              variant: AppChipVariant.neutral,
            ),
            AppChip(
              label: 'Danger (#EF4444)',
              icon: Icons.error_outline,
              variant: AppChipVariant.danger,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const AppSectionHeader(title: 'Avatars (AppAvatar)'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            AppAvatar(name: 'Thomas Petit', radius: 24, isOnline: true),
            AppAvatar(name: 'Sophie Roche', radius: 24),
            AppAvatar(radius: 24, defaultIcon: Icons.child_care_rounded),
          ],
        ),
        const SizedBox(height: 24),
        const AppSectionHeader(title: 'Écran d\'état vide (AppEmptyState)'),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: AppEmptyState(
            title: 'Aucune donnée enregistrée',
            description:
                'Il n\'y a encore aucune observation pour aujourd\'hui.',
            actionText: 'Créer une entrée',
            onActionPressed: () {},
          ),
        ),
      ],
    );
  }
}
