import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    const seed = Color(0xFF0E9F6E);
    const textColor = Color(0xFF182230);

    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFFF6F8FB),
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        primary: seed,
        secondary: const Color(0xFF2563EB),
        tertiary: const Color(0xFFF59E0B),
        surface: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: textColor, fontWeight: FontWeight.w900),
        titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.w900),
        titleMedium: TextStyle(color: textColor, fontWeight: FontWeight.w800),
        bodyMedium: TextStyle(color: Color(0xFF475467)),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFFF6F8FB),
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
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
          borderSide: const BorderSide(color: seed, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: const BorderSide(color: Color(0xFFD7DEE8)),
        selectedColor: const Color(0xFFD7F0E5),
        backgroundColor: Colors.white,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFD7F0E5),
        labelTextStyle: WidgetStateProperty.all(const TextStyle(fontWeight: FontWeight.w800)),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    const seed = Color(0xFF0E9F6E);
    const surface = Color(0xFF111827);
    const card = Color(0xFF182230);
    const textColor = Color(0xFFF9FAFB);

    return ThemeData(
      scaffoldBackgroundColor: surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
        primary: const Color(0xFF34D399),
        secondary: const Color(0xFF60A5FA),
        tertiary: const Color(0xFFFBBF24),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
          borderSide: const BorderSide(color: seed, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: const BorderSide(color: Color(0xFF344054)),
        selectedColor: const Color(0xFF064E3B),
        backgroundColor: card,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: const Color(0xFF064E3B),
        labelTextStyle: WidgetStateProperty.all(const TextStyle(fontWeight: FontWeight.w800)),
      ),
      useMaterial3: true,
    );
  }
}
