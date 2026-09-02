import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/core/constants/app_colors.dart';

/// Thème dédié à l'Espace Enfant avec une identité visuelle ludique
/// et sa couleur principale : le vert enfantin.
class KidTheme {
  KidTheme._();

  // ============================================================
  // COULEURS DU THÈME ENFANT
  // ============================================================

  /// Vert enfantin vif et chaleureux (couleur primaire principale de l'enfant)
  static const Color primaryGreen = Color(0xFF22C55E); // Green 500
  static const Color primaryGreenLight = Color(0xFF4ADE80); // Green 400
  static const Color primaryGreenDark = Color(0xFF16A34A); // Green 600

  /// Couleurs secondaires ludiques
  static const Color playfulAmber = Color(0xFFF59E0B);
  static const Color playfulSky = Color(0xFF0EA5E9);
  static const Color playfulPurple = Color(0xFF8B5CF6);
  static const Color playfulCoral = Color(0xFFF97316);

  /// Fonds et surfaces mode clair
  static const Color lightBackground = Color(0xFFF0FDF4); // Doux vert pastel
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceVariant = Color(0xFFDCFCE7); // Vert très pâle
  static const Color lightTextPrimary = Color(
    0xFF14532D,
  ); // Vert forêt très sombre lisible
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightBorder = Color(0xFFBBF7D0);

  /// Fonds et surfaces mode sombre (fond gris inspiré du mode nuit parent mais légèrement plus clair)
  static const Color darkBackground = Color(
    0xFF18181C,
  ); // Gris sombre légèrement plus clair que le parent (0xFF121214)
  static const Color darkSurface = Color(
    0xFF222228,
  ); // Surface gris sombre légèrement plus claire (0xFF1E1E22)
  static const Color darkSurfaceVariant = Color(0xFF2E2E36);
  static const Color darkTextPrimary = Color(0xFFF8F7FC);
  static const Color darkTextSecondary = Color(0xFFB8B3C7);
  static const Color darkBorder = Color(0xFF383842);

  // ============================================================
  // TRANSITIONS DE PAGE
  // ============================================================
  static const PageTransitionsTheme _pageTransitionsTheme =
      PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        },
      );

  // ============================================================
  // THÈME CLAIR ENFANT
  // ============================================================
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      pageTransitionsTheme: _pageTransitionsTheme,
      brightness: Brightness.light,
      fontFamily: AppTextStyles.fontFamily,

      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        onPrimary: Colors.white,
        primaryContainer: lightSurfaceVariant,
        onPrimaryContainer: primaryGreenDark,

        secondary: playfulAmber,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFFEF3C7),
        onSecondaryContainer: Color(0xFF92400E),

        tertiary: playfulSky,
        onTertiary: Colors.white,

        error: AppColors.danger,
        onError: Colors.white,

        surface: lightSurface,
        onSurface: lightTextPrimary,
        surfaceContainerHighest: lightSurfaceVariant,
        onSurfaceVariant: lightTextSecondary,
        outline: lightBorder,
      ),

      scaffoldBackgroundColor: lightBackground,

      // ── APP BAR ──
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: lightTextPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: lightSurface,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),

      // ── BOUTONS ÉLEVÉS (ARRONDIS ET LUDIQUES) ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryGreen.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // ── BOUTONS PLEINS ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // ── BOUTONS CONTOUR ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreenDark,
          side: const BorderSide(color: primaryGreen, width: 1.8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── BOUTONS TEXTE ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreenDark,
          textStyle: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── CARTES ──
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: lightBorder, width: 1.2),
        ),
      ),

      // ── FLOATING ACTION BUTTON ──
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // ── DIALOGUES ──
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: lightTextPrimary,
        ),
      ),

      // ── BOTTOM SHEET ──
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      // ── PROGRESS INDICATOR ──
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGreen,
        linearTrackColor: lightSurfaceVariant,
        circularTrackColor: lightSurfaceVariant,
      ),

      // ── CHIPS ──
      chipTheme: ChipThemeData(
        backgroundColor: lightSurfaceVariant,
        labelStyle: const TextStyle(
          color: primaryGreenDark,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: Colors.transparent),
        ),
      ),

      // ── TYPOGRAPHIE CLAIRE ──
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: AppTextStyles.fontFamily, color: lightTextPrimary, fontWeight: FontWeight.w900),
        displayMedium: TextStyle(fontFamily: AppTextStyles.fontFamily, color: lightTextPrimary, fontWeight: FontWeight.w900),
        displaySmall: TextStyle(fontFamily: AppTextStyles.fontFamily, color: lightTextPrimary, fontWeight: FontWeight.w900),
        headlineLarge: TextStyle(fontFamily: AppTextStyles.fontFamily, color: lightTextPrimary, fontWeight: FontWeight.w900),
        headlineMedium: TextStyle(fontFamily: AppTextStyles.fontFamily, color: lightTextPrimary, fontWeight: FontWeight.w800),
        headlineSmall: TextStyle(fontFamily: AppTextStyles.fontFamily, color: lightTextPrimary, fontWeight: FontWeight.w800),
        titleLarge: TextStyle(fontFamily: AppTextStyles.fontFamily, color: lightTextPrimary, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontFamily: AppTextStyles.fontFamily, color: lightTextPrimary, fontWeight: FontWeight.w800),
        titleSmall: TextStyle(fontFamily: AppTextStyles.fontFamily, color: lightTextPrimary, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(fontFamily: AppTextStyles.fontFamily, color: lightTextPrimary, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontFamily: AppTextStyles.fontFamily, color: lightTextPrimary, fontWeight: FontWeight.w600),
        bodySmall: TextStyle(fontFamily: AppTextStyles.fontFamily, color: lightTextSecondary, fontWeight: FontWeight.w500),
        labelLarge: TextStyle(fontFamily: AppTextStyles.fontFamily, color: lightTextPrimary, fontWeight: FontWeight.w700),
        labelMedium: TextStyle(fontFamily: AppTextStyles.fontFamily, color: lightTextSecondary, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(fontFamily: AppTextStyles.fontFamily, color: lightTextSecondary, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ============================================================
  // THÈME SOMBRE ENFANT
  // ============================================================
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      pageTransitionsTheme: _pageTransitionsTheme,
      brightness: Brightness.dark,
      fontFamily: AppTextStyles.fontFamily,

      colorScheme: const ColorScheme.dark(
        primary: primaryGreenLight,
        onPrimary: Color(0xFF052E16),
        primaryContainer: darkSurfaceVariant,
        onPrimaryContainer: Color(0xFFDCFCE7),

        secondary: playfulAmber,
        onSecondary: Color(0xFF451A03),
        secondaryContainer: Color(0xFF78350F),
        onSecondaryContainer: Color(0xFFFEF3C7),

        tertiary: playfulSky,
        onTertiary: Colors.white,

        error: AppColors.danger,
        onError: Colors.white,

        surface: darkSurface,
        onSurface: darkTextPrimary,
        surfaceContainerHighest: darkSurfaceVariant,
        onSurfaceVariant: darkTextSecondary,
        outline: darkBorder,
      ),

      scaffoldBackgroundColor: darkBackground,

      // ── APP BAR ──
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: darkTextPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: darkSurface,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      // ── BOUTONS ÉLEVÉS ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreenLight,
          foregroundColor: const Color(0xFF052E16),
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // ── BOUTONS PLEINS ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryGreenLight,
          foregroundColor: const Color(0xFF052E16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // ── BOUTONS CONTOUR ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreenLight,
          side: const BorderSide(color: primaryGreenLight, width: 1.8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── BOUTONS TEXTE ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreenLight,
          textStyle: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── CARTES ──
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: darkBorder, width: 1.2),
        ),
      ),

      // ── FLOATING ACTION BUTTON ──
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryGreenLight,
        foregroundColor: const Color(0xFF052E16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // ── DIALOGUES ──
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: darkTextPrimary,
        ),
      ),

      // ── BOTTOM SHEET ──
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      // ── PROGRESS INDICATOR ──
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGreenLight,
        linearTrackColor: darkSurfaceVariant,
        circularTrackColor: darkSurfaceVariant,
      ),

      // ── CHIPS ──
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceVariant,
        labelStyle: const TextStyle(
          color: primaryGreenLight,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: Colors.transparent),
        ),
      ),

      // ── TYPOGRAPHIE SOMBRE ──
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: AppTextStyles.fontFamily, color: darkTextPrimary, fontWeight: FontWeight.w900),
        displayMedium: TextStyle(fontFamily: AppTextStyles.fontFamily, color: darkTextPrimary, fontWeight: FontWeight.w900),
        displaySmall: TextStyle(fontFamily: AppTextStyles.fontFamily, color: darkTextPrimary, fontWeight: FontWeight.w900),
        headlineLarge: TextStyle(fontFamily: AppTextStyles.fontFamily, color: darkTextPrimary, fontWeight: FontWeight.w900),
        headlineMedium: TextStyle(fontFamily: AppTextStyles.fontFamily, color: darkTextPrimary, fontWeight: FontWeight.w800),
        headlineSmall: TextStyle(fontFamily: AppTextStyles.fontFamily, color: darkTextPrimary, fontWeight: FontWeight.w800),
        titleLarge: TextStyle(fontFamily: AppTextStyles.fontFamily, color: darkTextPrimary, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontFamily: AppTextStyles.fontFamily, color: darkTextPrimary, fontWeight: FontWeight.w800),
        titleSmall: TextStyle(fontFamily: AppTextStyles.fontFamily, color: darkTextPrimary, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(fontFamily: AppTextStyles.fontFamily, color: darkTextPrimary, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontFamily: AppTextStyles.fontFamily, color: darkTextPrimary, fontWeight: FontWeight.w600),
        bodySmall: TextStyle(fontFamily: AppTextStyles.fontFamily, color: darkTextSecondary, fontWeight: FontWeight.w500),
        labelLarge: TextStyle(fontFamily: AppTextStyles.fontFamily, color: darkTextPrimary, fontWeight: FontWeight.w700),
        labelMedium: TextStyle(fontFamily: AppTextStyles.fontFamily, color: darkTextSecondary, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(fontFamily: AppTextStyles.fontFamily, color: darkTextSecondary, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Widget enveloppant automatiquement n'importe quelle vue de l'espace enfant
/// avec le [KidTheme] adapté au mode (clair/sombre) actuel.
class KidThemeScope extends StatelessWidget {
  final Widget child;

  const KidThemeScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final parentTheme = Theme.of(context);
    final isDark = parentTheme.brightness == Brightness.dark;
    final kidTheme = isDark ? KidTheme.dark : KidTheme.light;

    return Theme(data: kidTheme, child: child);
  }
}
