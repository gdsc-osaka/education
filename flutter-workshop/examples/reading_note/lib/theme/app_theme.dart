import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppPalette {
  AppPalette._();

  static const Color cream = Color(0xFFF1E9D2);
  static const Color creamDeep = Color(0xFFE6DAB8);
  static const Color paper = Color(0xFFF6F0DC);
  static const Color ink = Color(0xFF1B1610);
  static const Color inkSoft = Color(0xFF3D342A);
  static const Color inkMuted = Color(0xFF7A6B54);
  static const Color hairline = Color(0xFFBFB39A);
  static const Color hairlineSoft = Color(0xFFD8CDB1);
  static const Color accent = Color(0xFF8E2A1F);
  static const Color accentBright = Color(0xFFB54838);
  static const Color highlight = Color(0xFFE5C97A);
}

class AppRadii {
  AppRadii._();
  static const double pill = 999;
  static const double card = 4;
}

TextTheme _buildTextTheme() {
  final base = ThemeData.light().textTheme;
  final body = GoogleFonts.shipporiMinchoTextTheme(base);

  TextStyle disp(double size, {FontWeight weight = FontWeight.w700, double height = 1.1, Color? color, double letter = -0.5}) {
    return GoogleFonts.shipporiMincho(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letter,
      color: color ?? AppPalette.ink,
    );
  }

  TextStyle serif(double size, {FontWeight weight = FontWeight.w400, double height = 1.55, Color? color, double letter = 0}) {
    return GoogleFonts.shipporiMincho(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letter,
      color: color ?? AppPalette.inkSoft,
    );
  }

  return body.copyWith(
    displayLarge: disp(48, weight: FontWeight.w800, letter: -1.2),
    displayMedium: disp(34, weight: FontWeight.w700, letter: -0.8),
    displaySmall: disp(26, weight: FontWeight.w700, letter: -0.4),
    headlineLarge: disp(28, weight: FontWeight.w700, letter: -0.4),
    headlineMedium: disp(22, weight: FontWeight.w600, letter: -0.2),
    headlineSmall: disp(18, weight: FontWeight.w600, letter: -0.1),
    titleLarge: serif(20, weight: FontWeight.w700, color: AppPalette.ink, height: 1.3),
    titleMedium: serif(16, weight: FontWeight.w600, color: AppPalette.ink),
    titleSmall: serif(14, weight: FontWeight.w600, color: AppPalette.ink),
    bodyLarge: serif(16, color: AppPalette.inkSoft),
    bodyMedium: serif(14, color: AppPalette.inkSoft),
    bodySmall: serif(12, color: AppPalette.inkMuted),
    labelLarge: serif(13, weight: FontWeight.w600, color: AppPalette.ink, letter: 0.8),
    labelMedium: serif(11, weight: FontWeight.w600, color: AppPalette.inkMuted, letter: 1.2),
    labelSmall: serif(10, weight: FontWeight.w600, color: AppPalette.inkMuted, letter: 1.4),
  );
}

TextStyle editorialLabel({Color? color, double size = 11, double letter = 2.0}) {
  return GoogleFonts.crimsonPro(
    fontSize: size,
    fontWeight: FontWeight.w600,
    letterSpacing: letter,
    color: color ?? AppPalette.inkMuted,
    height: 1.2,
  );
}

TextStyle editorialItalic({Color? color, double size = 14}) {
  return GoogleFonts.crimsonPro(
    fontSize: size,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w500,
    color: color ?? AppPalette.inkMuted,
    height: 1.4,
  );
}

class AppTheme {
  static ThemeData build() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppPalette.accent,
      brightness: Brightness.light,
      primary: AppPalette.accent,
      onPrimary: AppPalette.cream,
      secondary: AppPalette.ink,
      onSecondary: AppPalette.cream,
      surface: AppPalette.cream,
      onSurface: AppPalette.ink,
      error: AppPalette.accent,
    );

    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppPalette.cream,
      canvasColor: AppPalette.cream,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      dividerColor: AppPalette.hairline,
      dividerTheme: const DividerThemeData(
        color: AppPalette.hairlineSoft,
        thickness: 0.6,
        space: 0,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppPalette.cream,
        surfaceTintColor: AppPalette.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppPalette.ink,
        centerTitle: false,
        titleTextStyle: textTheme.titleMedium,
        toolbarHeight: 64,
      ),
      iconTheme: const IconThemeData(color: AppPalette.ink, size: 20),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppPalette.ink,
        contentTextStyle: GoogleFonts.shipporiMincho(
          color: AppPalette.cream,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: AppPalette.highlight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        elevation: 0,
      ),
      splashFactory: InkSparkle.splashFactory,
      splashColor: AppPalette.accent.withValues(alpha: 0.06),
      highlightColor: AppPalette.accent.withValues(alpha: 0.04),
      hoverColor: AppPalette.accent.withValues(alpha: 0.04),
    );
  }
}
