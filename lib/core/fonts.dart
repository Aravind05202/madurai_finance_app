import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Matches the web app's type system:
///   --serif: "Fraunces"        -> headings, brand titles, big numbers
///   --sans:  "Plus Jakarta Sans" / "Inter" -> body / UI text
///   --mono:  "JetBrains Mono"  -> money figures, loan IDs, reference numbers
class AppText {
  static TextStyle display({
    double size = 24,
    Color? color,
    FontWeight weight = FontWeight.w700,
    double? letterSpacing,
  }) =>
      GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.18,
        letterSpacing: letterSpacing,
      );

  static TextStyle heading({
    double size = 20,
    Color? color,
    FontWeight weight = FontWeight.w700,
    double? letterSpacing,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.25,
        letterSpacing: letterSpacing ?? -0.2,
      );

  static TextStyle body({
    double size = 14,
    Color? color,
    FontWeight weight = FontWeight.w400,
    double height = 1.45,
    double? letterSpacing,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle mono({
    double size = 14,
    Color? color,
    FontWeight weight = FontWeight.w600,
    double? letterSpacing,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing ?? -0.3,
      );

  static TextStyle badge({
    double size = 11,
    Color? color,
    FontWeight weight = FontWeight.w700,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: 0.4,
      );
}

