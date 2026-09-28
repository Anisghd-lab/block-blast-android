import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/game_theme.dart';
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
    final theme = settingsProvider.currentTheme;

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildUtilityButton(
                icon: Icons.pause_rounded,
                onPressed: onPausePressed,
                theme: theme,
              ),

              // Switcher Mode de Jeu (Niveaux vs Classique)
              Container(
                decoration: BoxDecoration(
                  color: theme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: theme.isDark ? Colors.black38 : const Color(0x14000000),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
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
                      theme: theme,
                    ),
                    _buildModeTab(
                      title: 'Classique',
                      isSelected: !isAdventure,
                      onTap: () => gameProvider.switchMode(GameMode.classic),
                      theme: theme,
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildUtilityButton(
                    icon: settingsProvider.isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    onPressed: () => settingsProvider.toggleDarkMode(),
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _buildUtilityButton(
                    icon: Icons.palette_rounded,
                    onPressed: onSettingsPressed,
                    theme: theme,
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Raccourci vers la sélection de niveau (en mode Aventure)
        if (isAdventure && level != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: theme.isDark ? Colors.black26 : const Color(0x10000000),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Niveau ${level.levelId} : ${level.title}',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: theme.primaryAccent,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 3. Bannière HUD Adaptative (TARGET | CAMÉO | MOVES/SCORE)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Container(
            decoration: BoxDecoration(
              color: theme.surfaceColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: theme.borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: theme.isDark ? Colors.black45 : const Color(0x14000000),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rangée principale : TARGET | CAMÉO | MOVES
                Row(
                  children: [
                    // A. Encart TARGET
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.borderColor, width: 1.0),
                          boxShadow: [
                            BoxShadow(
                              color: theme.isDark ? Colors.black26 : const Color(0x0C000000),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'TARGET',
                              style: TextStyle(
                                fontFamily: 'Space Grotesk',
                                color: theme.textMutedColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (isAdventure && level != null)
                              _buildTargetContent(gameProvider, level, theme)
                            else
                              _buildClassicTargetContent(gameProvider, theme),
                          ],
                        ),
                      ),
                    ),

                    // B. Caméo Central Dynamique
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildCenterCameo(
                        isCheering: isCheering,
                        isAlert: isAlert,
                        streak: gameProvider.comboStreak,
                        theme: theme,
                      ),
                    ),

                    // C. Encart MOVES / SCORE
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.borderColor, width: 1.0),
                          boxShadow: [
                            BoxShadow(
                              color: theme.isDark ? Colors.black26 : const Color(0x0C000000),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isAdventure ? 'MOVES' : 'SCORE',
                              style: TextStyle(
                                fontFamily: 'Space Grotesk',
                                color: theme.textMutedColor,
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
                                  color: isAlert ? theme.alertColor : theme.textColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              )
                            else
                              Text(
                                '${gameProvider.score}',
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  color: theme.textColor,
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

                const SizedBox(height: 5),

                // D. Jauge de progression 3 Étoiles
                _buildStarProgressBar(gameProvider, level, theme),
              ],
            ),
          ),
        ),

        // 4. Bannière dynamique de Combos
        ComboBanner(comboStreak: gameProvider.comboStreak),
      ],
    );
  }

  Widget _buildCenterCameo({
    required bool isCheering,
    required bool isAlert,
    required int streak,
    required GameTheme theme,
  }) {
    final emoji = isAlert
        ? '⚠️'
        : (isCheering ? (streak >= 3 ? '🔥' : '⭐') : '👑');

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: theme.cardColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCheering
              ? theme.primaryAccent
              : (isAlert ? theme.alertColor : theme.borderColor),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isCheering
                ? theme.primaryAccent.withValues(alpha: 0.4)
                : (theme.isDark ? Colors.black38 : const Color(0x14000000)),
            blurRadius: isCheering ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }

  Widget _buildTargetContent(GameProvider provider, GameLevel level, GameTheme theme) {
    bool isCompleted = false;
    String progressText = '';
    String goalIcon = '💎';

    switch (level.goal) {
      case LevelGoal.clearJewels:
        goalIcon = '💎';
        isCompleted = provider.levelJewelsCollected >= level.targetValue;
        progressText = '${provider.levelJewelsCollected}/${level.targetValue}';
        break;
      case LevelGoal.clearLines:
        goalIcon = '⚡';
        isCompleted = provider.levelLinesCleared >= level.targetValue;
        progressText = '${provider.levelLinesCleared}/${level.targetValue}';
        break;
      case LevelGoal.score:
        goalIcon = '⭐';
        isCompleted = provider.score >= level.targetValue;
        progressText = '${provider.score}';
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(goalIcon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Text(
          progressText,
          style: TextStyle(
            fontFamily: 'Rubik',
            color: theme.textColor,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (isCompleted) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.check_circle_rounded,
            color: theme.successColor,
            size: 16,
          ),
        ],
      ],
    );
  }

  Widget _buildClassicTargetContent(GameProvider provider, GameTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.emoji_events_rounded, color: theme.starGold, size: 18),
        const SizedBox(width: 4),
        Text(
          '${provider.highScore}',
          style: TextStyle(
            fontFamily: 'Rubik',
            color: theme.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildStarProgressBar(GameProvider provider, GameLevel? level, GameTheme theme) {
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
                color: theme.boardBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.borderColor, width: 1.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryAccent,
                            theme.starGold,
                          ],
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
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                color: theme.textColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: theme.isDark ? Colors.black87 : Colors.white70,
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),

            // Les 3 Étoiles Paliers (33%, 66%, 100%)
            Positioned(
              left: barWidth * 0.33 - 10,
              top: -4,
              child: _buildStarItem(isEarned: starsEarned >= 1, size: 22, theme: theme),
            ),
            Positioned(
              left: barWidth * 0.66 - 10,
              top: -4,
              child: _buildStarItem(isEarned: starsEarned >= 2, size: 22, theme: theme),
            ),
            Positioned(
              right: 0,
              top: -4,
              child: _buildStarItem(isEarned: starsEarned >= 3, size: 24, theme: theme),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStarItem({
    required bool isEarned,
    required double size,
    required GameTheme theme,
  }) {
    return Icon(
      isEarned ? Icons.star_rounded : Icons.star_outline_rounded,
      color: isEarned ? theme.starGold : theme.borderColor,
      size: size,
    );
  }

  Widget _buildModeTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required GameTheme theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Rubik',
            color: isSelected ? theme.buttonTextColor : theme.textMutedColor,
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
    required GameTheme theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        shape: BoxShape.circle,
        border: Border.all(color: theme.borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: theme.isDark ? Colors.black26 : const Color(0x10000000),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: theme.textColor, size: 19),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    );
  }
}
