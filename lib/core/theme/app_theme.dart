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
      fontFamily: 'Work Sans',
      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Fraunces',
          color: ink,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerColor: line,
      cardTheme: CardThemeData(
        color: paper,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: paper,
        indicatorColor: Colors.transparent,
        height: 58,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected) ? ink : muted,
            fontSize: 10,
          ),
        ),
      ),
      textTheme: Typography.material2021().black
          .apply(fontFamily: 'Work Sans', bodyColor: ink, displayColor: ink)
          .copyWith(
            headlineMedium: const TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 34,
              fontWeight: FontWeight.w500,
              color: ink,
            ),
            titleLarge: const TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: ink,
            ),
          ),
    );
  }
}
