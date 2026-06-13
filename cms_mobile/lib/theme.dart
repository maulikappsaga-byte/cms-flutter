import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDefaultColors {
  static const Color primary = Color(0xFF00478D);
  static const Color onPrimary = Colors.white;
  static const Color background = Color(0xFFF8F9FA);
  static const Color onBackground = Color(0xFF191C1D);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color surfaceContainerLowest = Colors.white;
  static const Color onSurfaceVariant = Color(0xFF424752);
  static const Color outline = Color(0xFF727783);
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Colors.white;
  static const Color secondary = Color(0xFF595F65);
  static const Color secondaryContainer = Color(0xFFDEE3EA);
  static const Color onSecondaryContainer = Color(0xFF5F656B);
  static const Color primaryContainer = Color(0xFF005EB8);
  static const Color inputBackground = Color(0xFFEFF4FB);
  static const Color accentBlue = Color(0xFFD6E3FF);
  static const Color cardShadow = Color(0x0D000000);
}

class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color surfaceContainerLowest;
  final Color inputBackground;
  final Color accentBlue;
  final Color cardShadow;

  const AppCustomColors({
    required this.surfaceContainerLowest,
    required this.inputBackground,
    required this.accentBlue,
    required this.cardShadow,
  });

  @override
  AppCustomColors copyWith({
    Color? surfaceContainerLowest,
    Color? inputBackground,
    Color? accentBlue,
    Color? cardShadow,
  }) {
    return AppCustomColors(
      surfaceContainerLowest: surfaceContainerLowest ?? this.surfaceContainerLowest,
      inputBackground: inputBackground ?? this.inputBackground,
      accentBlue: accentBlue ?? this.accentBlue,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) {
      return this;
    }
    return AppCustomColors(
      surfaceContainerLowest: Color.lerp(surfaceContainerLowest, other.surfaceContainerLowest, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
    );
  }
}

class AppTheme {
  static Color _parseColor(Map<String, dynamic>? palette, String key, Color defaultColor) {
    if (palette == null) return defaultColor;
    if (!palette.containsKey(key)) return defaultColor;
    final value = palette[key];
    if (value == null || value is! String || value.isEmpty) return defaultColor;
    
    try {
      String hex = value.toUpperCase().replaceAll("#", "");
      if (hex.length == 6) {
        hex = "FF$hex";
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return defaultColor;
    }
  }

  static ThemeData createTheme(Map<String, dynamic>? palette) {
    final primary = _parseColor(palette, 'primary_color', AppDefaultColors.primary);
    final onPrimary = _parseColor(palette, 'on_primary_color', AppDefaultColors.onPrimary);
    final background = _parseColor(palette, 'background_color', AppDefaultColors.background);
    final surface = _parseColor(palette, 'surface_color', AppDefaultColors.surface);
    final onSurface = _parseColor(palette, 'text_color', AppDefaultColors.onSurface);
    final error = _parseColor(palette, 'error_color', AppDefaultColors.error);
    final onError = _parseColor(palette, 'on_error_color', AppDefaultColors.onError);
    final outline = _parseColor(palette, 'border_color', AppDefaultColors.outline);
    final secondary = _parseColor(palette, 'secondary_color', AppDefaultColors.secondary);
    final secondaryContainer = _parseColor(palette, 'secondary_container_color', AppDefaultColors.secondaryContainer);
    final onSecondaryContainer = _parseColor(palette, 'on_secondary_container_color', AppDefaultColors.onSecondaryContainer);
    final primaryContainer = _parseColor(palette, 'hover_active_color', AppDefaultColors.primaryContainer); // mapped hover to primary container for now
    final onSurfaceVariant = _parseColor(palette, 'text_color', AppDefaultColors.onSurfaceVariant); // using text_color for variant

    final inputBackground = _parseColor(palette, 'input_background_color', AppDefaultColors.inputBackground);
    final accentBlue = _parseColor(palette, 'accent_color', AppDefaultColors.accentBlue);
    final cardShadow = _parseColor(palette, 'card_shadow_color', AppDefaultColors.cardShadow);
    final surfaceContainerLowest = _parseColor(palette, 'surface_container_lowest_color', AppDefaultColors.surfaceContainerLowest);

    final colorScheme = ColorScheme.light(
      primary: primary,
      onPrimary: onPrimary,
      surface: surface,
      onSurface: onSurface,
      error: error,
      onError: onError,
      outline: outline,
      secondary: secondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      primaryContainer: primaryContainer,
      onSurfaceVariant: onSurfaceVariant,
    );

    final customColors = AppCustomColors(
      surfaceContainerLowest: surfaceContainerLowest,
      inputBackground: inputBackground,
      accentBlue: accentBlue,
      cardShadow: cardShadow,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      extensions: [customColors],
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineLarge: GoogleFonts.manrope(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: onSurfaceVariant,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        prefixIconColor: outline,
        hintStyle: GoogleFonts.inter(
          color: outline,
          fontSize: 16,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          textStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get lightTheme => createTheme(null);
}
