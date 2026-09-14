import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/game_theme.dart';
import '../../engine/block_shape.dart';
import '../../engine/board_state.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import 'board_cell.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  final GlobalKey _boardKey = GlobalKey();

  // Décalage tactile vertical standard pour mobile (la pièce flotte au-dessus du doigt)
  static const double fingerVerticalOffset = -75.0;

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final theme = settingsProvider.currentTheme;

    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = (screenWidth - 32.0).clamp(280.0, 440.0);
    const double padding = 10.0;
    const double spacing = 4.0;
    final cellSize = (boardSize - (padding * 2) - (spacing * 7)) / BoardState.size;

    return Center(
      child: Container(
        key: _boardKey,
        width: boardSize,
        height: boardSize,
        padding: const EdgeInsets.all(padding),
        decoration: BoxDecoration(
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
