import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// `color` is REQUIRED on purpose. It turns the analyzer into a
/// migration checklist — every call site must state which palette
/// color it wants, so nothing silently stays light-mode-only.
class AppText {
  AppText._();

  static TextStyle price(double size, {required Color color}) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle heading(double size,
          {required Color color, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.25,
      );

  static TextStyle label(double size,
          {required Color color, FontWeight weight = FontWeight.w500}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.35,
      );

  static TextStyle micro(double size,
          {required Color color, FontWeight weight = FontWeight.w600}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: 1.1,
        height: 1.2,
      );
}