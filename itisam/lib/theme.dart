import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ItisamColors {
  static const emerald = Color(0xFF0E6B4F);
  static const deepGreen = Color(0xFF051B14);
  static const darkSurface = Color(0xFF0B2A20);
  static const cardSurface = Color(0xFF0F3427);
  static const gold = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFF0D98C);
  static const cream = Color(0xFFF5EFDD);
  static const faint = Color(0xFF9DB8AE);
}

ThemeData buildItisamTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: ItisamColors.emerald,
    brightness: Brightness.dark,
    primary: ItisamColors.emerald,
    secondary: ItisamColors.gold,
    surface: ItisamColors.darkSurface,
  );

  final cairo = GoogleFonts.cairoTextTheme();
  final amiri = GoogleFonts.amiriTextTheme();

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: ItisamColors.deepGreen,
    fontFamily: GoogleFonts.cairo().fontFamily,
    textTheme: cairo.apply(
      bodyColor: ItisamColors.cream,
      displayColor: ItisamColors.cream,
    ),
  );

  final displayColor = ItisamColors.cream;
  final bodyTextTheme = base.textTheme.copyWith(
    displayLarge: amiri.displayLarge!.copyWith(color: displayColor),
    displayMedium: amiri.displayMedium!.copyWith(color: displayColor),
    headlineLarge: amiri.headlineLarge!.copyWith(color: displayColor),
    headlineMedium: amiri.headlineMedium!.copyWith(color: displayColor),
    headlineSmall: amiri.headlineSmall!.copyWith(color: displayColor),
    titleLarge: amiri.titleLarge!.copyWith(color: displayColor),
    titleMedium: cairo.titleMedium!.copyWith(color: displayColor),
    titleSmall: cairo.titleSmall!.copyWith(color: displayColor),
    bodyLarge: cairo.bodyLarge!.copyWith(color: ItisamColors.cream),
    bodyMedium: cairo.bodyMedium!.copyWith(color: ItisamColors.faint),
    bodySmall: cairo.bodySmall!.copyWith(color: ItisamColors.faint),
    labelLarge: cairo.labelLarge!.copyWith(color: ItisamColors.goldLight),
    labelMedium: cairo.labelMedium!.copyWith(color: ItisamColors.goldLight),
  );

  return base.copyWith(textTheme: bodyTextTheme);
}