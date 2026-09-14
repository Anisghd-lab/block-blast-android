import 'package:flutter/material.dart';
import '../core/audio/audio_service.dart';
import '../core/haptics/haptic_service.dart';
import '../core/storage/game_storage.dart';
import '../core/theme/game_theme.dart';

class SettingsProvider extends ChangeNotifier {
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  GameTheme _currentTheme = GameTheme.neon;

  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  GameTheme get currentTheme => _currentTheme;

  SettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() {
    _soundEnabled = GameStorage.getSoundEnabled();
    _hapticsEnabled = GameStorage.getHapticsEnabled();
    final themeIndex = GameStorage.getThemeIndex();
    _currentTheme = GameTheme.fromMode(GameThemeMode.values[themeIndex % GameThemeMode.values.length]);

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

  Future<void> setTheme(GameThemeMode mode) async {
    _currentTheme = GameTheme.fromMode(mode);
    await GameStorage.setThemeIndex(mode.index);
    notifyListeners();
  }
}
