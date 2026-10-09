import 'package:flutter/material.dart';

class AppTheme {
  static const ink = Color(0xFF1C2437);
  static const paper = Color(0xFFF6F3EC);
  static const paperSecondary = Color(0xFFEFEAE0);
  static const line = Color(0xFFDAD3C3);
  static const sage = Color(0xFF5F7A5E);
  static const rust = Color(0xFFB5563C);
  static const gold = Color(0xFFB3934F);
  static const muted = Color(0xFF8A8578);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ink,
      brightness: Brightness.light,
      primary: ink,
      secondary: sage,
      tertiary: gold,
      error: rust,
      surface: paper,
      outline: line,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: paper,
      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: line),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: paper,
        indicatorColor: paperSecondary,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected) ? ink : muted,
            fontSize: 12,
          ),
        ),
      ),
      textTheme: Typography.material2021().black.apply(
        bodyColor: ink,
        displayColor: ink,
      ),
    );
  }
}
