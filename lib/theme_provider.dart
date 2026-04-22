import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

class ThemeProvider extends ChangeNotifier {
  int _selectedThemeIndex = 0;
  AppTheme? _customTheme;
  bool _useCustom = false;

  // Custom theme colors
  Color _customPrimary = const Color(0xFF6750A4);
  Color _customBackground = const Color(0xFF1C1B1F);
  Color _customSurface = const Color(0xFF2B2930);
  Color _customOnBackground = const Color(0xFFE6E1E5);
  Color _customAccent = const Color(0xFFD0BCFF);

  ThemeProvider() {
    _load();
  }

  AppTheme get currentTheme {
    if (_useCustom && _customTheme != null) return _customTheme!;
    return AppThemes.presets[_selectedThemeIndex];
  }

  int get selectedIndex => _selectedThemeIndex;
  bool get useCustom => _useCustom;

  Color get customPrimary => _customPrimary;
  Color get customBackground => _customBackground;
  Color get customSurface => _customSurface;
  Color get customOnBackground => _customOnBackground;
  Color get customAccent => _customAccent;

  void selectPreset(int index) {
    _selectedThemeIndex = index;
    _useCustom = false;
    _save();
    notifyListeners();
  }

  void updateCustomColor({
    Color? primary,
    Color? background,
    Color? surface,
    Color? onBackground,
    Color? accent,
  }) {
    if (primary != null) _customPrimary = primary;
    if (background != null) _customBackground = background;
    if (surface != null) _customSurface = surface;
    if (onBackground != null) _customOnBackground = onBackground;
    if (accent != null) _customAccent = accent;

    _customTheme = AppThemes.fromCustom(
      primary: _customPrimary,
      background: _customBackground,
      surface: _customSurface,
      onBackground: _customOnBackground,
      accent: _customAccent,
    );
    _useCustom = true;
    notifyListeners();
  }

  void applyCustomTheme() {
    _customTheme = AppThemes.fromCustom(
      primary: _customPrimary,
      background: _customBackground,
      surface: _customSurface,
      onBackground: _customOnBackground,
      accent: _customAccent,
    );
    _useCustom = true;
    _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_index', _selectedThemeIndex);
    await prefs.setBool('use_custom', _useCustom);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedThemeIndex = prefs.getInt('theme_index') ?? 0;
    _useCustom = prefs.getBool('use_custom') ?? false;
    notifyListeners();
  }
}
