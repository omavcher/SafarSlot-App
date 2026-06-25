import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized font system for SafarSlot
///
/// Primary Font   → Poppins   (headings, titles, UI labels, buttons)
/// Secondary Font → Inter     (numbers, data, station codes, time values)
/// Regional Font  → Noto Sans (Hindi, Marathi, and other Indic scripts)
class AppFonts {
  AppFonts._(); // Non-instantiable

  // ---------------------------------------------------------------------------
  // PRIMARY: Poppins — used for all general UI text via ThemeData
  // ---------------------------------------------------------------------------

  /// Poppins TextTheme — apply this to ThemeData.textTheme
  static TextTheme poppinsTextTheme([TextTheme? base]) =>
      GoogleFonts.poppinsTextTheme(base);

  /// Combined TextTheme: Poppins for headings and buttons, Inter for body/content
  static TextTheme combinedTextTheme([TextTheme? base]) {
    final baseTheme = base ?? ThemeData.light().textTheme;
    final poppinsTheme = GoogleFonts.poppinsTextTheme(baseTheme);
    final interTheme = GoogleFonts.interTextTheme(baseTheme);
    
    return poppinsTheme.copyWith(
      bodyLarge: interTheme.bodyLarge,
      bodyMedium: interTheme.bodyMedium,
      bodySmall: interTheme.bodySmall,
      labelLarge: poppinsTheme.labelLarge,
      labelMedium: interTheme.labelMedium,
      labelSmall: interTheme.labelSmall,
    );
  }

  /// Quick shorthand: Poppins style with custom params
  static TextStyle poppins({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  // ---------------------------------------------------------------------------
  // SECONDARY: Inter — used for numbers, codes, timestamps, data fields
  // ---------------------------------------------------------------------------

  /// Quick shorthand: Inter style with custom params
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  // ---------------------------------------------------------------------------
  // REGIONAL: Noto Sans — used for Hindi, Marathi, and all Indic scripts
  // ---------------------------------------------------------------------------

  /// Noto Sans style for Devanagari (Hindi / Marathi) and other regional scripts
  static TextStyle notoSans({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.notoSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  // ---------------------------------------------------------------------------
  // COMMON PRESET STYLES  (reusable across the app)
  // ---------------------------------------------------------------------------

  // --- Poppins presets ---
  static TextStyle get appBarTitle => poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0F172A),
      );

  static TextStyle get sectionHeading => poppins(
        fontSize: 16.5,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF0F172A),
      );

  static TextStyle get bodyMedium => inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF334155),
      );

  static TextStyle get labelSmall => inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF64748B),
      );

  static TextStyle get buttonText => poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.3,
      );

  // --- Inter presets (data / numbers) ---
  static TextStyle get trainTime => inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0F172A),
      );

  static TextStyle get trainCode => inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF64748B),
        letterSpacing: 0.5,
      );

  static TextStyle get pnrNumber => inter(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: const Color(0xFF0F172A),
      );

  // --- Noto Sans presets (regional language) ---
  static TextStyle get hindiTagline => notoSans(
        fontSize: 13.5,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF0F172A),
      );

  static TextStyle get regionalNativeName => notoSans(
        fontSize: 13.5,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF0F172A),
      );
}
