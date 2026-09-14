import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/dialogs/game_over_dialog.dart';
import '../widgets/dialogs/pause_dialog.dart';
import '../widgets/game_board.dart';
import '../widgets/piece_dock.dart';
import '../widgets/score_header.dart';
import 'settings_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  void _showPauseDialog(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PauseDialog(
        onResume: () => Navigator.pop(ctx),
        onRestart: () {
          Navigator.pop(ctx);
          gameProvider.startNewGame();
        },
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, GameProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameOverDialog(
        score: provider.score,
        highScore: provider.highScore,
        onRestart: () {
          Navigator.pop(ctx);
          provider.startNewGame();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final theme = settingsProvider.currentTheme;

    // Déclencher le dialogue de fin de partie dès que l'état bascule
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (gameProvider.isGameOver && ModalRoute.of(context)?.isCurrent == true) {
        _showGameOverDialog(context, gameProvider);
      }
    });

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. HUD & Score
            ScoreHeader(
              onPausePressed: () => _showPauseDialog(context),
              onSettingsPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),

            const Spacer(flex: 1),

            // 2. Grille de jeu 8x8 centrale
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: GameBoard(),
            ),

            const Spacer(flex: 2),

            // 3. Tiroir de pièces du bas
            const Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: PieceDock(),
            ),
          ],
        ),
      ),
    );
  }
}
