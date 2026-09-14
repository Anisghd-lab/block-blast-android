import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class GameOverDialog extends StatelessWidget {
  final int score;
  final int highScore;
  final VoidCallback onRestart;

  const GameOverDialog({
    Key? key,
    required this.score,
    required this.highScore,
    required this.onRestart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isNewRecord = score >= highScore && score > 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isNewRecord ? AppColors.goldBest : const Color(0xFF00F2FE),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: (isNewRecord ? AppColors.goldBest : const Color(0xFF00F2FE))
                  .withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titre Game Over ou Nouveau Record
            if (isNewRecord) ...[
              const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.goldBest,
                size: 56,
              ),
              const SizedBox(height: 8),
              const Text(
                'NOUVEAU RECORD !',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  color: AppColors.goldBest,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ] else ...[
              const Text(
                'PARTIE TERMINÉE',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Score obtenu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'SCORE',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$score',
                    style: const TextStyle(
                      fontFamily: 'Rubik',
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 16),
                  Text(
                    'MEILLEUR : $highScore',
                    style: const TextStyle(
                      fontFamily: 'Space Grotesk',
                      color: AppColors.goldBest,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bouton Rejouer
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F2FE),
                  foregroundColor: const Color(0xFF00373A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                ),
                onPressed: onRestart,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.replay_rounded, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'REJOUER',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
