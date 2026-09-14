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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DraggablePiece(
                    pieceIndex: index,
                    shape: piece,
                    theme: theme,
                    dockCellSize: 18.0,
                    boardCellSize: 38.0,
                    isPlaceable: isPlaceable,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bouton Pivoter 90°
                      GestureDetector(
                        onTap: () => gameProvider.rotatePiece(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A2B42),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF00F2FE).withOpacity(0.4),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.rotate_right_rounded, color: Color(0xFF00F2FE), size: 14),
                              SizedBox(width: 2),
                              Text(
                                '90°',
                                style: TextStyle(
                                  color: Color(0xFF00F2FE),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Bouton Miroir
                      GestureDetector(
                        onTap: () => gameProvider.mirrorPiece(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D1B38),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFFF0844).withOpacity(0.4),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.flip_rounded, color: Color(0xFFFF708D), size: 14),
                              SizedBox(width: 2),
                              Text(
                                'Miroir',
                                style: TextStyle(
                                  color: Color(0xFFFF708D),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
