import 'package:flutter/material.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/theme/game_theme.dart';
import '../../engine/block_shape.dart';
import 'board_cell.dart';

class DraggablePiece extends StatelessWidget {
  final int pieceIndex;
  final BlockShape shape;
  final GameTheme theme;
  final double dockCellSize;
  final double boardCellSize;
  final bool isPlaceable;

  const DraggablePiece({
    Key? key,
    required this.pieceIndex,
    required this.shape,
    required this.theme,
    this.dockCellSize = 22.0,
    this.boardCellSize = 38.0,
    this.isPlaceable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Largeur et hauteur de la forme au format plateau
    final feedbackWidth = shape.cols * boardCellSize + (shape.cols - 1) * 3.0;
    final feedbackHeight = shape.rows * boardCellSize + (shape.rows - 1) * 3.0;

    return Draggable<Map<String, dynamic>>(
      data: {
        'pieceIndex': pieceIndex,
        'shape': shape,
      },
      onDragStarted: () {
        HapticService.onPiecePick();
      },
      // Le composant visuel qui flotte sous/au-dessus du doigt
      feedback: Material(
        color: Colors.transparent,
        child: Transform.translate(
          // Décalage vertical de -75px pour que le doigt ne cache jamais la pièce ni la grille !
          offset: Offset(-feedbackWidth / 2, -feedbackHeight / 2 - 75.0),
          child: _buildShapeMatrix(cellSize: boardCellSize, spacing: 3.0, opacity: 0.95),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.2,
        child: _buildShapeMatrix(cellSize: dockCellSize, spacing: 2.0, opacity: 0.2),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isPlaceable ? 1.0 : 0.4,
        child: _buildShapeMatrix(cellSize: dockCellSize, spacing: 2.0, opacity: 1.0),
      ),
    );
  }

  Widget _buildShapeMatrix({
    required double cellSize,
    required double spacing,
    required double opacity,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(shape.rows, (r) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(shape.cols, (c) {
            final isFilled = shape.matrix[r][c] > 0;
            return Padding(
              padding: EdgeInsets.all(spacing / 2),
              child: isFilled
                  ? BoardCell(
                      colorIndex: shape.colorIndex,
                      theme: theme,
                      size: cellSize,
                    )
                  : SizedBox(width: cellSize, height: cellSize),
            );
          }),
        );
      }),
    );
  }
}
