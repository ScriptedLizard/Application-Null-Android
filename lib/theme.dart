import 'package:flutter/material.dart';

class AppTheme {
  final String name;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color onPrimary;
  final Color onBackground;
  final Color accent;

  const AppTheme({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.onPrimary,
    required this.onBackground,
    required this.accent,
  });

  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: _isDark ? Brightness.dark : Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: onPrimary,
        error: Colors.red,
        onError: Colors.white,
        background: background,
        onBackground: onBackground,
        surface: surface,
        onSurface: onBackground,
      ),
      scaffoldBackgroundColor: background,
      cardColor: surface,
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return primary;
          return surface;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return primary.withOpacity(0.5);
          return onBackground.withOpacity(0.2);
        }),
      ),
    );
  }

  bool get _isDark => background.computeLuminance() < 0.5;
}

class AppThemes {
  static const List<AppTheme> presets = [
    AppTheme(
      name: 'Null Dark',
      primary: Color(0xFF6750A4),
      secondary: Color(0xFF625B71),
      background: Color(0xFF1C1B1F),
      surface: Color(0xFF2B2930),
      onPrimary: Colors.white,
      onBackground: Color(0xFFE6E1E5),
      accent: Color(0xFFD0BCFF),
    ),
    AppTheme(
      name: 'Cotton Cloud',
      primary: Color(0xFF4A90D9),
      secondary: Color(0xFF7EC8E3),
      background: Color(0xFFF5F9FF),
      surface: Color(0xFFFFFFFF),
      onPrimary: Colors.white,
      onBackground: Color(0xFF1A2B3C),
      accent: Color(0xFF4A90D9),
    ),
    AppTheme(
      name: 'Matcha',
      primary: Color(0xFF4CAF72),
      secondary: Color(0xFF81C784),
      background: Color(0xFF1A211C),
      surface: Color(0xFF243028),
      onPrimary: Colors.white,
      onBackground: Color(0xFFD8F0DC),
      accent: Color(0xFF69F0AE),
    ),
    AppTheme(
      name: 'Ember',
      primary: Color(0xFFE64A19),
      secondary: Color(0xFFFF7043),
      background: Color(0xFF1F1410),
      surface: Color(0xFF2E1C14),
      onPrimary: Colors.white,
      onBackground: Color(0xFFFFD7CC),
      accent: Color(0xFFFF6E40),
    ),
    AppTheme(
      name: 'Lavender Mist',
      primary: Color(0xFF9C6FD6),
      secondary: Color(0xFFCE93D8),
      background: Color(0xFFFAF5FF),
      surface: Color(0xFFFFFFFF),
      onPrimary: Colors.white,
      onBackground: Color(0xFF2D1B4E),
      accent: Color(0xFF9C6FD6),
    ),
    AppTheme(
      name: 'Midnight Blue',
      primary: Color(0xFF1565C0),
      secondary: Color(0xFF42A5F5),
      background: Color(0xFF0A0E1A),
      surface: Color(0xFF111829),
      onPrimary: Colors.white,
      onBackground: Color(0xFFCCDDFF),
      accent: Color(0xFF40C4FF),
    ),
    AppTheme(
      name: 'Rose Gold',
      primary: Color(0xFFB5737A),
      secondary: Color(0xFFD4A0A5),
      background: Color(0xFFFFF8F8),
      surface: Color(0xFFFFFFFF),
      onPrimary: Colors.white,
      onBackground: Color(0xFF3D1C20),
      accent: Color(0xFFB5737A),
    ),
    AppTheme(
      name: 'Abyss',
      primary: Color(0xFF00BCD4),
      secondary: Color(0xFF4DD0E1),
      background: Color(0xFF050A0E),
      surface: Color(0xFF0D1117),
      onPrimary: Colors.black,
      onBackground: Color(0xFFB2EBF2),
      accent: Color(0xFF00E5FF),
    ),
    AppTheme(
      name: 'Honey',
      primary: Color(0xFFF59E0B),
      secondary: Color(0xFFFBBF24),
      background: Color(0xFFFFFBF0),
      surface: Color(0xFFFFFFFF),
      onPrimary: Colors.black,
      onBackground: Color(0xFF3D2B00),
      accent: Color(0xFFF59E0B),
    ),
    AppTheme(
      name: 'Slate',
      primary: Color(0xFF607D8B),
      secondary: Color(0xFF90A4AE),
      background: Color(0xFF1A2025),
      surface: Color(0xFF243040),
      onPrimary: Colors.white,
      onBackground: Color(0xFFCFD8DC),
      accent: Color(0xFF80DEEA),
    ),
    AppTheme(
      name: 'Sakura',
      primary: Color(0xFFE91E8C),
      secondary: Color(0xFFF48FB1),
      background: Color(0xFFFFF0F5),
      surface: Color(0xFFFFFFFF),
      onPrimary: Colors.white,
      onBackground: Color(0xFF3D0020),
      accent: Color(0xFFE91E8C),
    ),
    AppTheme(
      name: 'Forest Night',
      primary: Color(0xFF2E7D32),
      secondary: Color(0xFF66BB6A),
      background: Color(0xFF0D1510),
      surface: Color(0xFF162018),
      onPrimary: Colors.white,
      onBackground: Color(0xFFC8E6C9),
      accent: Color(0xFF76FF03),
    ),
    AppTheme(
      name: 'Polar',
      primary: Color(0xFF5C6BC0),
      secondary: Color(0xFF9FA8DA),
      background: Color(0xFFF8FAFF),
      surface: Color(0xFFFFFFFF),
      onPrimary: Colors.white,
      onBackground: Color(0xFF1A1F3D),
      accent: Color(0xFF5C6BC0),
    ),
  ];

  static AppTheme fromCustom({
    required Color primary,
    required Color background,
    required Color surface,
    required Color onBackground,
    required Color accent,
  }) {
    return AppTheme(
      name: 'Custom',
      primary: primary,
      secondary: primary.withOpacity(0.7),
      background: background,
      surface: surface,
      onPrimary: background.computeLuminance() > 0.5 ? Colors.black : Colors.white,
      onBackground: onBackground,
      accent: accent,
    );
  }
}
