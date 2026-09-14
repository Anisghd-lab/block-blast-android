import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../engine/level_model.dart';
import '../../../providers/game_provider.dart';
import '../../screens/level_select_screen.dart';

class LevelDefeatDialog extends StatelessWidget {
  const LevelDefeatDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final level = gameProvider.currentLevel;

    String progressText = '';
    if (level != null) {
      if (level.goal == LevelGoal.clearJewels) {
        progressText = 'Gemmes : ${gameProvider.levelJewelsCollected} / ${level.targetValue}';
      } else if (level.goal == LevelGoal.clearLines) {
        progressText = 'Lignes : ${gameProvider.levelLinesCleared} / ${level.targetValue}';
      } else {
        progressText = 'Score : ${gameProvider.score} / ${level.targetValue}';
      }
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF111224),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFFF0844),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF0844).withOpacity(0.3),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '💔',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),
            const Text(
              'NIVEAU ÉCHOUÉ',
              style: TextStyle(
                color: Color(0xFFFF0844),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              gameProvider.defeatReason.isNotEmpty
                  ? gameProvider.defeatReason
                  : 'Objectif non atteint',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Progression atteinte
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF181A30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  const Text(
                    'Progression atteinte',
                    style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    progressText,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bouton Réessayer
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0844),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 6,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  gameProvider.restartCurrentLevel();
                },
                child: const Text(
                  'RÉESSAYER ↺',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Bouton Choix du niveau
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
                  );
                },
                child: const Text(
                  'CHOIX DU NIVEAU 🗺️',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
