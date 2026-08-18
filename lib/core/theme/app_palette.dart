import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color surface;
  final Color surfaceAlt;

  final Color brass;
  final Color brassLight;
  final Color onBrass;

  final Color positive;
  final Color positiveSoft;
  final Color negative;
  final Color negativeSoft;
  final Color live;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  final Color border;
  final Color divider;
  final Color cardShadow;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.brass,
    required this.brassLight,
    required this.onBrass,
    required this.positive,
    required this.positiveSoft,
    required this.negative,
    required this.negativeSoft,
    required this.live,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.divider,
    required this.cardShadow,
  });

  static const light = AppPalette(
    background: Color(0xFFFAF7F2),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF1EDE6),
    brass: Color(0xFF8A6A2F),
    brassLight: Color(0xFFB89B63),
    onBrass: Color(0xFFFFFFFF),
    positive: Color(0xFF1F7A54),
    positiveSoft: Color(0xFFE6F2EC),
    negative: Color(0xFFB3402F),
    negativeSoft: Color(0xFFFBEAE7),
    live: Color(0xFFD1493A),
    textPrimary: Color(0xFF1C1A17),
    textSecondary: Color(0xFF6B6459),
    textMuted: Color(0xFF8B8378),
    border: Color(0xFFE8E2D8),
    divider: Color(0xFFEFEAE1),
    cardShadow: Color(0x0F1C1A17),
  );

  static const dark = AppPalette(
    background: Color(0xFF121212),
    surface: Color(0xFF1C1C1C),
    surfaceAlt: Color(0xFF262626),
    // Lifted for contrast — #8A6A2F fails WCAG on a dark background.
    brass: Color(0xFFC9A961),
    brassLight: Color(0xFFDCC48D),
    onBrass: Color(0xFF1A1408),
    positive: Color(0xFF3DBE86),
    positiveSoft: Color(0xFF14312A),
    negative: Color(0xFFE0705C),
    negativeSoft: Color(0xFF3A1E19),
    live: Color(0xFFE0705C),
    textPrimary: Color(0xFFF5F3EF),
    textSecondary: Color(0xFFB0AAA0),
    textMuted: Color(0xFF7A736A),
    border: Color(0xFF2E2E2E),
    divider: Color(0xFF262626),
    cardShadow: Color(0x33000000),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? brass,
    Color? brassLight,
    Color? onBrass,
    Color? positive,
    Color? positiveSoft,
    Color? negative,
    Color? negativeSoft,
    Color? live,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? divider,
    Color? cardShadow,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      brass: brass ?? this.brass,
      brassLight: brassLight ?? this.brassLight,
      onBrass: onBrass ?? this.onBrass,
      positive: positive ?? this.positive,
      positiveSoft: positiveSoft ?? this.positiveSoft,
      negative: negative ?? this.negative,
      negativeSoft: negativeSoft ?? this.negativeSoft,
      live: live ?? this.live,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  /// Lets Flutter animate smoothly between light and dark.
  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      brass: Color.lerp(brass, other.brass, t)!,
      brassLight: Color.lerp(brassLight, other.brassLight, t)!,
      onBrass: Color.lerp(onBrass, other.onBrass, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      positiveSoft: Color.lerp(positiveSoft, other.positiveSoft, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      negativeSoft: Color.lerp(negativeSoft, other.negativeSoft, t)!,
      live: Color.lerp(live, other.live, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
    );
  }
}

/// Short accessor: `context.c.brass`
extension AppPaletteX on BuildContext {
  AppPalette get c => Theme.of(this).extension<AppPalette>()!;
}