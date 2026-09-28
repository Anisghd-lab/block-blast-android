import 'package:flutter/material.dart';
import '../core/audio/audio_service.dart';
import '../core/haptics/haptic_service.dart';
import '../core/storage/game_storage.dart';
import '../core/theme/game_theme.dart';

class SettingsProvider extends ChangeNotifier {
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  bool _isDarkMode = true;
  GameThemeMode _currentThemeMode = GameThemeMode.neonArcade;
  late GameTheme _currentTheme;

  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get isDarkMode => _isDarkMode;
  GameThemeMode get currentThemeMode => _currentThemeMode;
  GameTheme get currentTheme => _currentTheme;

  SettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() {
    _soundEnabled = GameStorage.getSoundEnabled();
    _hapticsEnabled = GameStorage.getHapticsEnabled();
    _isDarkMode = GameStorage.getDarkMode();
    final themeIndex = GameStorage.getThemeIndex();
    _currentThemeMode = GameThemeMode.values[themeIndex % GameThemeMode.values.length];
    _currentTheme = GameTheme.getTheme(_currentThemeMode, isDark: _isDarkMode);

    AudioService.isEnabled = _soundEnabled;
    HapticService.isEnabled = _hapticsEnabled;
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    AudioService.isEnabled = _soundEnabled;
    await GameStorage.setSoundEnabled(_soundEnabled);
    notifyListeners();
  }

  Future<void> toggleHaptics() async {
    _hapticsEnabled = !_hapticsEnabled;
    HapticService.isEnabled = _hapticsEnabled;
    await GameStorage.setHapticsEnabled(_hapticsEnabled);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    await setDarkMode(!_isDarkMode);
  }

  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode == isDark) return;
    _isDarkMode = isDark;
    _currentTheme = GameTheme.getTheme(_currentThemeMode, isDark: _isDarkMode);
    await GameStorage.setDarkMode(isDark);
    notifyListeners();
  }

  Future<void> setTheme(GameThemeMode mode) async {
    _currentThemeMode = mode;
    _currentTheme = GameTheme.getTheme(_currentThemeMode, isDark: _isDarkMode);
    await GameStorage.setThemeIndex(mode.index);
    notifyListeners();
  }
}
