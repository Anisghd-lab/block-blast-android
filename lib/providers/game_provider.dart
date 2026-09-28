import 'package:flutter/material.dart';
import '../core/audio/audio_service.dart';
import '../core/haptics/haptic_service.dart';
import '../core/storage/game_storage.dart';
import '../engine/block_shape.dart';
import '../engine/board_state.dart';
import '../engine/level_manager.dart';
import '../engine/level_model.dart';
import '../engine/score_calculator.dart';
import '../engine/shape_generator.dart';

enum GameMode {
  classic,
  adventure,
}

/// Boosters tactiques sélectionnables (Style Sugar Delight)
enum ActiveBooster {
  none,
  hammer,
  bomb,
}

/// Événement de destruction de lignes/colonnes pour déclencher les effets Juice & Particules
class ClearEvent {
  final List<int> rows;
  final List<int> cols;
  final int totalLines;
  final int comboStreak;
  final int points;
  final int jewelsCleared;
  final int rocksCleared;
  final int timestamp;

  ClearEvent({
    required this.rows,
    required this.cols,
    required this.totalLines,
    required this.comboStreak,
    required this.points,
    required this.jewelsCleared,
    required this.rocksCleared,
  }) : timestamp = DateTime.now().microsecondsSinceEpoch;
}

class GameProvider extends ChangeNotifier {
  final ShapeGenerator _generator = ShapeGenerator();
  final LevelManager _levelManager = LevelManager();

  GameMode _gameMode = GameMode.adventure;
  late BoardState _board;
  List<BlockShape?> _availablePieces = [null, null, null];

  // Mode Classique
  int _score = 0;
  int _highScore = 0;
  int _comboStreak = 0;
  int _lastPointsAwarded = 0;
  bool _isGameOver = false;
  bool _isPaused = false;

  // Mode Aventure (50 Niveaux)
  GameLevel? _currentLevel;
  int _currentLevelId = 1;
  int _levelScore = 0;
  int _levelLinesCleared = 0;
  int _levelJewelsCollected = 0;
  int? _movesRemaining;
  bool _isLevelWon = false;
  bool _isLevelFailed = false;
  String _defeatReason = '';
  int _starsEarned = 0;

  // Boosters & Outils Tactiques (Sugar Delight System)
  ActiveBooster _activeBooster = ActiveBooster.none;
  int _hammerCount = 3;
  int _bombCount = 3;
  int _gloveCount = 3;
  int _extraMovesCount = 3;

  // Animation des explosions de lignes en cours
  List<int> _clearingRows = [];
  List<int> _clearingCols = [];
  ClearEvent? _lastClearEvent;

  // Aperçu de placement en direct pendant le glissement (Drag & Drop)
  BlockShape? _previewShape;
  int? _previewRow;
  int? _previewCol;
  bool _isPreviewValid = false;

  // Getters
  GameMode get gameMode => _gameMode;
  BoardState get board => _board;
  List<BlockShape?> get availablePieces => _availablePieces;
  int get score => _gameMode == GameMode.adventure ? _levelScore : _score;
  int get highScore => _highScore;
  int get comboStreak => _comboStreak;
  int get lastPointsAwarded => _lastPointsAwarded;
  bool get isGameOver => _gameMode == GameMode.adventure ? (_isLevelWon || _isLevelFailed) : _isGameOver;
  bool get isPaused => _isPaused;
  List<int> get clearingRows => _clearingRows;
  List<int> get clearingCols => _clearingCols;
  ClearEvent? get lastClearEvent => _lastClearEvent;

  // Getters Boosters
  ActiveBooster get activeBooster => _activeBooster;
  int get hammerCount => _hammerCount;
  int get bombCount => _bombCount;
  int get gloveCount => _gloveCount;
  int get extraMovesCount => _extraMovesCount;

  // Getters Aventure
  GameLevel? get currentLevel => _currentLevel;
  int get currentLevelId => _currentLevelId;
  int get levelLinesCleared => _levelLinesCleared;
  int get levelJewelsCollected => _levelJewelsCollected;
  int? get movesRemaining => _movesRemaining;
  bool get isLevelWon => _isLevelWon;
  bool get isLevelFailed => _isLevelFailed;
  String get defeatReason => _defeatReason;
  int get starsEarned => _starsEarned;

  BlockShape? get previewShape => _previewShape;
  int? get previewRow => _previewRow;
  int? get previewCol => _previewCol;
  bool get isPreviewValid => _isPreviewValid;

  GameProvider() {
    _board = BoardState();
    _highScore = GameStorage.getHighScore();
    _hammerCount = GameStorage.getHammerCount();
    _bombCount = GameStorage.getBombCount();
    _gloveCount = GameStorage.getGloveCount();
    _extraMovesCount = GameStorage.getExtraMovesCount();
    _initLevelsAndStart();
  }

  Future<void> _initLevelsAndStart() async {
    await _levelManager.init();
    final savedState = GameStorage.getSavedGameState();
    if (savedState != null) {
      final success = _restoreGameState(savedState);
      if (success) return;
    }

    if (_levelManager.levels.isNotEmpty) {
      final unlocked = _levelManager.progress.unlockedLevel.clamp(1, 50);
      loadLevel(unlocked);
    } else {
      _initializeClassicGame();
    }
  }

  bool _restoreGameState(Map<String, dynamic> state) {
    try {
      final modeStr = state['gameMode'] as String?;
      _gameMode = modeStr == 'classic' ? GameMode.classic : GameMode.adventure;
      _currentLevelId = (state['currentLevelId'] as num?)?.toInt() ?? 1;
      _currentLevel = _levelManager.getLevel(_currentLevelId);

      final rawGrid = state['grid'] as List?;
      if (rawGrid != null && rawGrid.length == BoardState.size) {
        final parsedGrid = rawGrid
            .map((r) => (r as List).map((c) => (c as num).toInt()).toList())
            .toList();
        _board = BoardState.fromGrid(parsedGrid);
      } else {
        return false;
      }

      final rawPieces = state['availablePieces'] as List?;
      if (rawPieces != null && rawPieces.length == 3) {
        _availablePieces = rawPieces.map((p) {
          if (p == null) return null;
          return BlockShape.fromJson(Map<String, dynamic>.from(p as Map));
        }).toList();
      } else {
        _availablePieces = [null, null, null];
      }

      _score = (state['score'] as num?)?.toInt() ?? 0;
      _levelScore = (state['levelScore'] as num?)?.toInt() ?? 0;
      _levelLinesCleared = (state['levelLinesCleared'] as num?)?.toInt() ?? 0;
      _levelJewelsCollected = (state['levelJewelsCollected'] as num?)?.toInt() ?? 0;
      _movesRemaining = (state['movesRemaining'] as num?)?.toInt();
      _comboStreak = (state['comboStreak'] as num?)?.toInt() ?? 0;
      _isLevelWon = false;
      _isLevelFailed = false;
      _isGameOver = false;
      _isPaused = false;

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> saveCurrentState() async {
    if (_isGameOver || _isLevelWon || _isLevelFailed) return;
    try {
      final state = {
        'gameMode': _gameMode == GameMode.adventure ? 'adventure' : 'classic',
        'currentLevelId': _currentLevelId,
        'grid': _board.grid,
        'availablePieces': _availablePieces.map((p) => p?.toJson()).toList(),
        'score': _score,
        'levelScore': _levelScore,
        'levelLinesCleared': _levelLinesCleared,
        'levelJewelsCollected': _levelJewelsCollected,
        'movesRemaining': _movesRemaining,
        'comboStreak': _comboStreak,
      };
      await GameStorage.saveGameState(state);
    } catch (_) {}
  }

  void switchMode(GameMode mode) {
    if (_gameMode == mode) return;
    _gameMode = mode;
    GameStorage.clearSavedGameState();
    if (_gameMode == GameMode.adventure) {
      final unlocked = _levelManager.progress.unlockedLevel.clamp(1, 50);
      loadLevel(unlocked);
    } else {
      _initializeClassicGame();
    }
    notifyListeners();
  }

  /// Charge et initialise un niveau spécifique (1 à 50)
  void loadLevel(int levelId) {
    _currentLevelId = levelId;
    _currentLevel = _levelManager.getLevel(levelId);

    if (_currentLevel != null) {
      _board = BoardState.fromGrid(_currentLevel!.cloneGrid());
      _movesRemaining = _currentLevel!.moveLimit;
    } else {
      _board = BoardState();
      _movesRemaining = null;
    }

    _levelScore = 0;
    _levelLinesCleared = 0;
    _levelJewelsCollected = 0;
    _comboStreak = 0;
    _isLevelWon = false;
    _isLevelFailed = false;
    _defeatReason = '';
    _starsEarned = 0;
    _isPaused = false;
    _activeBooster = ActiveBooster.none;

    _spawnNewTrio();
    saveCurrentState();
    notifyListeners();
  }

  void restartCurrentLevel() {
    GameStorage.clearSavedGameState();
    loadLevel(_currentLevelId);
  }

  void nextLevel() {
    GameStorage.clearSavedGameState();
    if (_currentLevelId < 50) {
      loadLevel(_currentLevelId + 1);
    } else {
      loadLevel(1);
    }
  }

  void _initializeClassicGame() {
    _score = 0;
    _comboStreak = 0;
    _isGameOver = false;
    _isPaused = false;
    _activeBooster = ActiveBooster.none;
    _board.reset();
    _spawnNewTrio();
    saveCurrentState();
    notifyListeners();
  }

  void startNewGame() {
    GameStorage.clearSavedGameState();
    if (_gameMode == GameMode.adventure) {
      restartCurrentLevel();
    } else {
      GameStorage.incrementGamesPlayed();
      _initializeClassicGame();
    }
  }

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  /// Fait pivoter une pièce du tiroir de 90 degrés dans le sens horaire
  void rotatePiece(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= _availablePieces.length) return;
    final piece = _availablePieces[slotIndex];
    if (piece == null) return;

    _availablePieces[slotIndex] = piece.rotate90();
    AudioService.playPiecePick();
    HapticService.onPieceRotate();
    saveCurrentState();
    notifyListeners();
  }

  /// Inverse une pièce horizontalement
  void mirrorPiece(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= _availablePieces.length) return;
    final piece = _availablePieces[slotIndex];
    if (piece == null) return;

    _availablePieces[slotIndex] = piece.mirror();
    AudioService.playPiecePick();
    HapticService.onPieceRotate();
    saveCurrentState();
    notifyListeners();
  }

  /// Met à jour l'aperçu du bloc en survol au-dessus de la grille (Ghost Shadow)
  void setDragPreview(BlockShape? shape, int? row, int? col) {
    if (shape == null || row == null || col == null) {
      if (_previewShape != null) {
        _previewShape = null;
        _previewRow = null;
        _previewCol = null;
        _isPreviewValid = false;
        notifyListeners();
      }
      return;
    }

    final isValid = _board.canPlace(shape, row, col);
    if (_previewShape != shape ||
        _previewRow != row ||
        _previewCol != col ||
        _isPreviewValid != isValid) {
      _previewShape = shape;
      _previewRow = row;
      _previewCol = col;
      _isPreviewValid = isValid;
      notifyListeners();
    }
  }

  /// Tente de poser la pièce à la coordonnée cible
  bool tryPlacePiece(int pieceIndex, int targetRow, int targetCol) {
    if (pieceIndex < 0 || pieceIndex >= _availablePieces.length) return false;
    final shape = _availablePieces[pieceIndex];
    if (shape == null) return false;

    // Réinitialiser l'aperçu
    _previewShape = null;
    _previewRow = null;
    _previewCol = null;
    _isPreviewValid = false;

    if (!_board.canPlace(shape, targetRow, targetCol)) {
      notifyListeners();
      return false;
    }

    // 1. Placement sur la grille
    _board.place(shape, targetRow, targetCol);
    _availablePieces[pieceIndex] = null;
    HapticService.onPieceDrop();
    AudioService.playPiecePlace();

    // Points de pose
    final placementPoints = ScoreCalculator.calculatePlacementPoints(shape);
    if (_gameMode == GameMode.adventure) {
      _levelScore += placementPoints;
      if (_movesRemaining != null) {
        _movesRemaining = _movesRemaining! - 1;
      }
    } else {
      _score += placementPoints;
    }

    // 2. Traitement des lignes complètes avec Gravité et Cascades automatiques
    final clearResult = _board.checkCompletedLines();
    if (clearResult.hasClear) {
      _processLineClear(clearResult);
    } else {
      _comboStreak = 0;
      _checkPostMoveState();
    }

    // Mise à jour du meilleur score classique
    if (_gameMode == GameMode.classic) {
      if (_score > _highScore) {
        _highScore = _score;
        GameStorage.saveHighScore(_highScore);
      }
      GameStorage.saveBestStreak(_comboStreak);
    }

    notifyListeners();
    return true;
  }

  /// Traitement modulaire d'une destruction de lignes/colonnes :
  /// 1. Explosion & Particules
  /// 2. Effacement des lignes
  /// 3. Gravité / Chute des blocs suspendus (Step Down)
  /// 4. Détection récursive des Combos en cascade
  void _processLineClear(LineClearResult clearResult) {
    _comboStreak++;
    final clearPoints = ScoreCalculator.calculateClearPoints(
      clearResult.totalLines,
      _comboStreak,
    );
    _lastPointsAwarded = clearPoints;

    if (_gameMode == GameMode.adventure) {
      _levelScore += clearPoints +
          (clearResult.jewelsCleared * 50) +
          (clearResult.rocksCleared * 30);
      _levelLinesCleared += clearResult.totalLines;
      _levelJewelsCollected += clearResult.jewelsCleared;
    } else {
      _score += clearPoints;
    }

    // Effets sonores et haptiques dynamiques
    AudioService.playLineClear(_comboStreak);
    HapticService.onLineClear(lineCount: clearResult.totalLines);
    if (_comboStreak >= 2) {
      AudioService.playComboBlast();
      HapticService.onComboBlast();
    }

    // Déclenchement de l'animation d'explosion & Événement Juice
    _clearingRows = List.from(clearResult.rows);
    _clearingCols = List.from(clearResult.cols);
    _lastClearEvent = ClearEvent(
      rows: List.from(clearResult.rows),
      cols: List.from(clearResult.cols),
      totalLines: clearResult.totalLines,
      comboStreak: _comboStreak,
      points: clearPoints,
      jewelsCleared: clearResult.jewelsCleared,
      rocksCleared: clearResult.rocksCleared,
    );
    notifyListeners();

    // 1. Délai pour admirer l'explosion et les éclats de particules (220ms)
    Future.delayed(const Duration(milliseconds: 220), () {
      GameStorage.addLinesCleared(_clearingRows.length + _clearingCols.length);
      _board.clearLines(_clearingRows, _clearingCols);
      _clearingRows = [];
      _clearingCols = [];

      // 2. Physique de chute / Gravité descendante (Step Down)
      final hasFallen = _board.applyGravity();
      notifyListeners();

      // 3. Après stabilisation de la chute, re-scan pour cascade combo
      Future.delayed(Duration(milliseconds: hasFallen ? 160 : 60), () {
        final cascadeResult = _board.checkCompletedLines();
        if (cascadeResult.hasClear) {
          // Combo en cascade : nouvelle vague de destruction !
          _processLineClear(cascadeResult);
        } else {
          // Grille stabilisée : validation des objectifs et fin de tour
          _checkPostMoveState();
          saveCurrentState();
          notifyListeners();
        }
      });
    });
  }

  /// Nettoie les statuts de fin de niveau pour éviter les glitchs lors de la navigation
  void clearLevelStatus() {
    _isLevelWon = false;
    _isLevelFailed = false;
    _defeatReason = '';
    _clearingRows = [];
    _clearingCols = [];
    _lastClearEvent = null;
    notifyListeners();
  }

  void _checkPostMoveState() {
    if (_gameMode == GameMode.adventure && _currentLevel != null) {
      // 1. Vérification de la victoire de niveau
      bool victory = false;
      final lvl = _currentLevel!;
      if (lvl.goal == LevelGoal.clearJewels && _levelJewelsCollected >= lvl.targetValue) {
        victory = true;
      } else if (lvl.goal == LevelGoal.clearLines && _levelLinesCleared >= lvl.targetValue) {
        victory = true;
      } else if (lvl.goal == LevelGoal.score && _levelScore >= lvl.targetValue) {
        victory = true;
      }

      if (victory) {
        _isLevelWon = true;
        GameStorage.clearSavedGameState();
        // Calcul des étoiles selon star_thresholds
        int stars = 1;
        final thresholds = lvl.starThresholds;

        if (thresholds.twoStarsMovesLeft != null) {
          if ((_movesRemaining ?? 0) >= thresholds.twoStarsMovesLeft!) {
            stars++;
          }
        } else {
          stars++;
        }

        if (_levelScore >= thresholds.threeStarsScore) {
          stars++;
        }
        _starsEarned = stars;

        _levelManager.recordCompletion(lvl.levelId, _starsEarned, _levelScore);
        AudioService.playLevelVictory();
        HapticService.onLevelVictory();
        notifyListeners();
        return;
      }

      // 2. Vérification de la limite de coups
      if (_movesRemaining != null && _movesRemaining! <= 0) {
        _isLevelFailed = true;
        _defeatReason = "Limite de coups atteinte !";
        GameStorage.clearSavedGameState();
        AudioService.playGameOver();
        HapticService.onGameOver();
        notifyListeners();
        return;
      }
    }

    // Si toutes les pièces du tiroir ont été jouées, faire réapparaître un nouveau trio
    if (_availablePieces.every((p) => p == null)) {
      _spawnNewTrio();
    }

    // Vérifier si au moins un coup reste possible
    if (!_board.hasAnyValidMove(_availablePieces)) {
      if (_gameMode == GameMode.adventure) {
        _isLevelFailed = true;
        _defeatReason = "Aucun placement possible sur la grille !";
        GameStorage.clearSavedGameState();
      } else {
        _isGameOver = true;
        GameStorage.clearSavedGameState();
      }
      AudioService.playGameOver();
      HapticService.onGameOver();
    } else {
      saveCurrentState();
    }

    notifyListeners();
  }

  void _spawnNewTrio() {
    final allowed = (_gameMode == GameMode.adventure && _currentLevel != null)
        ? _currentLevel!.allowedShapes
        : null;

    final trio = _generator.generateTrio(_board, allowedShapes: allowed);
    _availablePieces = [trio[0], trio[1], trio[2]];
  }

  // --- ACTIONS DES BOOSTERS TACTIQUES (SUGAR DELIGHT SYSTEM) ---

  /// Active ou désactive un booster ciblé (Marteau ou Bombe)
  void selectBooster(ActiveBooster booster) {
    if (_activeBooster == booster) {
      _activeBooster = ActiveBooster.none;
    } else {
      _activeBooster = booster;
    }
    notifyListeners();
  }

  /// Annule le ciblage du booster en cours
  void cancelActiveBooster() {
    if (_activeBooster != ActiveBooster.none) {
      _activeBooster = ActiveBooster.none;
      notifyListeners();
    }
  }

  /// Actualise le stock de boosters depuis le stockage persistant
  void refreshBoosterCounts() {
    _hammerCount = GameStorage.getHammerCount();
    _bombCount = GameStorage.getBombCount();
    _gloveCount = GameStorage.getGloveCount();
    _extraMovesCount = GameStorage.getExtraMovesCount();
    notifyListeners();
  }

  /// Applique le Marteau Sucré sur la cellule (r, c)
  Future<bool> applyHammer(int r, int c) async {
    if (_hammerCount <= 0) return false;
    final oldVal = _board.clearSingleCell(r, c);

    await GameStorage.useBooster('hammer');
    _hammerCount = GameStorage.getHammerCount();
    _activeBooster = ActiveBooster.none;

    AudioService.playHammerSmash();
    HapticService.onHammerSmash();

    if (oldVal == 2) {
      _levelJewelsCollected++;
    }
    if (_gameMode == GameMode.adventure) {
      _levelScore += 50;
    } else {
      _score += 50;
    }

    _checkPostMoveState();
    saveCurrentState();
    notifyListeners();
    return true;
  }

  /// Applique la Bombe Soda sur une zone 3x3 centrée en (centerR, centerC)
  Future<bool> applyBomb(int centerR, int centerC) async {
    if (_bombCount <= 0) return false;
    final cleared = _board.clear3x3Area(centerR, centerC);

    await GameStorage.useBooster('bomb');
    _bombCount = GameStorage.getBombCount();
    _activeBooster = ActiveBooster.none;

    AudioService.playBombExplosion();
    HapticService.onBombExplosion();

    int jewels = 0;
    for (final item in cleared) {
      if (item.$3 == 2) jewels++;
    }
    _levelJewelsCollected += jewels;
    final pts = (cleared.length * 35) + (jewels * 50);
    if (_gameMode == GameMode.adventure) {
      _levelScore += pts;
    } else {
      _score += pts;
    }

    _checkPostMoveState();
    saveCurrentState();
    notifyListeners();
    return true;
  }

  /// Utilise le Gant Magique pour régénérer immédiatement le tiroir de 3 pièces
  Future<bool> useGloveReroll() async {
    if (_gloveCount <= 0) return false;
    await GameStorage.useBooster('glove');
    _gloveCount = GameStorage.getGloveCount();
    _spawnNewTrio();

    AudioService.playPiecePick();
    HapticService.onPiecePick();

    _checkPostMoveState();
    saveCurrentState();
    notifyListeners();
    return true;
  }

  /// Utilise le Booster +5 Coups pour continuer le niveau
  Future<bool> useExtraMoves([int extra = 5]) async {
    if (_extraMovesCount <= 0) return false;
    await GameStorage.useBooster('extra_moves');
    _extraMovesCount = GameStorage.getExtraMovesCount();
    _movesRemaining = (_movesRemaining ?? 0) + extra;
    _isLevelFailed = false;
    _defeatReason = '';

    AudioService.playCoinReward();
    HapticService.onPieceDrop();

    saveCurrentState();
    notifyListeners();
    return true;
  }

  /// Achète 1 unité d'un booster avec les pièces du joueur
  Future<bool> buyBooster(String boosterType, int costInCoins) async {
    final success = await GameStorage.spendCoins(costInCoins);
    if (success) {
      await GameStorage.addBooster(boosterType, 1);
      refreshBoosterCounts();
      AudioService.playCoinReward();
      return true;
    }
    return false;
  }
}
