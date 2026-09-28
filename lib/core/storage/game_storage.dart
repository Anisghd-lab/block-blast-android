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
  static const String _keyDarkMode = 'block_blast_dark_mode';
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

  static bool getDarkMode() {
    return _prefs?.getBool(_keyDarkMode) ?? true;
  }

  static Future<void> setDarkMode(bool isDark) async {
    await _prefs?.setBool(_keyDarkMode, isDark);
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

  // --- ÉCONOMIE DU JEU : PIÈCES & VIES (SUGAR DELIGHT SYSTEM) ---
  static const String _keyCoins = 'candy_coins_balance';
  static const String _keyLives = 'candy_lives_count';
  static const String _keyLastLifeTime = 'candy_last_life_timestamp';
  static const int maxLives = 5;
  static const int lifeRegenSeconds = 900; // 15 minutes par vie

  static int getCoins() {
    return _prefs?.getInt(_keyCoins) ?? 150;
  }

  static Future<void> addCoins(int amount) async {
    final current = getCoins();
    await _prefs?.setInt(_keyCoins, current + amount);
  }

  static Future<bool> spendCoins(int amount) async {
    final current = getCoins();
    if (current >= amount) {
      await _prefs?.setInt(_keyCoins, current - amount);
      return true;
    }
    return false;
  }

  static int getLives() {
    _checkLifeRegeneration();
    return _prefs?.getInt(_keyLives) ?? maxLives;
  }

  static int getSecondsUntilNextLife() {
    final currentLives = _prefs?.getInt(_keyLives) ?? maxLives;
    if (currentLives >= maxLives) return 0;
    final lastTime = _prefs?.getInt(_keyLastLifeTime) ?? DateTime.now().millisecondsSinceEpoch;
    final elapsedSec = ((DateTime.now().millisecondsSinceEpoch - lastTime) / 1000).floor();
    final remaining = lifeRegenSeconds - (elapsedSec % lifeRegenSeconds);
    return remaining.clamp(0, lifeRegenSeconds);
  }

  static void _checkLifeRegeneration() {
    int current = _prefs?.getInt(_keyLives) ?? maxLives;
    if (current >= maxLives) return;

    final lastTime = _prefs?.getInt(_keyLastLifeTime) ?? DateTime.now().millisecondsSinceEpoch;
    final elapsedSec = ((DateTime.now().millisecondsSinceEpoch - lastTime) / 1000).floor();
    final livesGained = elapsedSec ~/ lifeRegenSeconds;

    if (livesGained > 0) {
      final updated = (current + livesGained).clamp(0, maxLives);
      _prefs?.setInt(_keyLives, updated);
      if (updated >= maxLives) {
        _prefs?.remove(_keyLastLifeTime);
      } else {
        final newLastTime = lastTime + (livesGained * lifeRegenSeconds * 1000);
        _prefs?.setInt(_keyLastLifeTime, newLastTime);
      }
    }
  }

  static Future<void> refillLives() async {
    await _prefs?.setInt(_keyLives, maxLives);
    await _prefs?.remove(_keyLastLifeTime);
  }

  static Future<bool> consumeLife() async {
    _checkLifeRegeneration();
    int current = _prefs?.getInt(_keyLives) ?? maxLives;
    if (current > 0) {
      if (current == maxLives) {
        await _prefs?.setInt(_keyLastLifeTime, DateTime.now().millisecondsSinceEpoch);
      }
      await _prefs?.setInt(_keyLives, current - 1);
      return true;
    }
    return false;
  }

  // --- BOOSTERS & OUTILS TACTIQUES (SUGAR DELIGHT BOOSTERS) ---
  static const String _keyHammer = 'booster_hammer_count';
  static const String _keyBomb = 'booster_bomb_count';
  static const String _keyGlove = 'booster_glove_count';
  static const String _keyExtraMoves = 'booster_extra_moves_count';

  static int getHammerCount() => _prefs?.getInt(_keyHammer) ?? 3;
  static int getBombCount() => _prefs?.getInt(_keyBomb) ?? 3;
  static int getGloveCount() => _prefs?.getInt(_keyGlove) ?? 3;
  static int getExtraMovesCount() => _prefs?.getInt(_keyExtraMoves) ?? 3;

  static Future<void> addBooster(String boosterType, [int count = 1]) async {
    final key = _getBoosterKey(boosterType);
    final current = _prefs?.getInt(key) ?? 3;
    await _prefs?.setInt(key, current + count);
  }

  static Future<bool> useBooster(String boosterType) async {
    final key = _getBoosterKey(boosterType);
    final current = _prefs?.getInt(key) ?? 3;
    if (current > 0) {
      await _prefs?.setInt(key, current - 1);
      return true;
    }
    return false;
  }

  static String _getBoosterKey(String boosterType) {
    switch (boosterType) {
      case 'hammer':
        return _keyHammer;
      case 'bomb':
        return _keyBomb;
      case 'glove':
        return _keyGlove;
      case 'extra_moves':
      default:
        return _keyExtraMoves;
    }
  }
}
