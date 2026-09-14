import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'level_model.dart';

class LevelManager {
  static final LevelManager _instance = LevelManager._internal();
  factory LevelManager() => _instance;
  LevelManager._internal();

  List<GameLevel> _levels = [];
  LevelProgress _progress = LevelProgress();
  bool _isInitialized = false;

  List<GameLevel> get levels => _levels;
  LevelProgress get progress => _progress;
  bool get isInitialized => _isInitialized;

  /// Charger les 50 niveaux depuis l'asset JSON et la progression locale
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final jsonString = await rootBundle.loadString('assets/levels/levels.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final rawList = data['levels'] as List<dynamic>;

      _levels = rawList.map((item) => GameLevel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback si chargement asynchrone spécifique
      _levels = [];
    }

    await _loadProgress();
    _isInitialized = true;
  }

  GameLevel? getLevel(int levelId) {
    try {
      return _levels.firstWhere((lvl) => lvl.levelId == levelId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final unlocked = prefs.getInt('level_unlocked') ?? 1;
      final rawProgressStr = prefs.getString('level_stars_map');

      final Map<int, int> starsMap = {};
      if (rawProgressStr != null) {
        final Map<String, dynamic> decoded = json.decode(rawProgressStr);
        decoded.forEach((key, value) {
          final id = int.tryParse(key);
          if (id != null) starsMap[id] = value as int;
        });
      }

      _progress = LevelProgress(
        unlockedLevel: unlocked,
        starsPerLevel: starsMap,
      );
    } catch (_) {
      _progress = LevelProgress();
    }
  }

  Future<void> recordCompletion(int levelId, int stars, int score) async {
    _progress.recordCompletion(levelId, stars, score);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('level_unlocked', _progress.unlockedLevel);

      final Map<String, int> exportMap = {};
      _progress.starsPerLevel.forEach((k, v) => exportMap[k.toString()] = v);
      await prefs.setString('level_stars_map', json.encode(exportMap));
    } catch (_) {}
  }
}
