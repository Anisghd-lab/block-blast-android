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

/// Paliers d'étoiles pour la fin de niveau
class StarThresholds {
  final String oneStar;
  final int? twoStarsMovesLeft;
  final int threeStarsScore;

  const StarThresholds({
    this.oneStar = 'goal_completed',
    this.twoStarsMovesLeft,
    required this.threeStarsScore,
  });

  factory StarThresholds.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const StarThresholds(threeStarsScore: 1000);
    }
    return StarThresholds(
      oneStar: json['one_star']?.toString() ?? 'goal_completed',
      twoStarsMovesLeft: json['two_stars_moves_left'] as int?,
      threeStarsScore: json['three_stars_score'] as int? ?? 1000,
    );
  }

  Map<String, dynamic> toJson() => {
        'one_star': oneStar,
        'two_stars_moves_left': twoStarsMovesLeft,
        'three_stars_score': threeStarsScore,
      };
}

/// Présentation de fin de niveau (Bannière de bravoure, animation et thème de particules)
class EndLevelPresentation {
  final String victoryBanner;
  final String finisherAnim; // missile_shower | gem_explosion | grid_rainbow_sweep
  final String particleTheme; // neon | gold | crystal | fireworks

  const EndLevelPresentation({
    required this.victoryBanner,
    required this.finisherAnim,
    required this.particleTheme,
  });

  factory EndLevelPresentation.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const EndLevelPresentation(
        victoryBanner: 'VICTOIRE !',
        finisherAnim: 'grid_rainbow_sweep',
        particleTheme: 'neon',
      );
    }
    return EndLevelPresentation(
      victoryBanner: json['victory_banner']?.toString() ?? 'VICTOIRE !',
      finisherAnim: json['finisher_anim']?.toString() ?? 'grid_rainbow_sweep',
      particleTheme: json['particle_theme']?.toString() ?? 'neon',
    );
  }

  Map<String, dynamic> toJson() => {
        'victory_banner': victoryBanner,
        'finisher_anim': finisherAnim,
        'particle_theme': particleTheme,
      };
}

/// Modèle d'un niveau du jeu (compatible avec le format JSON BlockPuzzle8x8 enrichi)
class GameLevel {
  final int levelId;
  final String title;
  final String world;
  final LevelGoal goal;
  final int targetValue;
  final int? moveLimit;
  final List<List<int>> initialGrid;
  final List<String> allowedShapes;
  final StarThresholds starThresholds;
  final EndLevelPresentation endLevelPresentation;

  const GameLevel({
    required this.levelId,
    required this.title,
    this.world = 'Initiation',
    required this.goal,
    required this.targetValue,
    this.moveLimit,
    required this.initialGrid,
    this.allowedShapes = const [],
    required this.starThresholds,
    required this.endLevelPresentation,
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
      world: json['world'] as String? ?? 'Initiation',
      goal: LevelGoal.fromString(json['goal'] as String),
      targetValue: json['target_value'] as int,
      moveLimit: json['move_limit'] as int?,
      initialGrid: parsedGrid,
      allowedShapes: parsedShapes,
      starThresholds: StarThresholds.fromJson(json['star_thresholds'] as Map<String, dynamic>?),
      endLevelPresentation: EndLevelPresentation.fromJson(json['end_level_presentation'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level_id': levelId,
      'title': title,
      'world': world,
      'goal': goal.name,
      'target_value': targetValue,
      'move_limit': moveLimit,
      'initial_grid': initialGrid,
      'allowed_shapes': allowedShapes,
      'star_thresholds': starThresholds.toJson(),
      'end_level_presentation': endLevelPresentation.toJson(),
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
