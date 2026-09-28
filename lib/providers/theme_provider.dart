import 'package:flutter/material.dart';
import '../core/storage/game_storage.dart';
import '../core/theme/game_theme.dart';

/// ThemeProvider gérant de manière réactive les thèmes et le mode Sombre / Clair
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  GameThemeMode _currentMode = GameThemeMode.neonArcade;
  late GameTheme _currentTheme;

  bool get isDarkMode => _isDarkMode;
  GameThemeMode get currentMode => _currentMode;
  GameTheme get currentTheme => _currentTheme;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() {
    _isDarkMode = GameStorage.getDarkMode();
    final themeIndex = GameStorage.getThemeIndex();
    _currentMode = GameThemeMode.values[themeIndex % GameThemeMode.values.length];
    _currentTheme = GameTheme.getTheme(_currentMode, isDark: _isDarkMode);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    await setDarkMode(!_isDarkMode);
  }

  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode == isDark) return;
    _isDarkMode = isDark;
    _currentTheme = GameTheme.getTheme(_currentMode, isDark: _isDarkMode);
    await GameStorage.setDarkMode(isDark);
    notifyListeners();
  }

  Future<void> setTheme(GameThemeMode mode) async {
    _currentMode = mode;
    _currentTheme = GameTheme.getTheme(_currentMode, isDark: _isDarkMode);
    await GameStorage.setThemeIndex(mode.index);
    notifyListeners();
  }
}
