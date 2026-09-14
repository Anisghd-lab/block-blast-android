/// Représentation d'un objectif de niveau
enum LevelGoal {
  score,
  clearLines,
  clearJewels;

  static LevelGoal fromString(String val) {
    switch (val) {
      case 'clear_lines':
        return LevelGoal.clearLines;
      case 'clear_jewels':
        return LevelGoal.clearJewels;
      case 'score':
      default:
        return LevelGoal.score;
    }
  }

  String get displayName {
    switch (this) {
      case LevelGoal.clearLines:
        return 'Lignes';
      case LevelGoal.clearJewels:
        return 'Gemmes';
      case LevelGoal.score:
        return 'Score';
    }
  }

  String get icon {
    switch (this) {
      case LevelGoal.clearLines:
        return '📏';
      case LevelGoal.clearJewels:
        return '💎';
      case LevelGoal.score:
        return '🎯';
    }
  }
}

/// Modèle d'un niveau du jeu (compatible avec le format JSON BlockPuzzle8x8)
class GameLevel {
  final int levelId;
  final String title;
  final LevelGoal goal;
  final int targetValue;
  final int? moveLimit;
  final List<List<int>> initialGrid;
  final List<String> allowedShapes;

  const GameLevel({
    required this.levelId,
    required this.title,
    required this.goal,
    required this.targetValue,
    this.moveLimit,
    required this.initialGrid,
    this.allowedShapes = const [],
  });

  factory GameLevel.fromJson(Map<String, dynamic> json) {
    final rawGrid = json['initial_grid'] as List<dynamic>;
    final parsedGrid = rawGrid.map((row) {
      return (row as List<dynamic>).map((cell) => cell as int).toList();
    }).toList();

    final rawShapes = json['allowed_shapes'] as List<dynamic>?;
    final parsedShapes = rawShapes != null
        ? rawShapes.map((s) => s.toString()).toList()
        : <String>[];

    return GameLevel(
      levelId: json['level_id'] as int,
      title: json['title'] as String,
      goal: LevelGoal.fromString(json['goal'] as String),
      targetValue: json['target_value'] as int,
      moveLimit: json['move_limit'] as int?,
      initialGrid: parsedGrid,
      allowedShapes: parsedShapes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level_id': levelId,
      'title': title,
      'goal': goal.name,
      'target_value': targetValue,
      'move_limit': moveLimit,
      'initial_grid': initialGrid,
      'allowed_shapes': allowedShapes,
    };
  }

  /// Cloner la grille de départ pour une nouvelle partie
  List<List<int>> cloneGrid() {
    return initialGrid.map((row) => List<int>.from(row)).toList();
  }
}

/// Modèle de progression du joueur à travers les 50 niveaux
class LevelProgress {
  int unlockedLevel;
  final Map<int, int> starsPerLevel;
  final Map<int, int> bestScorePerLevel;

  LevelProgress({
    this.unlockedLevel = 1,
    Map<int, int>? starsPerLevel,
    Map<int, int>? bestScorePerLevel,
  })  : starsPerLevel = starsPerLevel ?? {},
        bestScorePerLevel = bestScorePerLevel ?? {};

  int getStars(int levelId) => starsPerLevel[levelId] ?? 0;
  int getBestScore(int levelId) => bestScorePerLevel[levelId] ?? 0;
  bool isUnlocked(int levelId) => levelId <= unlockedLevel;

  void recordCompletion(int levelId, int stars, int score) {
    if (stars > getStars(levelId)) {
      starsPerLevel[levelId] = stars;
    }
    if (score > getBestScore(levelId)) {
      bestScorePerLevel[levelId] = score;
    }
    // Débloque le niveau suivant
    if (levelId >= unlockedLevel && unlockedLevel < 50) {
      unlockedLevel = levelId + 1;
    }
  }
}
