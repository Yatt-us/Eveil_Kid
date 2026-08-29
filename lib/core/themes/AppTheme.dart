import 'package:eveilkid/core/constants/AppRadius.dart';
import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
export 'kid_theme.dart';

class AppTheme {
  AppTheme._();

  // ============================================================
  // THÈME CLAIR
  // Parent / Visiteur / Manager
  // ============================================================

  static const PageTransitionsTheme _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
      TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
    },
  );

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      pageTransitionsTheme: _pageTransitionsTheme,

      brightness: Brightness.light,

      fontFamily: AppTextStyles.fontFamily,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.white,

        secondary: AppColors.secondary,
        onSecondary: AppColors.white,

        error: AppColors.danger,
        onError: AppColors.white,

        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.border,
      ),

      scaffoldBackgroundColor: AppColors.background,

      // ========================================================
      // APP BAR
      // ========================================================
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headingMedium,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.surface,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),

      // ========================================================
      // TAB BAR (Clean, Flat & Moderne)
      // ========================================================
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ========================================================
      // CARD
      // ========================================================
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),

      // ========================================================
      // INPUT (Flat, Simple, Professionnel, Bordure active minime)
      // ========================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary.withValues(alpha: 0.7),
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: AppColors.border,
            width: 1.0,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: AppColors.border,
            width: 1.0,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 1.2,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: AppColors.danger,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: AppColors.danger,
            width: 1.2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
      ),

      // ========================================================
      // ELEVATED BUTTON
      // ========================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,

          elevation: 0,

          minimumSize: const Size(double.infinity, 52),

          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),

          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      // ========================================================
      // OUTLINED BUTTON
      // ========================================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,

          minimumSize: const Size(double.infinity, 52),

          side: const BorderSide(color: AppColors.primary),

          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),

          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      // ========================================================
      // TEXT BUTTON
      // ========================================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,

          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),

          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // ========================================================
      // ICON
      // ========================================================
      iconTheme: const IconThemeData(color: AppColors.icon, size: 24),

      // ========================================================
      // DIVIDER
      // ========================================================
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // ========================================================
      // BOTTOM NAVIGATION BAR
      // ========================================================
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.icon,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ========================================================
      // SNACKBAR
      // ========================================================
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),

        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
        ),
      ),

      // ========================================================
      // DIALOG
      // ========================================================
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,

        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),

        titleTextStyle: AppTextStyles.headingMedium.copyWith(
          color: AppColors.textPrimary,
        ),

        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // ============================================================
  // THÈME SOMBRE
  // Parent / Visiteur / Manager
  // ============================================================

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      pageTransitionsTheme: _pageTransitionsTheme,

      brightness: Brightness.dark,

      fontFamily: AppTextStyles.fontFamily,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.white,

        secondary: AppColors.secondary,
        onSecondary: AppColors.white,

        error: AppColors.danger,
        onError: AppColors.white,

        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        surfaceContainerHighest: AppColors.darkSurfaceVariant,
        onSurfaceVariant: AppColors.darkTextSecondary,
        outline: AppColors.darkBorder,
      ),

      scaffoldBackgroundColor: AppColors.darkBackground,

      // ========================================================
      // APP BAR
      // ========================================================
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headingMedium,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.darkSurface,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      // ========================================================
      // TAB BAR (Clean, Flat & Moderne)
      // ========================================================
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primaryLight,
        unselectedLabelColor: AppColors.darkTextSecondary,
        indicatorColor: AppColors.primaryLight,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ========================================================
      // CARD
      // ========================================================
      cardTheme: const CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),

      // ========================================================
      // INPUT (Flat, Simple, Professionnel, Bordure active minime)
      // ========================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextSecondary.withValues(alpha: 0.7),
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primaryLight,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: AppColors.darkBorder,
            width: 1.0,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: AppColors.darkBorder,
            width: 1.0,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: AppColors.primaryLight,
            width: 1.2,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: AppColors.danger,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: AppColors.danger,
            width: 1.2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: AppColors.darkBorder.withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
      ),

      // ========================================================
      // BUTTON
      // ========================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,

          elevation: 0,

          minimumSize: const Size(double.infinity, 52),

          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),

          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),

          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,

          minimumSize: const Size(double.infinity, 52),

          side: const BorderSide(color: AppColors.primaryLight),

          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),

          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,

          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),

          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      // ========================================================
      // ICON
      // ========================================================
      iconTheme: const IconThemeData(color: AppColors.darkIcon, size: 24),

      // ========================================================
      // DIVIDER
      // ========================================================
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.darkIcon,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ========================================================
      // DIALOG
      // ========================================================
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,

        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),

        titleTextStyle: AppTextStyles.headingMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),

        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextSecondary,
        ),
      ),
    );
  }

  // ============================================================
  // THÈME ENFANT
  // ============================================================

  static ThemeData get child {
    return ThemeData(
      useMaterial3: true,
      pageTransitionsTheme: _pageTransitionsTheme,

      brightness: Brightness.light,

      fontFamily: AppTextStyles.fontFamily,

      colorScheme: const ColorScheme.light(
        primary: AppColors.childPrimary,
        onPrimary: AppColors.white,

        secondary: AppColors.childSecondary,
        onSecondary: AppColors.white,

        error: AppColors.danger,
        onError: AppColors.white,

        surface: AppColors.childSurface,
        onSurface: AppColors.childTextPrimary,
      ),

      scaffoldBackgroundColor: AppColors.childBackground,

      // ========================================================
      // APP BAR
      // ========================================================
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.childSurface,
        foregroundColor: AppColors.childTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.childTitle,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.childSurface,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),

      // ========================================================
      // CARD
      // ========================================================
      cardTheme: const CardThemeData(
        color: AppColors.childSurface,
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.childCard),
      ),

      // ========================================================
      // INPUT
      // ========================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.childSurfaceVariant,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.childTextSecondary,
        ),

        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.childBorder),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.childBorder),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.childPrimary, width: 2),
        ),
      ),

      // ========================================================
      // BUTTON
      // ========================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.childPrimary,
          foregroundColor: AppColors.white,

          elevation: 2,

          minimumSize: const Size(double.infinity, 54),

          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),

          shape: RoundedRectangleBorder(borderRadius: AppRadius.childButton),

          textStyle: AppTextStyles.childButton,
        ),
      ),

      // ========================================================
      // OUTLINED BUTTON
      // ========================================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.childPrimaryDark,

          minimumSize: const Size(double.infinity, 54),

          side: const BorderSide(color: AppColors.childPrimary),

          shape: RoundedRectangleBorder(borderRadius: AppRadius.childButton),

          textStyle: AppTextStyles.childButton,
        ),
      ),

      // ========================================================
      // TEXT BUTTON
      // ========================================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.childPrimaryDark,

          shape: RoundedRectangleBorder(borderRadius: AppRadius.childButton),

          textStyle: AppTextStyles.childButton,
        ),
      ),

      // ========================================================
      // ICON
      // ========================================================
      iconTheme: const IconThemeData(
        color: AppColors.childPrimaryDark,
        size: 26,
      ),

      // ========================================================
      // DIVIDER
      // ========================================================
      dividerTheme: const DividerThemeData(
        color: AppColors.childBorder,
        thickness: 1,
        space: 1,
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.childSurface,
        selectedItemColor: AppColors.childPrimary,
        unselectedItemColor: AppColors.childTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ========================================================
      // DIALOG
      // ========================================================
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.childSurface,

        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),

        titleTextStyle: AppTextStyles.childCardTitle.copyWith(
          color: AppColors.childTextPrimary,
        ),

        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.childTextSecondary,
        ),
      ),
    );
  }
}
