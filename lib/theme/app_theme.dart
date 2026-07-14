import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SageColors {
  // Primary - Green (Activity/Tasks theme)
  static const primary = Color(0xFF348E73);
  static const primaryContainer = Color(0xFFD5EBE1);
  static const primaryDim = Color(0xFF266E58);
  static const onPrimary = Color(0xFF1E1E1E);

  // Secondary - Coral/Red (Wellness/Team theme)
  static const secondary = Color(0xFFC95B50);
  static const secondaryContainer = Color(0xFFFAD1C7);
  static const secondaryDim = Color(0xFFA63C33);
  static const onSecondary = Color(0xFF1E1E1E);

  // Tertiary - Lavender/Purple (Sleep/Finance theme)
  static const tertiary = Color(0xFF7E72CF);
  static const tertiaryContainer = Color(0xFFE4E1F4);
  static const tertiaryDim = Color(0xFF5348A6);

  // Yellow Accent (Bottom Bar / Tabs / Highlights)
  static const yellowAccent = Color(0xFFFFD56B);
  static const yellowAccentContainer = Color(0xFFFFF0C2);

  // Error / Danger
  static const error = Color(0xFFD32F2F);
  static const errorContainer = Color(0xFFFFCDD2);
  static const errorDim = Color(0xFFB71C1C);

  // Background - Neo-Brutalist Light Cream
  static const background = Color(0xFFFCF8F2);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFFBF6EE);
  static const surfaceContainer = Color(0xFFF7ECE0);
  static const surfaceContainerHigh = Color(0xFFF5E5D5);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);

  // Text
  static const onSurface = Color(0xFF1E1E1E);
  static const onSurfaceVariant = Color(0xFF555555);
  static const onBackground = Color(0xFF1E1E1E);

  // Outline (Classic black borders for neo-brutalism)
  static const outline = Color(0xFF000000);
  static const outlineVariant = Color(0xFF000000);

  // Neo-brutalist flat offset shadows
  static List<BoxShadow> neonGlow(Color color, {double spread = 0, double blur = 0}) => [
    BoxShadow(
      color: Colors.black,
      blurRadius: 0,
      spreadRadius: 0,
      offset: const Offset(3, 3),
    ),
  ];

  static List<Shadow> neonTextGlow(Color color) => [];

  // Reusable Neo-Brutalist Border Decoration
  static BoxDecoration brutalistDecoration({
    Color backgroundColor = Colors.white,
    double borderRadius = 16.0,
    Color borderColor = Colors.black,
    double borderWidth = 1.5,
    bool hasShadow = true,
    double shadowOffset = 3.0,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: hasShadow
          ? [
              BoxShadow(
                color: Colors.black,
                offset: Offset(shadowOffset, shadowOffset),
                blurRadius: 0,
              ),
            ]
          : null,
    );
  }
}

class SageTheme {
  static ThemeData get dark {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: SageColors.primary,
        primaryContainer: SageColors.primaryContainer,
        onPrimary: SageColors.onPrimary,
        secondary: SageColors.secondary,
        secondaryContainer: SageColors.secondaryContainer,
        onSecondary: SageColors.onSecondary,
        tertiary: SageColors.tertiary,
        surface: SageColors.surface,
        onSurface: SageColors.onSurface,
        onSurfaceVariant: SageColors.onSurfaceVariant,
        outline: SageColors.outline,
        error: SageColors.error,
      ),
      scaffoldBackgroundColor: SageColors.background,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme).apply(
        bodyColor: SageColors.onSurface,
        displayColor: SageColors.onSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SageColors.background,
        foregroundColor: SageColors.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: SageColors.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: SageColors.outline, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: SageColors.outline, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: SageColors.outline, width: 2.0),
        ),
        filled: true,
        fillColor: SageColors.surface,
        hintStyle: const TextStyle(color: SageColors.onSurfaceVariant, fontSize: 13),
        labelStyle: const TextStyle(color: SageColors.onSurface, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SageColors.yellowAccent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.black, width: 1.5),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.black, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      dividerTheme: const DividerThemeData(color: SageColors.outline, thickness: 1.5),
      cardTheme: CardThemeData(
        color: SageColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.black, width: 1.5),
        ),
        margin: EdgeInsets.zero,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: SageColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        titleTextStyle: const TextStyle(
          color: SageColors.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SageColors.yellowAccentContainer,
        contentTextStyle: const TextStyle(color: Colors.black, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black, width: 1.5),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return SageColors.yellowAccent;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.black),
        side: const BorderSide(color: SageColors.outline, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(SageColors.surface),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.black, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}

