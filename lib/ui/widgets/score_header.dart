import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/game_provider.dart';
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ligne utilitaire supérieure (Pause, Meilleur score, Paramètres)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bouton Pause tactile
              _buildIconButton(
                icon: Icons.pause_rounded,
                onPressed: onPausePressed,
              ),

              // Pilule Meilleur Score avec couronne dorée
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'BEST: ${gameProvider.highScore}',
                      style: const TextStyle(
                        fontFamily: 'Space Grotesk',
                        color: AppColors.goldBest,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Bouton Paramètres / Thèmes
              _buildIconButton(
                icon: Icons.palette_rounded,
                onPressed: onSettingsPressed,
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Grand affichage du score avec typographie imposante
        Text(
          '${gameProvider.score}',
          style: const TextStyle(
            fontFamily: 'Rubik',
            color: Colors.white,
            fontSize: 48,
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

        const SizedBox(height: 4),

        // Bannière de combo dynamique
        ComboBanner(comboStreak: gameProvider.comboStreak),
      ],
    );
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
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: onPressed,
        splashRadius: 24,
      ),
    );
  }
}
