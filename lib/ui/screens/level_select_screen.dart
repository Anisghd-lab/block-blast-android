import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../engine/level_manager.dart';
import '../../providers/game_provider.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({Key? key}) : super(key: key);

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  int _currentPart = 1; // 1: Niveaux 1 à 25, 2: Niveaux 26 à 50

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final levelManager = LevelManager();
    final levels = levelManager.levels;
    final progress = levelManager.progress;

    final startIdx = (_currentPart - 1) * 25;
    final endIdx = (startIdx + 25).clamp(0, levels.length);
    final currentLevels = levels.sublist(startIdx, endIdx);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D1D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'CHOIX DU NIVEAU',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Onglets de sélection de parties
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF15162A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _currentPart = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: _currentPart == 1
                                ? const LinearGradient(
                                    colors: [Color(0xFF00F2FE), Color(0xFF0072FF)],
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Partie 1 (1 - 25)',
                              style: TextStyle(
                                color: _currentPart == 1 ? Colors.white : Colors.white60,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _currentPart = 2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: _currentPart == 2
                                ? const LinearGradient(
                                    colors: [Color(0xFF00F2FE), Color(0xFF0072FF)],
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Partie 2 (26 - 50)',
                              style: TextStyle(
                                color: _currentPart == 2 ? Colors.white : Colors.white60,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Grille 5 colonnes des niveaux
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: currentLevels.length,
                itemBuilder: (context, index) {
                  final lvl = currentLevels[index];
                  final isUnlocked = progress.isUnlocked(lvl.levelId);
                  final stars = progress.getStars(lvl.levelId);
                  final isCurrent = gameProvider.currentLevelId == lvl.levelId;

                  return GestureDetector(
                    onTap: isUnlocked
                        ? () {
                            gameProvider.switchMode(GameMode.adventure);
                            gameProvider.loadLevel(lvl.levelId);
                            Navigator.of(context).pop();
                          }
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFF00F2FE).withOpacity(0.2)
                            : (isUnlocked ? const Color(0xFF1B1C31) : const Color(0xFF121320)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFF00F2FE)
                              : (isUnlocked ? Colors.white24 : Colors.white10),
                          width: isCurrent ? 2.0 : 1.0,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF00F2FE).withOpacity(0.4),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isUnlocked ? '${lvl.levelId}' : '🔒',
                            style: TextStyle(
                              color: isUnlocked ? Colors.white : Colors.white38,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isUnlocked)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (s) {
                                return Icon(
                                  Icons.star,
                                  size: 11,
                                  color: s < stars ? Colors.amber : Colors.white24,
                                );
                              }),
                            )
                          else
                            const SizedBox(height: 11),
                        ],
                      ),
                    ),
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
