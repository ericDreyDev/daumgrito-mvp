import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    const primary = Color(0xFF0757B8);
    const secondary = Color(0xFF0287D9);
    const accent = Color(0xFFFF7A00);
    const textColor = Color(0xFF10233F);

    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFFF7FAFE),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: Colors.white,
        primaryContainer: const Color(0xFFE5F1FF),
        secondaryContainer: const Color(0xFFE0F4FF),
        tertiaryContainer: const Color(0xFFFFE4C7),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: textColor, fontWeight: FontWeight.w900),
        titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.w900),
        titleMedium: TextStyle(color: textColor, fontWeight: FontWeight.w800),
        bodyMedium: TextStyle(color: Color(0xFF516070)),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFFF7FAFE),
        foregroundColor: textColor,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFE5EAF1)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD7DEE8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: const BorderSide(color: Color(0xFFD7DEE8)),
        selectedColor: const Color(0xFFE0F4FF),
        backgroundColor: Colors.white,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFFFE4C7),
        labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w800)),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    const primary = Color(0xFF4FB2FF);
    const surface = Color(0xFF071A33);
    const card = Color(0xFF10233F);
    const textColor = Color(0xFFF9FAFB);

    return ThemeData(
      scaffoldBackgroundColor: surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        secondary: const Color(0xFF64C7FF),
        tertiary: const Color(0xFFFF9B22),
        surface: card,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: textColor, fontWeight: FontWeight.w900),
        titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.w900),
        titleMedium: TextStyle(color: textColor, fontWeight: FontWeight.w800),
        bodyMedium: TextStyle(color: Color(0xFFD0D5DD)),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: surface,
        foregroundColor: textColor,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF344054)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF344054)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: const BorderSide(color: Color(0xFF344054)),
        selectedColor: const Color(0xFF063F7A),
        backgroundColor: card,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: const Color(0xFF7A3800),
        labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w800)),
      ),
      useMaterial3: true,
    );
  }
}
