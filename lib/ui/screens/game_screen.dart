import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/game_assets.dart';
import '../../engine/block_shape.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/booster_dock.dart';
import '../widgets/dialogs/game_over_dialog.dart';
import '../widgets/dialogs/level_defeat_dialog.dart';
import '../widgets/dialogs/level_victory_dialog.dart';
import '../widgets/dialogs/pause_dialog.dart';
import '../widgets/game_board.dart';
import '../widgets/piece_dock.dart';
import '../widgets/score_header.dart';
import 'settings_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late String _currentBackground;

  @override
  void initState() {
    super.initState();
    _currentBackground = GameAssets.getRandomBackground();
  }

  void _randomizeBackground() {
    setState(() {
      _currentBackground = GameAssets.getRandomBackground();
    });
  }

  void _showPauseDialog(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PauseDialog(
        onResume: () => Navigator.pop(ctx),
        onRestart: () {
          Navigator.pop(ctx);
          _randomizeBackground();
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
          _randomizeBackground();
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      color: theme.backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // 1. Fond aléatoire décoratif avec fondu d'opacité fluide
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: theme.isDark ? 0.20 : 0.12,
                child: Image.asset(
                  _currentBackground,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),

            // 2. Contenu principal et zone de jeu
            SafeArea(
              child: DragTarget<Map<String, dynamic>>(
                hitTestBehavior: HitTestBehavior.translucent,
                onWillAcceptWithDetails: (details) => true,
                onMove: (details) {
                  final shape = details.data['shape'] as BlockShape;
                  final target = GameBoard.calculateTargetCell(details.offset, shape);
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
                  final target = GameBoard.calculateTargetCell(details.offset, shape);
                  if (target != null) {
                    final pieceIndex = details.data['pieceIndex'] as int;
                    gameProvider.tryPlacePiece(pieceIndex, target.$1, target.$2);
                  }
                },
                builder: (context, candidateData, rejectedData) {
                  final bottomInset = MediaQuery.of(context).padding.bottom;
                  final isCompactScreen = MediaQuery.of(context).size.height < 740;

                  return Column(
                    children: [
                      // HUD & Score avec bouton bascule 1-clic Soleil/Lune
                      RepaintBoundary(
                        child: ScoreHeader(
                          onPausePressed: () => _showPauseDialog(context),
                          onSettingsPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SettingsScreen()),
                            );
                          },
                        ),
                      ),

                      // Grille de jeu centrale 8x8 dans son LayoutBuilder adaptatif
                      const Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                            child: GameBoard(),
                          ),
                        ),
                      ),

                      // Espacement vertical aéré
                      SizedBox(height: isCompactScreen ? 8.0 : 14.0),

                      // Barre des Boosters avec assets personnalisés
                      const RepaintBoundary(child: BoosterDock()),

                      // Espacement vertical aéré
                      SizedBox(height: isCompactScreen ? 8.0 : 14.0),

                      // Bac de pièces avec marge de sécurité système
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: math.max(bottomInset, isCompactScreen ? 6.0 : 12.0),
                        ),
                        child: const RepaintBoundary(child: PieceDock()),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
