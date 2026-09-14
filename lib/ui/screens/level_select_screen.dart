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
  int _selectedWorld = 0; // 0: Initiation, 1: Pierres, 2: Poids Lourd, 3: Combos, 4: Master

  final List<Map<String, String>> _worlds = [
    {'title': '🌟 Initiation', 'range': '1 - 10'},
    {'title': '💎 Pierres', 'range': '11 - 20'},
    {'title': '🗿 Poids Lourd', 'range': '21 - 30'},
    {'title': '⚡ Combos', 'range': '31 - 40'},
    {'title': '👑 Master', 'range': '41 - 50'},
  ];

  @override
  void initState() {
    super.initState();
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    _selectedWorld = ((gameProvider.currentLevelId - 1) ~/ 10).clamp(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final levelManager = LevelManager();
    final levels = levelManager.levels;
    final progress = levelManager.progress;

    final startIdx = _selectedWorld * 10;
    final endIdx = (startIdx + 10).clamp(0, levels.length);
    final currentLevels = levels.isNotEmpty ? levels.sublist(startIdx, endIdx) : [];

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
            // Onglets des 5 Mondes (scrollables horizontalement)
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: _worlds.length,
                itemBuilder: (context, idx) {
                  final world = _worlds[idx];
                  final isSelected = _selectedWorld == idx;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedWorld = idx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [Color(0xFF00F2FE), Color(0xFF0072FF)],
                                )
                              : null,
                          color: isSelected ? null : const Color(0xFF1B1C31),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF00F2FE) : Colors.white12,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF00F2FE).withOpacity(0.35),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '${world['title']} (${world['range']})',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white60,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Grille des niveaux du monde sélectionné (5 colonnes x 2 lignes)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 14,
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
                            ? const Color(0xFF00F2FE).withOpacity(0.25)
                            : (isUnlocked ? const Color(0xFF1B1C31) : const Color(0xFF121320)),
                        borderRadius: BorderRadius.circular(16),
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
                                  blurRadius: 10,
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
                                  Icons.star_rounded,
                                  size: 13,
                                  color: s < stars ? const Color(0xFFFFD700) : Colors.white24,
                                );
                              }),
                            )
                          else
                            const SizedBox(height: 13),
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
