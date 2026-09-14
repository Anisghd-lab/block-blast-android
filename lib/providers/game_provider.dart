import 'package:flutter/material.dart';
import '../core/audio/audio_service.dart';
import '../core/haptics/haptic_service.dart';
import '../core/storage/game_storage.dart';
import '../engine/block_shape.dart';
import '../engine/board_state.dart';
import '../engine/score_calculator.dart';
import '../engine/shape_generator.dart';

class GameProvider extends ChangeNotifier {
  final ShapeGenerator _generator = ShapeGenerator();

  late BoardState _board;
  List<BlockShape?> _availablePieces = [null, null, null];

  int _score = 0;
  int _highScore = 0;
  int _comboStreak = 0;
  int _lastPointsAwarded = 0;
  bool _isGameOver = false;
  bool _isPaused = false;

  // Animation des explosions de lignes en cours
  List<int> _clearingRows = [];
  List<int> _clearingCols = [];

  // Aperçu de placement en direct pendant le glissement (Drag & Drop)
  BlockShape? _previewShape;
  int? _previewRow;
  int? _previewCol;
  bool _isPreviewValid = false;

  // Getters
  BoardState get board => _board;
  List<BlockShape?> get availablePieces => _availablePieces;
  int get score => _score;
  int get highScore => _highScore;
  int get comboStreak => _comboStreak;
  int get lastPointsAwarded => _lastPointsAwarded;
  bool get isGameOver => _isGameOver;
  bool get isPaused => _isPaused;
  List<int> get clearingRows => _clearingRows;
  List<int> get clearingCols => _clearingCols;

  BlockShape? get previewShape => _previewShape;
  int? get previewRow => _previewRow;
  int? get previewCol => _previewCol;
  bool get isPreviewValid => _isPreviewValid;

  GameProvider() {
    _board = BoardState();
    _highScore = GameStorage.getHighScore();
    _initializeGame();
  }

  void _initializeGame() {
    _score = 0;
    _comboStreak = 0;
    _isGameOver = false;
    _isPaused = false;
    _board.reset();
    _spawnNewTrio();
    notifyListeners();
  }

  void startNewGame() {
    GameStorage.incrementGamesPlayed();
    _initializeGame();
  }

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  /// Fait pivoter une pièce du tiroir de 90 degrés
  void rotatePiece(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= _availablePieces.length) return;
    final piece = _availablePieces[slotIndex];
    if (piece == null) return;

    _availablePieces[slotIndex] = piece.rotate90();
    AudioService.playPiecePlace();
    HapticService.onPiecePick();
    _saveCurrentProgress();
    notifyListeners();
  }

  /// Inverse une pièce horizontalement (effet miroir gauche <-> droite)
  void mirrorPiece(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= _availablePieces.length) return;
    final piece = _availablePieces[slotIndex];
    if (piece == null) return;

    _availablePieces[slotIndex] = piece.mirror();
    AudioService.playPiecePlace();
    HapticService.onPiecePick();
    _saveCurrentProgress();
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
    _score += placementPoints;

    // 2. Vérification des lignes et colonnes pleines
    final clearResult = _board.checkCompletedLines();
    if (clearResult.hasClear) {
      _comboStreak++;
      final clearPoints = ScoreCalculator.calculateClearPoints(
        clearResult.totalLines,
        _comboStreak,
      );
      _lastPointsAwarded = clearPoints;
      _score += clearPoints;

      // Sons et haptiques
      AudioService.playLineClear(_comboStreak);
      HapticService.onLineClear(lineCount: clearResult.totalLines);
      if (_comboStreak >= 2) {
        HapticService.onComboBlast();
      }

      // Déclenchement de l'animation d'explosion
      _clearingRows = List.from(clearResult.rows);
      _clearingCols = List.from(clearResult.cols);
      notifyListeners();

      // Nettoyage effectif après le flash d'animation
      Future.delayed(const Duration(milliseconds: 180), () {
        _board.clearLines(_clearingRows, _clearingCols);
        GameStorage.addLinesCleared(_clearingRows.length + _clearingCols.length);
        _clearingRows = [];
        _clearingCols = [];
        _checkPostMoveState();
      });
    } else {
      _comboStreak = 0;
      _checkPostMoveState();
    }

    // Mise à jour du meilleur score
    if (_score > _highScore) {
      _highScore = _score;
      GameStorage.saveHighScore(_highScore);
    }
    GameStorage.saveBestStreak(_comboStreak);

    notifyListeners();
    return true;
  }

  void _checkPostMoveState() {
    // Si toutes les pièces du tiroir ont été jouées, faire réapparaître un nouveau trio
    if (_availablePieces.every((p) => p == null)) {
      _spawnNewTrio();
    }

    // Vérifier si au moins un coup reste possible
    if (!_board.hasAnyValidMove(_availablePieces)) {
      _isGameOver = true;
      AudioService.playGameOver();
      HapticService.onGameOver();
      GameStorage.clearSavedGameState();
    } else {
      _saveCurrentProgress();
    }

    notifyListeners();
  }

  void _spawnNewTrio() {
    final trio = _generator.generateTrio(_board);
    _availablePieces = [trio[0], trio[1], trio[2]];
  }

  void _saveCurrentProgress() {
    GameStorage.saveGameState({
      'board': _board.toJson(),
      'score': _score,
      'comboStreak': _comboStreak,
      'pieces': _availablePieces.map((p) => p?.toJson()).toList(),
    });
  }
}
