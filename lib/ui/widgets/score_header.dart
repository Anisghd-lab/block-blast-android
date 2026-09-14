import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../engine/level_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import '../screens/level_select_screen.dart';
import 'combo_banner.dart';

class ScoreHeader extends StatelessWidget {
  final VoidCallback onPausePressed;
  final VoidCallback onSettingsPressed;

  const ScoreHeader({
    Key? key,
    required this.onPausePressed,
    required this.onSettingsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final isAdventure = gameProvider.gameMode == GameMode.adventure;
    final level = gameProvider.currentLevel;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Barre d'utilitaires supérieure (Pause, Switcher Mode, Paramètres)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconButton(
                icon: Icons.pause_rounded,
                onPressed: onPausePressed,
              ),

              // Switcher Mode de Jeu (Niveaux vs Classique)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF15162A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => gameProvider.switchMode(GameMode.adventure),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: isAdventure
                              ? const LinearGradient(
                                  colors: [Color(0xFF00F2FE), Color(0xFF0072FF)],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '🗺️ Niveaux',
                          style: TextStyle(
                            color: isAdventure ? Colors.white : Colors.white60,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => gameProvider.switchMode(GameMode.classic),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: !isAdventure
                              ? const LinearGradient(
                                  colors: [Color(0xFFFF9900), Color(0xFFFF5E00)],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '⚡ Classique',
                          style: TextStyle(
                            color: !isAdventure ? Colors.white : Colors.white60,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconButton(
                    icon: settingsProvider.soundEnabled
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    onPressed: () => settingsProvider.toggleSound(),
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    icon: Icons.palette_rounded,
                    onPressed: onSettingsPressed,
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Contenu spécifique selon le mode
        if (isAdventure && level != null) ...[
          // Badge Niveau cliquable pour ouvrir la sélection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00F2FE).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF00F2FE).withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Niveau ${level.levelId}',
                          style: const TextStyle(
                            color: Color(0xFF00F2FE),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF00F2FE),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  level.title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Cartes Objectif & Coups restants
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                // Objectif
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17182B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00F2FE).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              level.goal.icon,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'OBJECTIF',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _formatGoalProgress(gameProvider, level),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Coups
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17182B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('👣', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'COUPS',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                gameProvider.movesRemaining != null
                                    ? '${gameProvider.movesRemaining}'
                                    : 'Illimité',
                                style: TextStyle(
                                  color: (gameProvider.movesRemaining != null &&
                                          gameProvider.movesRemaining! <= 3)
                                      ? const Color(0xFFFF0844)
                                      : Colors.amber,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // En mode Classique : Affichage Record + Grand Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.goldBest.withOpacity(0.3),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.goldBest,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'RECORD: ${gameProvider.highScore}',
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk',
                    color: AppColors.goldBest,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${gameProvider.score}',
            style: const TextStyle(
              fontFamily: 'Rubik',
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
              shadows: [
                Shadow(
                  color: Color(0x6600F2FE),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
        ],

        // Bannière de combo
        ComboBanner(comboStreak: gameProvider.comboStreak),
      ],
    );
  }

  String _formatGoalProgress(GameProvider provider, GameLevel level) {
    switch (level.goal) {
      case LevelGoal.clearJewels:
        return '${provider.levelJewelsCollected} / ${level.targetValue}';
      case LevelGoal.clearLines:
        return '${provider.levelLinesCleared} / ${level.targetValue} Lig.';
      case LevelGoal.score:
        return '${provider.score} / ${level.targetValue} Pts';
    }
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.0,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        splashRadius: 22,
      ),
    );
  }
}
