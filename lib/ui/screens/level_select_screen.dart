import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/audio/audio_service.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/storage/game_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../engine/level_manager.dart';
import '../../engine/level_model.dart';
import '../../providers/game_provider.dart';
import '../widgets/candy_visuals.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({Key? key}) : super(key: key);

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  Timer? _regenTimer;
  late final AnimationController _pulseController;
  late final AnimationController _avatarBobController;

  static const double nodeStepY = 82.0;
  static const double bottomPadding = 140.0;
  static const double topPadding = 160.0;
  static const int totalLevels = 50;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _avatarBobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    // Minuteur pour rafraîchir le temps restant de la régénération des vies
    _regenTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    // Centrage automatique fluide sur le niveau actuel du joueur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentLevel();
    });
  }

  void _scrollToCurrentLevel() {
    final levelManager = LevelManager();
    final unlocked = levelManager.progress.unlockedLevel.clamp(1, totalLevels);
    final totalMapHeight = _calculateTotalHeight();
    final currentY = _calculateNodeY(unlocked, totalMapHeight);

    final screenHeight = MediaQuery.of(context).size.height;
    final targetOffset = (currentY - screenHeight * 0.5).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  double _calculateTotalHeight() {
    return (totalLevels - 1) * nodeStepY + bottomPadding + topPadding;
  }

  double _calculateNodeY(int levelId, double totalHeight) {
    return totalHeight - bottomPadding - (levelId - 1) * nodeStepY;
  }

  double _calculateNodeX(int levelId, double width) {
    // Courbe serpentine sinusoïdale fluide
    final swing = width * 0.32;
    return width * 0.5 + math.sin(levelId * 0.68) * swing;
  }

  @override
  void dispose() {
    _regenTimer?.cancel();
    _pulseController.dispose();
    _avatarBobController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showLuckyWheelDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _LuckyWheelDialog(
        onRewardClaimed: (coins) {
          GameStorage.addCoins(coins);
          setState(() {});
        },
      ),
    );
  }

  void _showRefillLivesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('❤️', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              'Vies & Énergie',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vous avez actuellement ${GameStorage.getLives()}/${GameStorage.maxLives} vies.',
              style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Une vie se régénère gratuitement toutes les 15 minutes.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.bolt_rounded),
                label: const Text(
                  'Recharger Plein (50 🪙)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  final success = await GameStorage.spendCoins(50);
                  if (success) {
                    await GameStorage.refillLives();
                    Navigator.pop(ctx);
                    setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pas assez de pièces ! Faites tourner la Roue !'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showLevelStartModal(GameLevel level, int starsAchieved) {
    final lives = GameStorage.getLives();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE0F2FE), Colors.white],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: CandyColors.hudBannerBlue, width: 3.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ruban Titre
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF00C8FF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x332563EB),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'NIVEAU ${level.levelId}',
                  style: const TextStyle(
                    fontFamily: 'Rubik',
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                level.title,
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  color: Color(0xFF1E3A8A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Monde : ${level.world}',
                style: const TextStyle(
                  fontFamily: 'Space Grotesk',
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),

              // Étoiles déjà obtenues
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (idx) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: StarBadge(isEarned: idx < starsAchieved, size: 30),
                  );
                }),
              ),
              const SizedBox(height: 18),

              // Objectif du Niveau
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: CandyColors.hudCardBorder),
                ),
                child: Row(
                  children: [
                    CandyWidget(
                      type: level.goal == LevelGoal.clearJewels
                          ? CandyType.gummyBear
                          : (level.goal == LevelGoal.clearLines ? CandyType.ring : CandyType.star),
                      size: 34,
                      showGlow: true,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'OBJECTIF',
                            style: TextStyle(
                              fontFamily: 'Space Grotesk',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            level.goal == LevelGoal.clearJewels
                                ? 'Récolter ${level.targetValue} Oursons'
                                : (level.goal == LevelGoal.clearLines
                                    ? 'Détruire ${level.targetValue} Lignes'
                                    : 'Atteindre ${level.targetValue} Pts'),
                            style: const TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Bouton JOUER !
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 14),
                ),
                onPressed: () async {
                  if (lives <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Plus de vies disponibles ! Attendez ou rechargez.')),
                    );
                    return;
                  }

                  await GameStorage.consumeLife();
                  final gameProvider = Provider.of<GameProvider>(context, listen: false);
                  gameProvider.loadLevel(level.levelId);
                  Navigator.pop(ctx); // Ferme modal
                  Navigator.pop(context); // Retourne au jeu
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow_rounded, size: 28),
                    SizedBox(width: 6),
                    Text(
                      'JOUER !',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final levelManager = LevelManager();
    final levels = levelManager.levels;
    final progress = levelManager.progress;
    final unlockedLevel = progress.unlockedLevel.clamp(1, totalLevels);
    final totalMapHeight = _calculateTotalHeight();

    final lives = GameStorage.getLives();
    final coins = GameStorage.getCoins();
    final secondsUntilLife = GameStorage.getSecondsUntilNextLife();
    final timeStr = '${(secondsUntilLife ~/ 60).toString().padLeft(2, '0')}:${(secondsUntilLife % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFF75C334), // Vert pâturage luxuriant Sugar Delight
      body: Stack(
        children: [
          // 1. Vue défilable de la carte overworld
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: screenSize.width,
              height: totalMapHeight,
              child: Stack(
                children: [
                  // Tracé du sentier serpentin et éléments de décor (Isolé dans un RepaintBoundary)
                  RepaintBoundary(
                    child: CustomPaint(
                      size: Size(screenSize.width, totalMapHeight),
                      painter: _SagaMapPainter(
                        totalLevels: totalLevels,
                        screenWidth: screenSize.width,
                        totalHeight: totalMapHeight,
                        unlockedLevel: unlockedLevel,
                        nodeStepY: nodeStepY,
                        bottomPadding: bottomPadding,
                      ),
                    ),
                  ),

                  // Pions de Niveaux 1 à 50
                  ...List.generate(totalLevels, (idx) {
                    final lvlId = idx + 1;
                    final isUnlocked = lvlId <= unlockedLevel;
                    final isCurrent = lvlId == unlockedLevel;
                    final stars = progress.starsPerLevel[lvlId] ?? 0;

                    final nx = _calculateNodeX(lvlId, screenSize.width);
                    final ny = _calculateNodeY(lvlId, totalMapHeight);

                    return Positioned(
                      left: nx - 27.0,
                      top: ny - 27.0,
                      child: _buildLevelPin(
                        levelId: lvlId,
                        isUnlocked: isUnlocked,
                        isCurrent: isCurrent,
                        stars: stars,
                        levels: levels,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // 2. Barre Supérieure Flottante (Vies, Pièces, Roue, Retour)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  // Bouton Retour
                  _buildCircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),

                  const SizedBox(width: 8),

                  // Capsule VIES (Cœur + Compteur + Minuteur + Plus)
                  GestureDetector(
                    onTap: _showRefillLivesDialog,
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF60A5FA), width: 1.8),
                        boxShadow: const [
                          BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('❤️', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 5),
                          Text(
                            '$lives',
                            style: const TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: Color(0xFFE11D48),
                            ),
                          ),
                          if (lives < GameStorage.maxLives) ...[
                            const SizedBox(width: 6),
                            Text(
                              timeStr,
                              style: const TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                          const SizedBox(width: 6),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 14),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Capsule PIÈCES (Or + Solde + Plus)
                  Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF59E0B), width: 1.8),
                      boxShadow: const [
                        BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 17)),
                        const SizedBox(width: 5),
                        Text(
                          '$coins',
                          style: const TextStyle(
                            fontFamily: 'Rubik',
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Bouton Roue de la fortune (Lucky Spin)
                  GestureDetector(
                    onTap: _showLuckyWheelDialog,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [Color(0xFFFFF275), Color(0xFFFF9800)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.0),
                        boxShadow: const [
                          BoxShadow(color: Color(0x33FF9800), blurRadius: 8, offset: Offset(0, 3)),
                        ],
                      ),
                      child: const Center(
                        child: Text('🎡', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelPin({
    required int levelId,
    required bool isUnlocked,
    required bool isCurrent,
    required int stars,
    required List<GameLevel> levels,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!isUnlocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Terminez le niveau précédent pour débloquer !'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }

        GameLevel? found;
        try {
          found = levels.firstWhere((l) => l.levelId == levelId);
        } catch (_) {}

        if (found != null) {
          AudioService.playPiecePick();
          HapticService.onPiecePick();
          _showLevelStartModal(found, stars);
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Halo d'énergie pulsant sur le niveau courant
          if (isCurrent)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + _pulseController.value * 0.28;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFD54F).withOpacity(0.45 * (1.0 - _pulseController.value)),
                    ),
                  ),
                );
              },
            ),

          // Bouton du Pion
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isUnlocked
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFCBD5E1), Color(0xFF64748B)],
                    ),
              border: Border.all(
                color: isUnlocked ? const Color(0xFFFFB300) : const Color(0xFF94A3B8),
                width: 3.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: isUnlocked
                  ? Text(
                      '$levelId',
                      style: const TextStyle(
                        fontFamily: 'Rubik',
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 19,
                        shadows: [
                          Shadow(color: Colors.black45, offset: Offset(0, 1.5), blurRadius: 3),
                        ],
                      ),
                    )
                  : const Icon(Icons.lock_rounded, color: Colors.white70, size: 20),
            ),
          ),

          // Étoiles obtenues en arc au-dessus du niveau
          if (isUnlocked && !isCurrent)
            Positioned(
              top: -14,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (starIdx) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: StarBadge(isEarned: starIdx < stars, size: 16),
                  );
                }),
              ),
            ),

          // Avatar de la Mascotte Pâtissière flottant sur le niveau courant
          if (isCurrent)
            Positioned(
              top: -38,
              child: AnimatedBuilder(
                animation: _avatarBobController,
                builder: (context, child) {
                  final bob = math.sin(_avatarBobController.value * math.pi) * 5.0;
                  return Transform.translate(
                    offset: Offset(0, -bob),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF00E5FF), width: 2.2),
                        boxShadow: const [
                          BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 3)),
                        ],
                      ),
                      child: const Center(
                        child: Text('👩‍🍳', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF60A5FA), width: 1.8),
        boxShadow: const [
          BoxShadow(color: Color(0x1F000000), blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF1E3A8A), size: 18),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    );
  }
}

/// CustomPainter traçant le sentier serpentin luxuriant et les décors
class _SagaMapPainter extends CustomPainter {
  final int totalLevels;
  final double screenWidth;
  final double totalHeight;
  final int unlockedLevel;
  final double nodeStepY;
  final double bottomPadding;

  _SagaMapPainter({
    required this.totalLevels,
    required this.screenWidth,
    required this.totalHeight,
    required this.unlockedLevel,
    required this.nodeStepY,
    required this.bottomPadding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fond collines avec nuances douces
    final bgPaint = Paint()..color = const Color(0xFF86D238);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Construction de la trajectoire serpentine fluide
    final path = Path();
    final points = <Offset>[];

    for (int lvl = 1; lvl <= totalLevels; lvl++) {
      final y = totalHeight - bottomPadding - (lvl - 1) * nodeStepY;
      final x = screenWidth * 0.5 + math.sin(lvl * 0.68) * (screenWidth * 0.32);
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final midX = (p0.dx + p1.dx) / 2;
        final midY = (p0.dy + p1.dy) / 2;
        path.quadraticBezierTo(p0.dx, p0.dy, midX, midY);
      }
      path.lineTo(points.last.dx, points.last.dy);
    }

    // Bordure extérieure de la route (vert herbe foncé)
    final roadBorderPaint = Paint()
      ..color = const Color(0xFF5BA723)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 46.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, roadBorderPaint);

    // Corps de la route verte tendre
    final roadPaint = Paint()
      ..color = const Color(0xFFB5EC7C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, roadPaint);

    // Ligne pointillée jaune pavés au centre
    final dashPaint = Paint()
      ..color = const Color(0xFFFEF08A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // Décors gourmands le long de la route (Gâteaux, maisons pain d'épices, marguerites)
    for (int lvl = 1; lvl <= totalLevels; lvl++) {
      final p = points[lvl - 1];
      // Marguerites
      if (lvl % 3 == 0) {
        _paintDaisy(canvas, Offset(p.dx + (lvl % 2 == 0 ? 50 : -50), p.dy + 15));
      }
      // Arbres bonbons
      if (lvl % 7 == 0) {
        _paintCandyTree(canvas, Offset(lvl % 2 == 0 ? 35 : screenWidth - 35, p.dy));
      }
    }
  }

  void _paintDaisy(Canvas canvas, Offset center) {
    final petalPaint = Paint()..color = Colors.white;
    const count = 5;
    for (int i = 0; i < count; i++) {
      final ang = i * (2 * math.pi / count);
      canvas.drawCircle(Offset(center.dx + math.cos(ang) * 5, center.dy + math.sin(ang) * 5), 3.5, petalPaint);
    }
    canvas.drawCircle(center, 3.0, Paint()..color = const Color(0xFFFFC107));
  }

  void _paintCandyTree(Canvas canvas, Offset pos) {
    // Tronc
    canvas.drawRect(Rect.fromLTWH(pos.dx - 3, pos.dy, 6, 16), Paint()..color = const Color(0xFF92400E));
    // Feuillage confiserie
    canvas.drawCircle(pos, 15, Paint()..color = const Color(0xFFFFB300));
    canvas.drawCircle(pos + const Offset(-4, -4), 5, Paint()..color = Colors.white.withOpacity(0.4));
  }

  @override
  bool shouldRepaint(covariant _SagaMapPainter oldDelegate) => false;
}

/// Dialogue Roue de la Fortune (Lucky Spin)
class _LuckyWheelDialog extends StatefulWidget {
  final ValueChanged<int> onRewardClaimed;

  const _LuckyWheelDialog({Key? key, required this.onRewardClaimed}) : super(key: key);

  @override
  State<_LuckyWheelDialog> createState() => _LuckyWheelDialogState();
}

class _LuckyWheelDialogState extends State<_LuckyWheelDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  final math.Random _rng = math.Random();
  bool _isSpinning = false;
  int _wonCoins = 0;

  final List<int> _rewards = [20, 50, 100, 30, 200, 40, 80, 500];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;
    setState(() => _isSpinning = true);

    final prizeIndex = _rng.nextInt(_rewards.length);
    _wonCoins = _rewards[prizeIndex];

    AudioService.playWheelTick();
    HapticService.onWheelTick();

    _spinController.reset();
    _spinController.forward().then((_) {
      widget.onRewardClaimed(_wonCoins);
      AudioService.playCoinReward();
      HapticService.onWheelReward();
      setState(() => _isSpinning = false);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('🎉 FÉLICITATIONS !', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Vous avez remporté $_wonCoins Pièces d\'or ! 🪙'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('SUPER !'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFFFB300), width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎡 ROUE DE LA FORTUNE',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),
            RotationTransition(
              turns: Tween<double>(begin: 0.0, end: 5.0).animate(
                CurvedAnimation(parent: _spinController, curve: Curves.decelerate),
              ),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const SweepGradient(
                    colors: [
                      Color(0xFFFF3366),
                      Color(0xFFFFBE0B),
                      Color(0xFF10B981),
                      Color(0xFF00C8FF),
                      Color(0xFFA855F7),
                      Color(0xFFFF7A00),
                      Color(0xFFFF3366),
                    ],
                  ),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: const [
                    BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: const Center(
                  child: Text('🎁', style: TextStyle(fontSize: 48)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: _isSpinning ? null : _spin,
              child: Text(
                _isSpinning ? 'EN ROTATION...' : 'TOURNER LA ROUE !',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
