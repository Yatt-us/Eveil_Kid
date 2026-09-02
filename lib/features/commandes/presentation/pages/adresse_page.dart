import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/AppSpacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../models/commande_model.dart';
import '../widgets/checkout_stepper.dart';
import 'paiement_page.dart';

enum ModeAdresseLivraison {
  gps,
  manuelle,
}

class AdressePage extends ConsumerStatefulWidget {
  final CommandeModel brouillonCommande;

  const AdressePage({super.key, required this.brouillonCommande});

  @override
  ConsumerState<AdressePage> createState() => _AdressePageState();
}

class _AdressePageState extends ConsumerState<AdressePage> {
  final _formKey = GlobalKey<FormState>();

  // Le mode GPS est le mode par défaut
  ModeAdresseLivraison _modeSelectionne = ModeAdresseLivraison.gps;

  // Contrôleurs : 2 champs pour la saisie manuelle (Adresse & Téléphone)
  final _adresseManuelleController = TextEditingController();
  final _telephoneController = TextEditingController();

  // Contrôleur et état GPS
  bool _isDetectingGps = false;
  String? _gpsCoordinates;
  String? _gpsAddressPreview;
  String? _gpsErrorMessage;

  // Case à cocher pour mémoriser le contact pour de prochaines commandes
  bool _enregistrerPourProchainesCommandes = true;

  @override
  void initState() {
    super.initState();
    _chargerDonneesSauvegardees();
  }

  Future<void> _chargerDonneesSauvegardees() async {
    final prefs = await SharedPreferences.getInstance();
    String userPhone = '';
    try {
      final authState = ref.read(authProvider);
      userPhone = authState.utilisateur?.telephone ?? '';
    } catch (_) {}

    final savedPhone = prefs.getString('saved_delivery_phone');
    final savedAdresse = prefs.getString('saved_delivery_address');
    final savedMode = prefs.getString('saved_delivery_mode');
    final savedGpsCoords = prefs.getString('saved_delivery_gps_coords');
    final savedGpsPreview = prefs.getString('saved_delivery_gps_preview');
    final savedRemember = prefs.getBool('saved_delivery_remember') ?? true;

    setState(() {
      _enregistrerPourProchainesCommandes = savedRemember;

      // Téléphone
      if (widget.brouillonCommande.numeroTelephone != null &&
          widget.brouillonCommande.numeroTelephone!.isNotEmpty) {
        _telephoneController.text = widget.brouillonCommande.numeroTelephone!;
      } else if (savedPhone != null && savedPhone.isNotEmpty) {
        _telephoneController.text = savedPhone;
      } else if (userPhone.isNotEmpty) {
        _telephoneController.text = userPhone;
      }

      // Adresse manuelle
      if (savedAdresse != null && savedAdresse.isNotEmpty) {
        _adresseManuelleController.text = savedAdresse;
      } else if (widget.brouillonCommande.adresseLivraison.isNotEmpty &&
          !widget.brouillonCommande.adresseLivraison.startsWith('GPS:')) {
        _adresseManuelleController.text = widget.brouillonCommande.adresseLivraison;
      }

      // GPS
      if (savedGpsCoords != null) _gpsCoordinates = savedGpsCoords;
      if (savedGpsPreview != null) _gpsAddressPreview = savedGpsPreview;

      // Mode (GPS par défaut sauf si l'utilisateur avait explicitement sélectionné 'manuelle')
      if (savedMode == 'manuelle') {
        _modeSelectionne = ModeAdresseLivraison.manuelle;
      } else {
        _modeSelectionne = ModeAdresseLivraison.gps;
      }
    });
  }

  Future<void> _detecterPositionGps({bool silent = false}) async {
    setState(() {
      _isDetectingGps = true;
      _gpsErrorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isDetectingGps = false;
          _gpsErrorMessage = 'Les services GPS sont désactivés sur votre appareil.';
        });
        if (!silent && mounted) {
          AppDialogs.showSnackBar(
            context: context,
            message: 'Veuillez activer la localisation GPS dans vos paramètres.',
            isError: true,
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isDetectingGps = false;
            _gpsErrorMessage = 'Permission de localisation refusée.';
          });
          if (!silent && mounted) {
            AppDialogs.showSnackBar(
              context: context,
              message: 'La permission GPS est nécessaire pour la localisation exacte.',
              isError: true,
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isDetectingGps = false;
          _gpsErrorMessage = 'Permissions de localisation refusées de façon permanente.';
        });
        if (!silent && mounted) {
          AppDialogs.showSnackBar(
            context: context,
            message: 'Veuillez autoriser la localisation dans les paramètres de votre téléphone.',
            isError: true,
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final lat = position.latitude;
      final lng = position.longitude;
      final coordsStr = '${lat.toStringAsFixed(6)}°, ${lng.toStringAsFixed(6)}°';

      // Reverse geocoding via OpenStreetMap Nominatim
      String addressPreview = 'Position GPS exacte';
      try {
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
        );
        final response = await http.get(
          url,
          headers: {'User-Agent': 'EveilKidApp/1.0 (contact@eveilkid.com)'},
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final displayName = data['display_name'] as String?;
          final address = data['address'] as Map<String, dynamic>?;

          if (address != null) {
            final road = address['road'] ?? address['suburb'] ?? address['neighbourhood'] ?? '';
            final city = address['city'] ?? address['town'] ?? address['municipality'] ?? address['county'] ?? '';
            final country = address['country'] ?? '';
            final parts = [road, city, country].where((p) => p.toString().trim().isNotEmpty).toList();
            if (parts.isNotEmpty) {
              addressPreview = parts.join(', ');
            } else if (displayName != null && displayName.isNotEmpty) {
              addressPreview = displayName;
            }
          } else if (displayName != null && displayName.isNotEmpty) {
            addressPreview = displayName;
          }
        }
      } catch (_) {
        addressPreview = 'Coordonnées ($coordsStr)';
      }

      if (!mounted) return;

      setState(() {
        _isDetectingGps = false;
        _gpsCoordinates = coordsStr;
        _gpsAddressPreview = addressPreview;
        _gpsErrorMessage = null;
      });

      if (!silent && mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Position GPS détectée avec succès !',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDetectingGps = false;
        _gpsErrorMessage = 'Impossible de récupérer la position GPS : $e';
      });
      if (!silent && mounted) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Erreur lors de la détection GPS. Vous pouvez utiliser la saisie manuelle.',
          isError: true,
        );
      }
    }
  }

  Future<void> _sauvegarderPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('saved_delivery_remember', _enregistrerPourProchainesCommandes);

    if (_enregistrerPourProchainesCommandes) {
      await prefs.setString('saved_delivery_phone', _telephoneController.text.trim());
      await prefs.setString('saved_delivery_mode',
          _modeSelectionne == ModeAdresseLivraison.gps ? 'gps' : 'manuelle');

      if (_modeSelectionne == ModeAdresseLivraison.manuelle) {
        await prefs.setString(
            'saved_delivery_address', _adresseManuelleController.text.trim());
      } else {
        if (_gpsCoordinates != null) {
          await prefs.setString('saved_delivery_gps_coords', _gpsCoordinates!);
        }
        if (_gpsAddressPreview != null) {
          await prefs.setString('saved_delivery_gps_preview', _gpsAddressPreview!);
        }
      }
    }
  }

  void _continuerVersPaiement() async {
    if (!_formKey.currentState!.validate()) return;

    final telephone = _telephoneController.text.trim();
    if (telephone.isEmpty) {
      AppDialogs.showSnackBar(
        context: context,
        message: 'Veuillez renseigner un numéro de téléphone pour la livraison.',
        isError: true,
      );
      return;
    }

    String adresseFinale = '';

    if (_modeSelectionne == ModeAdresseLivraison.manuelle) {
      final adresse = _adresseManuelleController.text.trim();
      if (adresse.isEmpty) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Veuillez saisir votre adresse complète de livraison.',
          isError: true,
        );
        return;
      }
      adresseFinale = adresse;
    } else {
      if (_gpsCoordinates == null) {
        AppDialogs.showSnackBar(
          context: context,
          message: 'Veuillez détecter votre position GPS exacte avant de continuer.',
          isError: true,
        );
        return;
      }

      final preview = _gpsAddressPreview ?? 'Localisation GPS';
      adresseFinale = 'GPS: $_gpsCoordinates ($preview)';
    }

    await _sauvegarderPreferences();

    if (!mounted) return;

    final commandeMiseAJour = widget.brouillonCommande.copyWith(
      adresseLivraison: adresseFinale,
      numeroTelephone: telephone,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaiementPage(brouillonCommande: commandeMiseAJour),
      ),
    );
  }

  @override
  void dispose() {
    _adresseManuelleController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.15);
    final textSecondary = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
        (isDark ? Colors.white70 : AppColors.textSecondary);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Adresse de livraison',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color ?? theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
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
      ),
      body: Column(
        children: [
          const CheckoutStepper(stepActuel: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sélecteur des 2 options (GPS par défaut et Saisie manuelle)
                    Text(
                      'MODE DE LOCALISATION',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildOptionCard(
                            mode: ModeAdresseLivraison.gps,
                            title: 'Localisation GPS',
                            subtitle: 'Position exacte (Recommandé)',
                            icon: Icons.my_location_rounded,
                            theme: theme,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildOptionCard(
                            mode: ModeAdresseLivraison.manuelle,
                            title: 'Saisie manuelle',
                            subtitle: 'Adresse écrite',
                            icon: Icons.edit_location_alt_rounded,
                            theme: theme,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Contenu selon le mode sélectionné
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 250),
                      crossFadeState: _modeSelectionne == ModeAdresseLivraison.gps
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: _buildGpsAddressSection(theme, isDark, dividerColor),
                      secondChild: _buildManualAddressSection(theme, isDark, dividerColor),
                    ),
                    const SizedBox(height: 18),

                    // Champ Téléphone obligatoire (dans les 2 cas)
                    _buildPhoneSection(theme, isDark, dividerColor, textSecondary),
                    const SizedBox(height: 16),

                    // Case à cocher : Enregistrer ce contact pour de prochaines commandes
                    _buildRememberCheckbox(theme, isDark, dividerColor),
                    const SizedBox(height: 28),

                    // Bouton Continuer vers le paiement
                    AppButton(
                      text: 'Continuer vers le paiement',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _continuerVersPaiement,
                    ),
                    AppSpacing.verticalMd,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final Utilisateur? utilisateur = authState.utilisateur;
    final nomParent = utilisateur?.nom ?? '';
    final affichageNom = nomParent.isNotEmpty ? nomParent : 'Parent';

  Widget _buildOptionCard({
    required ModeAdresseLivraison mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeData theme,
    required bool isDark,
  }) {
    final isSelected = _modeSelectionne == mode;
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () => setState(() => _modeSelectionne = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.2 : 0.08)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : theme.dividerColor.withValues(alpha: isDark ? 0.25 : 0.15),
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepIndicator('1', 'Adresse', true),
                  _buildStepLine(),
                  _buildStepIndicator('2', 'Paiement', false),
                  _buildStepLine(),
                  _buildStepIndicator('3', 'Confirmation', false),
                ],
              ),
              const SizedBox(height: 28),
              
              const Text(
                'Adresse de livraison',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle, 
                          color: Colors.green, 
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          affichageNom,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _ouvrirDialogueModification,
                      child: const Text(
                        'Modifier',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                  ),
                  onPressed: () {
                    // Récupération de l'ID du parent connecté depuis l'objet utilisateur
                    final String? parentId = utilisateur?.uid; 
                    if (parentId == null || parentId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Erreur : Utilisateur non identifié'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Injection du parentId et de l'adresse dans le modèle via copyWith
                    final commandeMiseAJour = widget.brouillonCommande.copyWith(
                      parentId: parentId,
                      adresseLivraison: _adresseLivraison,
                    );

                    // Navigation vers l'écran de paiement avec le modèle complété
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaiementPage(
                          brouillonCommande: commandeMiseAJour,
                          adresseLivraison: _adresseLivraison,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Confirmer la commande',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor.withValues(alpha: 0.2)
                        : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? primaryColor : theme.colorScheme.onSurfaceVariant,
                    size: 20,

                  ),
                ),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? primaryColor : theme.dividerColor,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: isSelected ? primaryColor : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGpsAddressSection(ThemeData theme, bool isDark, Color dividerColor) {
    const successColor = Color(0xFF10B981);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gps_fixed_rounded, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Localisation GPS exacte',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (_gpsCoordinates != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: successColor.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: successColor.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: successColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: successColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Position GPS enregistrée',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: successColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _gpsCoordinates!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (_gpsAddressPreview != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _gpsAddressPreview!,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isDetectingGps ? null : () => _detecterPositionGps(),
                    tooltip: 'Réactualiser la position GPS',
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: dividerColor),
              ),
              child: Column(
                children: [
                  Text(
                    'Partagez votre localisation GPS en un clic pour que le livreur vous trouve facilement.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  if (_gpsErrorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _gpsErrorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _isDetectingGps ? null : () => _detecterPositionGps(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _isDetectingGps
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.my_location_rounded, size: 18),
                    label: Text(
                      _isDetectingGps ? 'Détection en cours...' : 'Détecter ma position exacte',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManualAddressSection(ThemeData theme, bool isDark, Color dividerColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.home_outlined, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Adresse de livraison',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Champ unique pour l'adresse (Rue, quartier, repères...)
          TextFormField(
            controller: _adresseManuelleController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Adresse complète *',
              hintText: 'ex: Cocody Riviera 3, Rue des Jardins, Villa 124 (en face de la pharmacie)',
              prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(14),
            ),
            validator: (val) {
              if (_modeSelectionne == ModeAdresseLivraison.manuelle &&
                  (val == null || val.trim().isEmpty)) {
                return 'Veuillez renseigner votre adresse de livraison.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneSection(
    ThemeData theme,
    bool isDark,
    Color dividerColor,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.phone_in_talk_rounded, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Numéro de téléphone *',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Le livreur appellera ce numéro pour vous prévenir à l\'arrivée.',
            style: TextStyle(fontSize: 11.5, color: textSecondary, height: 1.3),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _telephoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Téléphone de contact *',
              hintText: '+225 07 00 00 00 00',
              prefixIcon: const Icon(Icons.phone_android_rounded, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Le numéro de téléphone est obligatoire.';
              }
              if (val.trim().length < 8) {
                return 'Veuillez saisir un numéro de téléphone valide.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRememberCheckbox(ThemeData theme, bool isDark, Color dividerColor) {
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: dividerColor),
        ),
        child: CheckboxListTile(
          value: _enregistrerPourProchainesCommandes,
          onChanged: (val) => setState(() => _enregistrerPourProchainesCommandes = val ?? true),
          title: Text(
            'Enregistrer ce contact pour de prochaines commandes',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: theme.colorScheme.primary,
          dense: true,
        ),
      ),
    );
  }
}