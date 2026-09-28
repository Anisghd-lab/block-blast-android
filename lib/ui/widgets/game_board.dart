import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/game_theme.dart';
import '../../engine/block_shape.dart';
import '../../engine/board_state.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import 'board_cell.dart';
import 'juice_effects.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  final GlobalKey _boardKey = GlobalKey();
  final GlobalKey<JuiceOverlayState> _juiceKey = GlobalKey<JuiceOverlayState>();
  int _lastHandledClearTimestamp = 0;

  // Décalage tactile vertical standard pour mobile (la pièce flotte au-dessus du doigt)
  static const double fingerVerticalOffset = -75.0;

  void _handleClearEffects(
    ClearEvent event,
    double boardSize,
    double cellSize,
    double spacing,
    double padding,
    bool isCandyTheme,
  ) {
    final juice = _juiceKey.currentState;
    if (juice == null) return;

    final colors = isCandyTheme
        ? CandyColors.candyPalette
        : const [
            Color(0xFF00F2FE),
            Color(0xFFFF0844),
            Color(0xFFFED929),
            Color(0xFF00F5A0),
            Color(0xFF8B5CF6),
          ];

    // 1. Particules éclatantes sur chaque ligne détruite
    for (final r in event.rows) {
      final y = padding + r * (cellSize + spacing) + cellSize / 2;
      for (int c = 0; c < BoardState.size; c += 2) {
        final x = padding + c * (cellSize + spacing) + cellSize / 2;
        juice.emitBurst(
          position: Offset(x, y),
          colors: colors,
          particleCount: 10,
          emitShockwave: c == 0,
        );
      }
    }

    // 2. Particules éclatantes sur chaque colonne détruite
    for (final c in event.cols) {
      final x = padding + c * (cellSize + spacing) + cellSize / 2;
      for (int r = 0; r < BoardState.size; r += 2) {
        final y = padding + r * (cellSize + spacing) + cellSize / 2;
        juice.emitBurst(
          position: Offset(x, y),
          colors: colors,
          particleCount: 10,
          emitShockwave: r == 0,
        );
      }
    }

    // 3. Tremblement d'écran physique (Juice)
    if (event.totalLines >= 2 || event.comboStreak >= 2) {
      final mag = (3.5 + event.totalLines * 1.5 + event.comboStreak * 1.0).clamp(3.0, 9.0);
      juice.triggerScreenShake(magnitude: mag);
    }

    // 4. Textes flottants rebondissants
    String phrase;
    if (event.comboStreak >= 4) {
      phrase = '💥 INCROYABLE !';
    } else if (event.comboStreak == 3) {
      phrase = '🍭 SUCRÉ !';
    } else if (event.comboStreak == 2) {
      phrase = '🍬 DÉLICIEUX !';
    } else if (event.totalLines >= 3) {
      phrase = '⚡ TRIPLE BURST !';
    } else if (event.totalLines == 2) {
      phrase = '✨ DOUBLE COMBO !';
    } else {
      phrase = '+${event.points}';
    }

    juice.spawnFloatingText(
      position: Offset(boardSize / 2, boardSize * 0.45),
      text: phrase,
      color: event.comboStreak >= 2 ? CandyColors.rubyHeart : CandyColors.starGoldGlow,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final theme = settingsProvider.currentTheme;
    final isCandyTheme = theme.mode == GameThemeMode.sugarDelight;

    final screenSize = MediaQuery.of(context).size;
    final availableWidth = screenSize.width - 32.0;
    final availableHeight = screenSize.height * 0.48;
    final boardSize = (availableWidth < availableHeight ? availableWidth : availableHeight)
        .clamp(240.0, 420.0);
    const double padding = 10.0;
    const double spacing = 4.0;
    final cellSize = (boardSize - (padding * 2) - (spacing * 7)) / BoardState.size;

    // Déclencher les effets dès qu'un nouvel événement de destruction survient
    final clearEvent = gameProvider.lastClearEvent;
    if (clearEvent != null && clearEvent.timestamp != _lastHandledClearTimestamp) {
      _lastHandledClearTimestamp = clearEvent.timestamp;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleClearEffects(clearEvent, boardSize, cellSize, spacing, padding, isCandyTheme);
      });
    }

    return Center(
      child: JuiceOverlay(
        key: _juiceKey,
        child: Container(
        key: _boardKey,
        width: boardSize,
        height: boardSize,
        padding: const EdgeInsets.all(padding),
        decoration: isCandyTheme
            ? BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF345B92),
                    Color(0xFF233E65),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: CandyColors.boardBorder,
                  width: 3.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x660F2648),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Color(0x33FFFFFF),
                    blurRadius: 4,
                    offset: Offset(0, -1),
                  ),
                ],
              )
            : BoxDecoration(
                color: theme.surfaceColor,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
        child: DragTarget<Map<String, dynamic>>(
          onWillAcceptWithDetails: (details) => true,
          onMove: (details) {
            final shape = details.data['shape'] as BlockShape;
            final target = _calculateTargetCell(details.offset, boardSize, cellSize, spacing, padding, shape);
            if (target != null) {
              gameProvider.setDragPreview(shape, target.$1, target.$2);
            } else {
              gameProvider.setDragPreview(null, null, null);
            }
          },
          onLeave: (_) {
            gameProvider.setDragPreview(null, null, null);
          },
          onAcceptWithDetails: (details) {
            final shape = details.data['shape'] as BlockShape;
            final target = _calculateTargetCell(details.offset, boardSize, cellSize, spacing, padding, shape);
            if (target != null) {
              final pieceIndex = details.data['pieceIndex'] as int;
              gameProvider.tryPlacePiece(pieceIndex, target.$1, target.$2);
            }
          },
          builder: (context, candidateData, rejectedData) {
            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: BoardState.size * BoardState.size,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: BoardState.size,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
              ),
              itemBuilder: (context, index) {
                final r = index ~/ BoardState.size;
                final c = index % BoardState.size;

                final rawColor = gameProvider.board.grid[r][c];
                final isClearing = gameProvider.clearingRows.contains(r) ||
                    gameProvider.clearingCols.contains(c);

                // Vérifier si cette case fait partie de l'aperçu de placement en cours
                bool isGhost = false;
                bool isGhostValid = true;
                if (gameProvider.previewShape != null &&
                    gameProvider.previewRow != null &&
                    gameProvider.previewCol != null) {
                  final pShape = gameProvider.previewShape!;
                  final pRow = gameProvider.previewRow!;
                  final pCol = gameProvider.previewCol!;

                  final dr = r - pRow;
                  final dc = c - pCol;
                  if (dr >= 0 && dr < pShape.rows && dc >= 0 && dc < pShape.cols) {
                    if (pShape.matrix[dr][dc] > 0) {
                      isGhost = true;
                      isGhostValid = gameProvider.isPreviewValid;
                    }
                  }
                }

                return BoardCell(
                  colorIndex: rawColor,
                  isGhost: isGhost,
                  isGhostValid: isGhostValid,
                  isClearing: isClearing,
                  theme: theme,
                  size: cellSize,
                );
              },
            );
          },
        ),
      ),
      ),
    );
  }

  (int, int)? _calculateTargetCell(
    Offset globalTouchPosition,
    double boardSize,
    double cellSize,
    double spacing,
    double padding,
    BlockShape shape,
  ) {
    final renderBox = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final localTouch = renderBox.globalToLocal(globalTouchPosition);
    final visualCenter = Offset(localTouch.dx, localTouch.dy + fingerVerticalOffset);

    // Dimensions exactes de la pièce avec espacement
    final pieceWidth = shape.cols * cellSize + (shape.cols - 1) * spacing;
    final pieceHeight = shape.rows * cellSize + (shape.rows - 1) * spacing;

    // Coin supérieur gauche de la pièce
    final pieceLeft = visualCenter.dx - pieceWidth / 2;
    final pieceTop = visualCenter.dy - pieceHeight / 2;

    final totalStep = cellSize + spacing;
    final col = ((pieceLeft - padding) / totalStep).round();
    final row = ((pieceTop - padding) / totalStep).round();

    if (row < 0 || row + shape.rows > BoardState.size ||
        col < 0 || col + shape.cols > BoardState.size) {
      return null;
    }
    return (row, col);
  }
}
