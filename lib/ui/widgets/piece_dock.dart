import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/game_theme.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import 'draggable_piece.dart';

class PieceDock extends StatelessWidget {
  const PieceDock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final theme = settingsProvider.currentTheme;

    final pieces = gameProvider.availablePieces;
    final board = gameProvider.board;

    final screenSize = MediaQuery.of(context).size;
    final dockWidth = (screenSize.width - 32.0).clamp(280.0, 440.0);
    const double fixedDockHeight = 106.0;

    return Container(
      width: dockWidth,
      height: fixedDockHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.surfaceColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(3, (index) {
          final piece = pieces[index];
          if (piece == null) {
            // Emplacement vide avec dimensions fixes pour ne jamais modifier la taille du dock
            return const Expanded(
              child: Center(
                child: SizedBox(
                  width: 76.0,
                  height: 76.0,
                ),
              ),
            );
          }

          final isPlaceable = board.canFitAnywhere(piece);
          final maxDim = piece.rows > piece.cols ? piece.rows : piece.cols;
          final uniformCellSize = maxDim >= 5 ? 12.5 : 14.0;

          return Expanded(
            child: Center(
              child: SizedBox(
                width: 76.0,
                height: 76.0,
                child: Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => gameProvider.rotatePiece(index),
                    child: DraggablePiece(
                      pieceIndex: index,
                      shape: piece,
                      theme: theme,
                      dockCellSize: uniformCellSize,
                      boardCellSize: 38.0,
                      isPlaceable: isPlaceable,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
