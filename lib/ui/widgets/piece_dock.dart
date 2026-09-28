import 'game_board.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
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
    final isCandyTheme = theme.mode == GameThemeMode.sugarDelight;

    final pieces = gameProvider.availablePieces;
    final board = gameProvider.board;

    final screenSize = MediaQuery.of(context).size;
    final dockWidth = (screenSize.width - 32.0).clamp(280.0, 440.0);
    const double fixedDockHeight = 106.0;

    return Container(
      width: dockWidth,
      height: fixedDockHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: isCandyTheme
          ? BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(
                color: CandyColors.hudCardBorder,
                width: 2.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            )
          : BoxDecoration(
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
                  width: 84.0,
                  height: 84.0,
                ),
              ),
            );
          }

          final isPlaceable = board.canFitAnywhere(piece);
          final maxDim = piece.rows > piece.cols ? piece.rows : piece.cols;

          // Tailles adaptatives généreuses pour que les blocs soient bien visibles et faciles à saisir
          final double uniformCellSize;
          if (maxDim <= 1) {
            uniformCellSize = 38.0; // Bloc 1x1 bien grand (38px) et facile à attraper
          } else if (maxDim <= 2) {
            uniformCellSize = 28.0; // Bloc 2x2 = 56px
          } else if (maxDim <= 3) {
            uniformCellSize = 22.0; // Bloc 3x3 = 66px
          } else if (maxDim <= 4) {
            uniformCellSize = 17.5; // Bloc 4x4 = 70px
          } else {
            uniformCellSize = 14.5; // Barre de 5 = 72px
          }

          return Expanded(
            child: Center(
              child: SizedBox(
                width: 84.0,
                height: 84.0,
                child: Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => gameProvider.rotatePiece(index),
                    child: DraggablePiece(
                      pieceIndex: index,
                      shape: piece,
                      theme: theme,
                      dockCellSize: uniformCellSize,
                      boardCellSize: GameBoard.currentCellSize > 0 ? GameBoard.currentCellSize : 34.0,
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
