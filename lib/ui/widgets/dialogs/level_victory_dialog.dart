import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/game_provider.dart';
import '../../screens/level_select_screen.dart';

class LevelVictoryDialog extends StatelessWidget {
  const LevelVictoryDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final level = gameProvider.currentLevel;
    final stars = gameProvider.starsEarned;
    final banner = level?.endLevelPresentation.victoryBanner ?? 'VICTOIRE !';
    final thresholds = level?.starThresholds;

    final bool star2Achieved = thresholds?.twoStarsMovesLeft != null
        ? (gameProvider.movesRemaining ?? 0) >= thresholds!.twoStarsMovesLeft!
        : true;
    final bool star3Achieved = thresholds != null
        ? gameProvider.score >= thresholds.threeStarsScore
        : false;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF111224),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF00F2FE),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F2FE).withOpacity(0.35),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bannière de bravoure
            Text(
              banner.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF00F2FE),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: Color(0x9900F2FE),
                    blurRadius: 16,
                  ),
                ],
              ),
            ),
            if (level != null) ...[
              const SizedBox(height: 2),
              Text(
                '${level.world} • Niveau ${level.levelId} : ${level.title}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 14),

            // Étoiles animées
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (s) {
                final isEarned = s < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.star_rounded,
                    size: 40,
                    color: isEarned ? const Color(0xFFFFD700) : Colors.white24,
                    shadows: isEarned
                        ? [
                            const Shadow(
                              color: Color(0xAAFFD700),
                              blurRadius: 14,
                            ),
                          ]
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),

            // Explication des 3 étoiles selon star_thresholds
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF181A30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _buildStarRow(
                    label: '⭐ 1 : Objectif complété',
                    isAchieved: true,
                  ),
                  const Divider(color: Colors.white10, height: 12),
                  _buildStarRow(
                    label: thresholds?.twoStarsMovesLeft != null
                        ? '⭐ 2 : Coups restants ≥ ${thresholds!.twoStarsMovesLeft}'
                        : '⭐ 2 : Fin de partie atteinte',
                    isAchieved: star2Achieved,
                  ),
                  const Divider(color: Colors.white10, height: 12),
                  _buildStarRow(
                    label: '⭐ 3 : Score élevé ≥ ${thresholds?.threeStarsScore ?? 1000}',
                    isAchieved: star3Achieved,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Score et Coups
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF15172A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Score Final',
                    style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${gameProvider.score}',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Bouton Niveau Suivant
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F2FE),
                  foregroundColor: const Color(0xFF00373A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 6,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  gameProvider.nextLevel();
                },
                child: const Text(
                  'NIVEAU SUIVANT ▶',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Boutons Rejouer et Niveaux
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      gameProvider.restartCurrentLevel();
                    },
                    child: const Text('REJOUER ↺', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
                      );
                    },
                    child: const Text('NIVEAUX 🗺️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRow({required String label, required bool isAchieved}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.between,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isAchieved ? Colors.white : Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          isAchieved ? '✓ Validé' : '✗ Non atteint',
          style: TextStyle(
            color: isAchieved ? const Color(0xFF00F2FE) : Colors.white24,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
