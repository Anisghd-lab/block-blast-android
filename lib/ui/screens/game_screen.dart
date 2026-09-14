import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/dialogs/game_over_dialog.dart';
import '../widgets/dialogs/level_defeat_dialog.dart';
import '../widgets/dialogs/level_victory_dialog.dart';
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

  void _showLevelVictoryDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const LevelVictoryDialog(),
    );
  }

  void _showLevelDefeatDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const LevelDefeatDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final theme = settingsProvider.currentTheme;

    // Déclencher les dialogues de fin de niveau ou de partie dès que l'état bascule
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.isCurrent != true) return;

      if (gameProvider.gameMode == GameMode.adventure) {
        if (gameProvider.isLevelWon) {
          _showLevelVictoryDialog(context);
        } else if (gameProvider.isLevelFailed) {
          _showLevelDefeatDialog(context);
        }
      } else {
        if (gameProvider.isGameOver) {
          _showGameOverDialog(context, gameProvider);
        }
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

            // 2. Grille de jeu 8x8 centrale
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: GameBoard(),
                ),
              ),
            ),

            // 3. Tiroir de pièces du bas fixé à l'écran
            const SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: PieceDock(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
