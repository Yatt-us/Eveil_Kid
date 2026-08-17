import 'package:eveilkid/core/constants/AppRadius.dart';
import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ============================================================
  // THÈME CLAIR
  // Parent / Visiteur / Manager
  // ============================================================

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,

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
      // INPUT
      // ========================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),

        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),

        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.border),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.danger),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
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
      // INPUT
      // ========================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextSecondary,
        ),

        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextSecondary,
        ),

        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.danger),
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
