import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // no instances — static access only

  // Backgrounds
  static const Color background = Color(0xFF0B1611);   // deep green-black
  static const Color card = Color(0xFF13251E);          // card surface
  static const Color cardLight = Color(0xFF1A3129);     // elevated surface

  // Brand
  static const Color gold = Color(0xFFE0A468);          // copper-gold (prices)
  static const Color goldDark = Color(0xFFB8860B);
  static const Color goldSoft = Color(0xFFEFC79A);

  // Semantic
  static const Color positive = Color(0xFF3DD68C);      // green +%
  static const Color negative = Color(0xFFE05D5D);      // red -%

  // Text
  static const Color textPrimary = Color(0xFFF4F1EC);
  static const Color textSecondary = Color(0xFF8FA39A);
  static const Color textMuted = Color(0xFF5E7169);

  // Misc
  static const Color divider = Color(0xFF22382F);
  static const Color chipBackground = Color(0xFF1E362D);
}