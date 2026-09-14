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

    final screenWidth = MediaQuery.of(context).size.width;
    final dockWidth = (screenWidth - 32.0).clamp(280.0, 440.0);

    return Container(
      width: dockWidth,
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            // Emplacement vide
            return const Expanded(
              child: SizedBox(),
            );
          }

          final isPlaceable = board.canFitAnywhere(piece);

          return Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () => gameProvider.rotatePiece(index),
                child: DraggablePiece(
                  pieceIndex: index,
                  shape: piece,
                  theme: theme,
                  dockCellSize: 20.0,
                  boardCellSize: 38.0,
                  isPlaceable: isPlaceable,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
