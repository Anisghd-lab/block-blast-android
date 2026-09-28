import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../engine/level_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import '../screens/level_select_screen.dart';
import 'candy_visuals.dart';
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
    final isAdventure = gameProvider.gameMode == GameMode.adventure;
    final level = gameProvider.currentLevel;
    final isCheering = gameProvider.comboStreak >= 2 || gameProvider.isLevelWon;
    final isAlert = isAdventure &&
        gameProvider.movesRemaining != null &&
        gameProvider.movesRemaining! <= 3 &&
        !gameProvider.isLevelWon;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Barre d'utilitaires supérieure (Pause, Sélecteur de Mode, Paramètres)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildUtilityButton(
                icon: Icons.pause_rounded,
                onPressed: onPausePressed,
              ),

              // Switcher Mode de Jeu (Niveaux vs Classique)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CandyColors.hudCardBorder, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2.5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeTab(
                      title: 'Aventure',
                      isSelected: isAdventure,
                      onTap: () => gameProvider.switchMode(GameMode.adventure),
                    ),
                    _buildModeTab(
                      title: 'Classique',
                      isSelected: !isAdventure,
                      onTap: () => gameProvider.switchMode(GameMode.classic),
                    ),
                  ],
                ),
              ),

              _buildUtilityButton(
                icon: Icons.palette_rounded,
                onPressed: onSettingsPressed,
              ),
            ],
          ),
        ),

        // 2. Raccourci vers la sélection de niveau (en mode Aventure)
        if (isAdventure && level != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.5)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x15000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Niveau ${level.levelId} : ${level.title}',
                      style: const TextStyle(
                        fontFamily: 'Rubik',
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 3. Bannière Cartoon Sugar Delight (TARGET | MASCOTTE | MOVES)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CandyColors.hudBannerBlue,
                  CandyColors.hudBannerBlueDark,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: CandyColors.hudBannerBlueDark.withOpacity(0.55),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rangée principale : TARGET | MASCOTTE | MOVES
                Row(
                  children: [
                    // A. Encart TARGET
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 64,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: CandyColors.hudCardWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: CandyColors.hudCardBorder, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1F000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'TARGET',
                              style: TextStyle(
                                fontFamily: 'Space Grotesk',
                                color: Color(0xFF64748B),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (isAdventure && level != null)
                              _buildTargetContent(gameProvider, level)
                            else
                              _buildClassicTargetContent(gameProvider),
                          ],
                        ),
                      ),
                    ),

                    // B. Cameo Mascotte Pastry Girl
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: MascotCameo(
                        size: 52,
                        isCheering: isCheering,
                        isAlert: isAlert,
                      ),
                    ),

                    // C. Encart MOVES / SCORE
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 64,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: CandyColors.hudCardWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: CandyColors.hudCardBorder, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1F000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isAdventure ? 'MOVES' : 'SCORE',
                              style: const TextStyle(
                                fontFamily: 'Space Grotesk',
                                color: Color(0xFF64748B),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (isAdventure)
                              Text(
                                gameProvider.movesRemaining != null
                                    ? '${gameProvider.movesRemaining}'
                                    : '∞',
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  color: isAlert ? const Color(0xFFE11D48) : CandyColors.textCaramel,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              )
                            else
                              Text(
                                '${gameProvider.score}',
                                style: const TextStyle(
                                  fontFamily: 'Rubik',
                                  color: CandyColors.textCaramel,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // D. Jauge de progression 3 Étoiles
                _buildStarProgressBar(gameProvider, level),
              ],
            ),
          ),
        ),

        // 4. Bannière dynamique de Combos
        ComboBanner(comboStreak: gameProvider.comboStreak),
      ],
    );
  }

  Widget _buildTargetContent(GameProvider provider, GameLevel level) {
    bool isCompleted = false;
    String progressText = '';
    CandyType targetCandy = CandyType.gummyBear;

    switch (level.goal) {
      case LevelGoal.clearJewels:
        targetCandy = CandyType.gummyBear;
        isCompleted = provider.levelJewelsCollected >= level.targetValue;
        progressText = '${provider.levelJewelsCollected}/${level.targetValue}';
        break;
      case LevelGoal.clearLines:
        targetCandy = CandyType.ring;
        isCompleted = provider.levelLinesCleared >= level.targetValue;
        progressText = '${provider.levelLinesCleared}/${level.targetValue}';
        break;
      case LevelGoal.score:
        targetCandy = CandyType.star;
        isCompleted = provider.score >= level.targetValue;
        progressText = '${provider.score}';
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CandyWidget(type: targetCandy, size: 22),
        const SizedBox(width: 5),
        Text(
          progressText,
          style: const TextStyle(
            fontFamily: 'Rubik',
            color: CandyColors.textCaramel,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (isCompleted) ...[
          const SizedBox(width: 4),
          const Icon(
            Icons.check_circle_rounded,
            color: CandyColors.greenSuccess,
            size: 16,
          ),
        ],
      ],
    );
  }

  Widget _buildClassicTargetContent(GameProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.emoji_events_rounded, color: CandyColors.starGold, size: 18),
        const SizedBox(width: 4),
        Text(
          '${provider.highScore}',
          style: const TextStyle(
            fontFamily: 'Rubik',
            color: CandyColors.textCaramel,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildStarProgressBar(GameProvider provider, GameLevel? level) {
    final targetScore = (level?.starThresholds.threeStarsScore ?? 1500).toDouble();
    final currentScore = provider.score.toDouble();
    final progress = (currentScore / targetScore).clamp(0.0, 1.0);

    final starsEarned = currentScore >= targetScore
        ? 3
        : (currentScore >= targetScore * 0.66
            ? 2
            : (currentScore >= targetScore * 0.33 ? 1 : 0));

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Rail de la jauge
            Container(
              width: barWidth,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF164E8A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.5), width: 1.2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFFFFD54F)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Score numérique au centre de la jauge
            Text(
              '${provider.score}',
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),

            // Les 3 Étoiles Paliers (33%, 66%, 100%)
            Positioned(
              left: barWidth * 0.33 - 10,
              top: -4,
              child: StarBadge(isEarned: starsEarned >= 1, size: 22),
            ),
            Positioned(
              left: barWidth * 0.66 - 10,
              top: -4,
              child: StarBadge(isEarned: starsEarned >= 2, size: 22),
            ),
            Positioned(
              right: 0,
              top: -4,
              child: StarBadge(isEarned: starsEarned >= 3, size: 24),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModeTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF38BDF8), Color(0xFF2563EB)],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Rubik',
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.w800,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }

  Widget _buildUtilityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(color: CandyColors.hudCardBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF1E3A8A), size: 19),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    );
  }
}
