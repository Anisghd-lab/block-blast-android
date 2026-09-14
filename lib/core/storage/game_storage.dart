import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Stockage local 100% hors ligne respectant la vie privée et les règles Google Play
class GameStorage {
  static const String _keyHighScore = 'block_blast_high_score';
  static const String _keyBestStreak = 'block_blast_best_streak';
  static const String _keyGamesPlayed = 'block_blast_games_played';
  static const String _keyTotalLines = 'block_blast_total_lines';
  static const String _keySound = 'block_blast_sound_enabled';
  static const String _keyHaptics = 'block_blast_haptics_enabled';
  static const String _keyTheme = 'block_blast_theme_mode';
  static const String _keySavedGame = 'block_blast_saved_game_state';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static int getHighScore() {
    return _prefs?.getInt(_keyHighScore) ?? 0;
  }

  static Future<void> saveHighScore(int score) async {
    final currentHigh = getHighScore();
    if (score > currentHigh) {
      await _prefs?.setInt(_keyHighScore, score);
    }
  }

  static int getBestStreak() {
    return _prefs?.getInt(_keyBestStreak) ?? 0;
  }

  static Future<void> saveBestStreak(int streak) async {
    final currentBest = getBestStreak();
    if (streak > currentBest) {
      await _prefs?.setInt(_keyBestStreak, streak);
    }
  }

  static int getGamesPlayed() {
    return _prefs?.getInt(_keyGamesPlayed) ?? 0;
  }

  static Future<void> incrementGamesPlayed() async {
    final count = getGamesPlayed() + 1;
    await _prefs?.setInt(_keyGamesPlayed, count);
  }

  static int getTotalLines() {
    return _prefs?.getInt(_keyTotalLines) ?? 0;
  }

  static Future<void> addLinesCleared(int count) async {
    final total = getTotalLines() + count;
    await _prefs?.setInt(_keyTotalLines, total);
  }

  static bool getSoundEnabled() {
    return _prefs?.getBool(_keySound) ?? true;
  }

  static Future<void> setSoundEnabled(bool enabled) async {
    await _prefs?.setBool(_keySound, enabled);
  }

  static bool getHapticsEnabled() {
    return _prefs?.getBool(_keyHaptics) ?? true;
  }

  static Future<void> setHapticsEnabled(bool enabled) async {
    await _prefs?.setBool(_keyHaptics, enabled);
  }

  static int getThemeIndex() {
    return _prefs?.getInt(_keyTheme) ?? 0;
  }

  static Future<void> setThemeIndex(int index) async {
    await _prefs?.setInt(_keyTheme, index);
  }

  // Sauvegarde de l'état de la partie en cours pour reprise automatique
  static Future<void> saveGameState(Map<String, dynamic> state) async {
    await _prefs?.setString(_keySavedGame, jsonEncode(state));
  }

  static Map<String, dynamic>? getSavedGameState() {
    final raw = _prefs?.getString(_keySavedGame);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearSavedGameState() async {
    await _prefs?.remove(_keySavedGame);
  }

  // Persistance du niveau atteint et progression
  static const String _keyLevelUnlocked = 'level_unlocked';
  static const String _keyLevelStars = 'level_stars_map';

  static int getUnlockedLevel() {
    return _prefs?.getInt(_keyLevelUnlocked) ?? 1;
  }

  static Future<void> saveUnlockedLevel(int level) async {
    final current = getUnlockedLevel();
    if (level > current) {
      await _prefs?.setInt(_keyLevelUnlocked, level);
    }
  }

  static Map<int, int> getLevelStars() {
    final raw = _prefs?.getString(_keyLevelStars);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final Map<int, int> result = {};
      decoded.forEach((key, val) {
        final id = int.tryParse(key);
        if (id != null) result[id] = val as int;
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveLevelStars(Map<int, int> starsMap) async {
    final Map<String, int> exportMap = {};
    starsMap.forEach((k, v) => exportMap[k.toString()] = v);
    await _prefs?.setString(_keyLevelStars, jsonEncode(exportMap));
  }
}
