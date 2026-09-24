import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shenai_skd_integration/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final baseText = GoogleFonts.vazirmatnTextTheme(ThemeData.light().textTheme);

    final textTheme = baseText.copyWith(
      displayLarge: baseText.displayLarge?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.25,
      ),
      displayMedium: baseText.displayMedium?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.3,
      ),
      headlineLarge: baseText.headlineLarge?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.35,
      ),
      headlineMedium: baseText.headlineMedium?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.35,
      ),
      headlineSmall: baseText.headlineSmall?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.35,
      ),
      titleLarge: baseText.titleLarge?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      titleSmall: baseText.titleSmall?.copyWith(
        color: AppColors.champagne,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      bodyLarge: baseText.bodyLarge?.copyWith(
        color: AppColors.mist,
        fontWeight: FontWeight.w400,
        height: 1.7,
      ),
      bodyMedium: baseText.bodyMedium?.copyWith(
        color: AppColors.mist,
        fontWeight: FontWeight.w400,
        height: 1.65,
      ),
      bodySmall: baseText.bodySmall?.copyWith(
        color: AppColors.muted,
        fontWeight: FontWeight.w400,
        height: 1.55,
      ),
      labelLarge: baseText.labelLarge?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      labelMedium: baseText.labelMedium?.copyWith(
        color: AppColors.muted,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      labelSmall: baseText.labelSmall?.copyWith(
        color: AppColors.muted,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );

    final colorScheme = ColorScheme.light(
      primary: AppColors.champagneSoft,
      onPrimary: Colors.white,
      secondary: AppColors.champagne,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      error: AppColors.coral,
      onError: Colors.white,
      outline: AppColors.hairline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.canvas,
      fontFamily: GoogleFonts.vazirmatn().fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.hairline,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.champagneSoft, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.coral),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.coral, width: 1.5),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceMuted,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.hairline),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.champagneSoft;
          }
          return AppColors.surfaceMuted;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.champagneSoft,
        circularTrackColor: AppColors.surfaceMuted,
        linearTrackColor: AppColors.surfaceMuted,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Kept for callers; bright professional theme is the only theme.
  static ThemeData get dark => light;
}
