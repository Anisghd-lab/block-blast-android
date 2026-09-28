import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/storage/game_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/game_provider.dart';

/// Barre d'outils et boosters tactiques du bas (Inspiré de Sugar Delight)
/// Propose 4 boosters signatures :
/// 1. 🍭🔨 Marteau Sucré (Détruit 1 bonbon ou obstacle)
/// 2. 💣 Bombe Soda (Explose une zone 3x3)
/// 3. 🧤 Gant Magique (Régénère le trio de pièces disponibles)
/// 4. ➕🖐️ +5 Coups (Ajoute 5 coups au niveau en cours)
class BoosterDock extends StatelessWidget {
  const BoosterDock({Key? key}) : super(key: key);

  void _showBuyBoosterDialog(
    BuildContext context,
    GameProvider provider, {
    required String type,
    required String title,
    required String description,
    required int cost,
    required Widget iconWidget,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        final currentCoins = GameStorage.getCoins();
        final canAfford = currentCoins >= cost;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF9ED),
                  Color(0xFFFFECD1),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: CandyColors.boardBorder,
                width: 3.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Grand Icone du booster
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0xFFFFF3DB), Color(0xFFFFD580)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(child: iconWidget),
                ),
                const SizedBox(height: 12),

                // 2. Nom du booster
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF6B3600),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),

                // 3. Description
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF825227),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 18),

                // 4. Solde actuel et prix
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD580)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Vos Pièces :',
                        style: TextStyle(
                          color: Color(0xFF825227),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Row(
                        children: [
                          const Text('🪙 ', style: TextStyle(fontSize: 14)),
                          Text(
                            '$currentCoins',
                            style: const TextStyle(
                              color: Color(0xFF6B3600),
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 5. Bouton d'achat ou solde insuffisant
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canAfford
                          ? const Color(0xFF48BB78)
                          : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      elevation: canAfford ? 6 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: canAfford
                        ? () async {
                            final ok = await provider.buyBooster(type, cost);
                            if (ok && ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                  content: Text(
                                    '🎉 $title acheté avec succès !',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          canAfford ? 'ACHETER POUR $cost 🪙' : 'PIÈCES INSUFFISANTES',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Bouton Fermer
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(
                      color: Color(0xFF825227),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final active = provider.activeBooster;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: const Color(0xE8FFFFFF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: CandyColors.boardBorder.withOpacity(0.8),
            width: 2.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Color(0x66FFFFFF),
              blurRadius: 2,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 1. Marteau Sucré
            _BoosterButton(
              title: 'Marteau',
              count: provider.hammerCount,
              isActive: active == ActiveBooster.hammer,
              icon: const CustomPaint(
                size: Size(32, 32),
                painter: HammerIconPainter(),
              ),
              onTap: () {
                if (provider.hammerCount > 0) {
                  provider.selectBooster(ActiveBooster.hammer);
                } else {
                  _showBuyBoosterDialog(
                    context,
                    provider,
                    type: 'hammer',
                    title: 'Marteau Sucré 🍭🔨',
                    description: 'Écrase n\'importe quel bonbon ou obstacle sur la grille d\'un seul coup sec !',
                    cost: 50,
                    iconWidget: const CustomPaint(
                      size: Size(44, 44),
                      painter: HammerIconPainter(),
                    ),
                  );
                }
              },
            ),

            // 2. Bombe Soda
            _BoosterButton(
              title: 'Bombe',
              count: provider.bombCount,
              isActive: active == ActiveBooster.bomb,
              icon: const CustomPaint(
                size: Size(32, 32),
                painter: BombIconPainter(),
              ),
              onTap: () {
                if (provider.bombCount > 0) {
                  provider.selectBooster(ActiveBooster.bomb);
                } else {
                  _showBuyBoosterDialog(
                    context,
                    provider,
                    type: 'bomb',
                    title: 'Bombe Soda 💣',
                    description: 'Déclenche une puissante onde de choc détruisant une zone entière de 3x3 cases !',
                    cost: 60,
                    iconWidget: const CustomPaint(
                      size: Size(44, 44),
                      painter: BombIconPainter(),
                    ),
                  );
                }
              },
            ),

            // 3. Gant Magique (Reroll)
            _BoosterButton(
              title: 'Gant',
              count: provider.gloveCount,
              isActive: false,
              icon: const CustomPaint(
                size: Size(32, 32),
                painter: GloveIconPainter(),
              ),
              onTap: () {
                if (provider.gloveCount > 0) {
                  provider.useGloveReroll();
                } else {
                  _showBuyBoosterDialog(
                    context,
                    provider,
                    type: 'glove',
                    title: 'Gant Magique 🧤',
                    description: 'Remplace instantanément les 3 pièces du tiroir par 3 nouvelles formes fraîches !',
                    cost: 40,
                    iconWidget: const CustomPaint(
                      size: Size(44, 44),
                      painter: GloveIconPainter(),
                    ),
                  );
                }
              },
            ),

            // 4. +5 Coups Extra
            _BoosterButton(
              title: '+5 Coups',
              count: provider.extraMovesCount,
              isActive: false,
              icon: const CustomPaint(
                size: Size(32, 32),
                painter: ExtraMovesIconPainter(),
              ),
              onTap: () {
                if (provider.gameMode != GameMode.adventure || provider.movesRemaining == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                      content: Text('Disponible dans les niveaux du mode Aventure !'),
                    ),
                  );
                  return;
                }

                if (provider.extraMovesCount > 0) {
                  provider.useExtraMoves(5);
                } else {
                  _showBuyBoosterDialog(
                    context,
                    provider,
                    type: 'extra_moves',
                    title: '+5 Coups Extra ➕🖐️',
                    description: 'Ajoute 5 coups supplémentaires pour continuer et réussir le niveau !',
                    cost: 60,
                    iconWidget: const CustomPaint(
                      size: Size(44, 44),
                      painter: ExtraMovesIconPainter(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BoosterButton extends StatelessWidget {
  final String title;
  final int count;
  final bool isActive;
  final Widget icon;
  final VoidCallback onTap;

  const _BoosterButton({
    Key? key,
    required this.title,
    required this.count,
    required this.isActive,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Bouton circulaire 3D doré
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.25, -0.35),
                    radius: 0.85,
                    colors: [
                      Color(0xFFFFFBF0),
                      Color(0xFFFFE6B3),
                      Color(0xFFFFCA66),
                    ],
                    stops: [0.0, 0.65, 1.0],
                  ),
                  border: Border.all(
                    color: isActive ? const Color(0xFFFF4081) : CandyColors.boardBorder,
                    width: isActive ? 3.0 : 2.0,
                  ),
                  boxShadow: isActive
                      ? [
                          const BoxShadow(
                            color: Color(0xFFFF4081),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                          const BoxShadow(
                            color: Color(0xFFFFD54F),
                            blurRadius: 6,
                          ),
                        ]
                      : const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                          BoxShadow(
                            color: Color(0x80FFFFFF),
                            blurRadius: 2,
                            offset: Offset(0, -1),
                          ),
                        ],
                ),
                child: Center(child: icon),
              ),

              // Pastille de quantité ou icône +
              Positioned(
                bottom: -2,
                right: -4,
                child: count > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF48BB78), Color(0xFF2E7D32)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFA726), Color(0xFFF57C00)],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.add, size: 12, color: Colors.white),
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: isActive ? const Color(0xFFFF4081) : const Color(0xFF6B3600),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// VECTOR PAINTERS POUR LES 4 BOOSTERS SIGNATURES (SUGAR DELIGHT 3D GLOSS)
// ============================================================================

/// Dessin vectoriel du Marteau Sucré (Manche doré + Sucette tourbillon)
class HammerIconPainter extends CustomPainter {
  const HammerIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Manche incliné en sucre d'orge
    final handlePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFCC80), Color(0xFFD48810)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..strokeWidth = w * 0.14
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.22, h * 0.82),
      Offset(w * 0.65, h * 0.38),
      handlePaint,
    );

    // 2. Tête de marteau en sucette tourbillon bicolore
    final headCenter = Offset(w * 0.64, h * 0.34);
    final headRadius = w * 0.28;

    final discPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        colors: [Color(0xFFFF80AB), Color(0xFFF50057), Color(0xFFC51162)],
      ).createShader(Rect.fromCircle(center: headCenter, radius: headRadius));

    canvas.drawCircle(headCenter, headRadius, discPaint);

    // Spirale de sucre blanc/menthe
    final swirlPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;

    final swirlPath = Path();
    for (double a = 0; a < math.pi * 3.5; a += 0.2) {
      final r = (a / (math.pi * 3.5)) * headRadius * 0.78;
      final px = headCenter.dx + r * math.cos(a);
      final py = headCenter.dy + r * math.sin(a);
      if (a == 0) {
        swirlPath.moveTo(px, py);
      } else {
        swirlPath.lineTo(px, py);
      }
    }
    canvas.drawPath(swirlPath, swirlPaint);

    // Éclat brillant spéculaire
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headCenter.dx - headRadius * 0.35, headCenter.dy - headRadius * 0.35),
        width: headRadius * 0.5,
        height: headRadius * 0.3,
      ),
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dessin vectoriel de la Bombe Soda (Sphère glossy rubis/pourpre + mèche allumée)
class BombIconPainter extends CustomPainter {
  const BombIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sphereCenter = Offset(w * 0.48, h * 0.58);
    final sphereRadius = w * 0.34;

    // 1. Corps de la bombe (Sphère glossy)
    final bombPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.35, -0.4),
        radius: 0.9,
        colors: [
          Color(0xFFFF5252),
          Color(0xFFD50000),
          Color(0xFF4A0072),
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: sphereCenter, radius: sphereRadius));

    canvas.drawCircle(sphereCenter, sphereRadius, bombPaint);

    // Reflet spéculaire doux
    final specularPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(sphereCenter.dx - sphereRadius * 0.32, sphereCenter.dy - sphereRadius * 0.35),
        width: sphereRadius * 0.5,
        height: sphereRadius * 0.28,
      ),
      specularPaint,
    );

    // 2. Collet doré et mèche
    final neckPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(sphereCenter.dx, sphereCenter.dy - sphereRadius * 0.95),
          width: w * 0.2,
          height: h * 0.1,
        ),
        const Radius.circular(3),
      ),
      neckPaint,
    );

    // Mèche incurvée
    final fusePaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;

    final fusePath = Path();
    fusePath.moveTo(sphereCenter.dx, sphereCenter.dy - sphereRadius * 1.05);
    fusePath.quadraticBezierTo(
      w * 0.65,
      h * 0.18,
      w * 0.76,
      h * 0.14,
    );
    canvas.drawPath(fusePath, fusePaint);

    // Étincelle brillante
    final sparkCenter = Offset(w * 0.76, h * 0.14);
    final sparkPaint = Paint()..color = const Color(0xFFFFEB3B);
    canvas.drawCircle(sparkCenter, w * 0.1, sparkPaint);
    final innerSparkPaint = Paint()..color = Colors.white;
    canvas.drawCircle(sparkCenter, w * 0.05, innerSparkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dessin vectoriel du Gant Magique (Gant de chef pâtissier + étoiles magiques)
class GloveIconPainter extends CustomPainter {
  const GloveIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Forme du gant
    final glovePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFE1F5FE),
          Color(0xFFB3E5FC),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final gloveBorderPaint = Paint()
      ..color = const Color(0xFF0288D1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final path = Path();
    path.moveTo(w * 0.32, h * 0.88);
    path.lineTo(w * 0.32, h * 0.52);
    // Pouce
    path.quadraticBezierTo(w * 0.14, h * 0.48, w * 0.18, h * 0.35);
    path.quadraticBezierTo(w * 0.28, h * 0.32, w * 0.42, h * 0.42);
    // Doigts
    path.lineTo(w * 0.44, h * 0.22);
    path.quadraticBezierTo(w * 0.58, h * 0.12, w * 0.72, h * 0.22);
    path.lineTo(w * 0.72, h * 0.88);
    path.close();

    canvas.drawPath(path, glovePaint);
    canvas.drawPath(path, gloveBorderPaint);

    // Manchette du gant
    final cuffPaint = Paint()
      ..color = const Color(0xFF03A9F4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.26, h * 0.84, w * 0.52, h * 0.12),
        const Radius.circular(3),
      ),
      cuffPaint,
    );

    // Étoile magique brillante
    final starPaint = Paint()..color = const Color(0xFFFFD700);
    _drawStar(canvas, Offset(w * 0.78, h * 0.32), w * 0.12, starPaint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final double outerAngle = i * (2 * math.pi / 5) - math.pi / 2;
      final double innerAngle = outerAngle + math.pi / 5;
      final double ox = center.dx + radius * math.cos(outerAngle);
      final double oy = center.dy + radius * math.sin(outerAngle);
      final double ix = center.dx + (radius * 0.45) * math.cos(innerAngle);
      final double iy = center.dy + (radius * 0.45) * math.sin(innerAngle);
      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dessin vectoriel du Booster +5 Coups
class ExtraMovesIconPainter extends CustomPainter {
  const ExtraMovesIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.42;

    // Disque doré
    final discPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.3),
        colors: [
          Color(0xFFFFF176),
          Color(0xFFFFB300),
          Color(0xFFF57F17),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, discPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFFFF9C4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius - 1, borderPaint);

    // Dessin du texte "+5"
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '+5',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              color: Color(0x805D4037),
              offset: Offset(1, 1.5),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
