import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Enumération des types de confiseries inspirées de Sugar Delight
enum CandyType {
  heart,      // 1: Cœur Fraise Rubis
  star,       // 2: Étoile Citron Dorée
  drop,       // 3: Goutte Pomme Verte
  bonbon,     // 4: Coussin Violet Myrtille
  ring,       // 5: Anneau Cyan Glacé
  orange,     // 6: Quartier d'Orange
  pink,       // 7: Bonbon Framboise Guimauve
  gummyBear,  // Spécial Joyau / Gemme (Gélifié Doré)
  waferChoco, // Spécial Obstacle (Gaufrette & Rosace Chocolat)
}

/// Helper pour mapper l'index de couleur de pièce vers un type de bonbon
CandyType getCandyTypeFromIndex(int index) {
  if (index == 2) return CandyType.gummyBear;
  if (index == -1) return CandyType.waferChoco;
  final safeIdx = (index - 1).abs() % 7;
  switch (safeIdx) {
    case 0:
      return CandyType.heart;
    case 1:
      return CandyType.star;
    case 2:
      return CandyType.drop;
    case 3:
      return CandyType.bonbon;
    case 4:
      return CandyType.ring;
    case 5:
      return CandyType.orange;
    case 6:
    default:
      return CandyType.pink;
  }
}

/// Widget affichant un bonbon ou obstacle ultra-net et glossy à n'importe quelle taille
class CandyWidget extends StatelessWidget {
  final CandyType type;
  final double size;
  final bool showGlow;
  final bool isGhost;
  final bool isGhostValid;

  const CandyWidget({
    Key? key,
    required this.type,
    required this.size,
    this.showGlow = false,
    this.isGhost = false,
    this.isGhostValid = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CandyCustomPainter(
        type: type,
        showGlow: showGlow,
        isGhost: isGhost,
        isGhostValid: isGhostValid,
      ),
    );
  }
}

class _CandyCustomPainter extends CustomPainter {
  final CandyType type;
  final bool showGlow;
  final bool isGhost;
  final bool isGhostValid;

  _CandyCustomPainter({
    required this.type,
    required this.showGlow,
    required this.isGhost,
    required this.isGhostValid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    if (isGhost) {
      _paintGhost(canvas, size);
      return;
    }

    switch (type) {
      case CandyType.heart:
        _paintHeart(canvas, size);
        break;
      case CandyType.star:
        _paintStar(canvas, size);
        break;
      case CandyType.drop:
        _paintDrop(canvas, size);
        break;
      case CandyType.bonbon:
        _paintBonbon(canvas, size);
        break;
      case CandyType.ring:
        _paintRing(canvas, size);
        break;
      case CandyType.orange:
        _paintOrange(canvas, size);
        break;
      case CandyType.pink:
        _paintPink(canvas, size);
        break;
      case CandyType.gummyBear:
        _paintGummyBear(canvas, size);
        break;
      case CandyType.waferChoco:
        _paintWaferChoco(canvas, size);
        break;
    }
  }

  void _paintGhost(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      Radius.circular(size.width * 0.22),
    );
    final fillPaint = Paint()
      ..color = isGhostValid ? CandyColors.ghostValid : CandyColors.ghostInvalid
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = isGhostValid ? const Color(0xFF00E5FF) : const Color(0xFFFF1744)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(rect, fillPaint);
    canvas.drawRRect(rect, strokePaint);
  }

  // 1. Cœur Rubis Fraise
  void _paintHeart(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ombre portée 3D sous le bonbon
    final shadowPath = _createHeartPath(w * 0.5, h * 0.52, w * 0.44, h * 0.44);
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = const Color(0x667F0024)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    // Corps principal du cœur
    final heartPath = _createHeartPath(w * 0.5, h * 0.48, w * 0.43, h * 0.43);
    final baseGradient = RadialGradient(
      center: const Alignment(-0.25, -0.3),
      radius: 0.85,
      colors: const [
        Color(0xFFFF5277),
        CandyColors.rubyHeart,
        Color(0xFFB80036),
      ],
      stops: const [0.0, 0.55, 1.0],
    );
    canvas.drawPath(
      heartPath,
      Paint()..shader = baseGradient.createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Bordure bonbon biseautée
    canvas.drawPath(
      heartPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0x88FFFFFF),
    );

    // Reflet blanc zénithal (Glossy shine)
    final shinePath = Path()
      ..moveTo(w * 0.32, h * 0.26)
      ..quadraticBezierTo(w * 0.42, h * 0.22, w * 0.47, h * 0.30)
      ..quadraticBezierTo(w * 0.40, h * 0.36, w * 0.30, h * 0.38)
      ..close();
    canvas.drawPath(
      shinePath,
      Paint()..color = const Color(0xBBFFFFFF),
    );
  }

  Path _createHeartPath(double cx, double cy, double rx, double ry) {
    final path = Path();
    path.moveTo(cx, cy + ry * 0.75);
    path.cubicTo(
      cx - rx * 1.1, cy + ry * 0.2,
      cx - rx * 1.0, cy - ry * 0.7,
      cx, cy - ry * 0.2,
    );
    path.cubicTo(
      cx + rx * 1.0, cy - ry * 0.7,
      cx + rx * 1.1, cy + ry * 0.2,
      cx, cy + ry * 0.75,
    );
    path.close();
    return path;
  }

  // 2. Étoile Citron Dorée
  void _paintStar(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.5;
    final outerR = w * 0.44;
    final innerR = w * 0.22;

    // Ombre 3D
    final shadowPath = _createStarPath(cx, cy + 2.0, outerR, innerR, 5);
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = const Color(0x55B45309)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
    );

    // Étoile principale
    final starPath = _createStarPath(cx, cy, outerR, innerR, 5);
    final gradient = RadialGradient(
      center: const Alignment(-0.2, -0.25),
      radius: 0.9,
      colors: const [
        Color(0xFFFFF275),
        CandyColors.lemonStar,
        Color(0xFFD97706),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
    canvas.drawPath(
      starPath,
      Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Contour doré sucré
    canvas.drawPath(
      starPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0x99FFFFFF),
    );

    // Point de brillance centrale
    canvas.drawCircle(
      Offset(cx - outerR * 0.22, cy - outerR * 0.22),
      outerR * 0.24,
      Paint()..color = const Color(0xAAFFFFFF),
    );
  }

  Path _createStarPath(double cx, double cy, double outerRadius, double innerRadius, int points) {
    final path = Path();
    final step = math.pi / points;
    double angle = -math.pi / 2;

    for (int i = 0; i < points * 2; i++) {
      final r = (i % 2 == 0) ? outerRadius : innerRadius;
      final x = cx + math.cos(angle) * r;
      final y = cy + math.sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      angle += step;
    }
    path.close();
    return path;
  }

  // 3. Goutte Pomme Verte
  void _paintDrop(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    // Ombre
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.62), width: w * 0.76, height: h * 0.72),
      Paint()
        ..color = const Color(0x44064E3B)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
    );

    // Forme de goutte
    final path = Path()
      ..moveTo(cx, h * 0.12)
      ..cubicTo(cx + w * 0.42, h * 0.42, cx + w * 0.40, h * 0.88, cx, h * 0.88)
      ..cubicTo(cx - w * 0.40, h * 0.88, cx - w * 0.42, h * 0.42, cx, h * 0.12)
      ..close();

    final gradient = RadialGradient(
      center: const Alignment(-0.25, -0.35),
      radius: 0.85,
      colors: const [
        Color(0xFF6EE7B7),
        CandyColors.limeDrop,
        Color(0xFF047857),
      ],
      stops: const [0.0, 0.55, 1.0],
    );
    canvas.drawPath(path, Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h)));

    // Biseau
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0x88FFFFFF),
    );

    // Reflet zénithal
    final shine = Path()
      ..moveTo(cx - w * 0.15, h * 0.32)
      ..quadraticBezierTo(cx - w * 0.05, h * 0.22, cx + w * 0.02, h * 0.32)
      ..quadraticBezierTo(cx - w * 0.08, h * 0.45, cx - w * 0.15, h * 0.32)
      ..close();
    canvas.drawPath(shine, Paint()..color = const Color(0xCCFFFFFF));
  }

  // 4. Coussin Bonbon Violet
  void _paintBonbon(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ombre
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.52), width: w * 0.84, height: h * 0.80),
      Radius.circular(w * 0.28),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = const Color(0x444C1D95)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
    );

    // Corps bombé
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.48), width: w * 0.82, height: h * 0.78),
      Radius.circular(w * 0.26),
    );
    final gradient = RadialGradient(
      center: const Alignment(-0.25, -0.25),
      radius: 0.9,
      colors: const [
        Color(0xFFD8B4FE),
        CandyColors.plumBonbon,
        Color(0xFF6B21A8),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    canvas.drawRRect(bodyRect, Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h)));

    // Rainures décoratives de torsion
    final linePaint = Paint()
      ..color = const Color(0x55FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawLine(Offset(w * 0.32, h * 0.26), Offset(w * 0.68, h * 0.70), linePaint);
    canvas.drawLine(Offset(w * 0.68, h * 0.26), Offset(w * 0.32, h * 0.70), linePaint);

    // Reflet
    canvas.drawOval(
      Rect.fromLTWH(w * 0.24, h * 0.20, w * 0.35, h * 0.18),
      Paint()..color = const Color(0xBBFFFFFF),
    );
  }

  // 5. Anneau Cyan Glacé (Donut / Lifesaver)
  void _paintRing(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.5;
    final outerR = w * 0.42;
    final innerR = w * 0.16;

    // Ombre
    canvas.drawCircle(
      Offset(cx, cy + 2.0),
      outerR,
      Paint()
        ..color = const Color(0x440284C7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
    );

    // Anneau extérieur
    final outerPath = Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: outerR));
    final innerPath = Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: innerR));
    final ringPath = Path.combine(PathOperation.difference, outerPath, innerPath);

    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 0.85,
      colors: const [
        Color(0xFF7DD3FC),
        CandyColors.aquaRing,
        Color(0xFF0369A1),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    canvas.drawPath(ringPath, Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h)));

    // Biseau
    canvas.drawPath(
      ringPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0x99FFFFFF),
    );

    // Reflet en arc
    final arcRect = Rect.fromCircle(center: Offset(cx, cy), radius: outerR * 0.72);
    canvas.drawArc(
      arcRect,
      math.pi * 1.1,
      math.pi * 0.5,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xDDFFFFFF),
    );
  }

  // 6. Quartier d'Orange Tangerine
  void _paintOrange(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.5;
    final r = w * 0.42;

    // Ombre
    canvas.drawCircle(
      Offset(cx, cy + 2.0),
      r,
      Paint()
        ..color = const Color(0x449A3412)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
    );

    // Cercle
    final circleRect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final gradient = RadialGradient(
      center: const Alignment(-0.25, -0.25),
      radius: 0.85,
      colors: const [
        Color(0xFFFED7AA),
        CandyColors.orangeTangerine,
        Color(0xFFC2410C),
      ],
      stops: const [0.0, 0.55, 1.0],
    );
    canvas.drawCircle(Offset(cx, cy), r, Paint()..shader = gradient.createShader(circleRect));

    // Décoration quartier d'agrumes
    final segmentPaint = Paint()
      ..color = const Color(0x55FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (int i = 0; i < 6; i++) {
      final angle = i * (math.pi / 3);
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + math.cos(angle) * r * 0.75, cy + math.sin(angle) * r * 0.75),
        segmentPaint,
      );
    }

    // Reflet
    canvas.drawOval(
      Rect.fromLTWH(w * 0.22, h * 0.18, w * 0.36, h * 0.22),
      Paint()..color = const Color(0xAAFFFFFF),
    );
  }

  // 7. Bonbon Framboise Guimauve
  void _paintPink(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.5;
    final r = w * 0.42;

    // Ombre
    canvas.drawCircle(
      Offset(cx, cy + 2.0),
      r,
      Paint()
        ..color = const Color(0x44831843)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
    );

    // Dôme sucré
    final gradient = RadialGradient(
      center: const Alignment(-0.25, -0.3),
      radius: 0.85,
      colors: const [
        Color(0xFFFBCFE8),
        CandyColors.berryPink,
        Color(0xFF9D174D),
      ],
      stops: const [0.0, 0.55, 1.0],
    );
    canvas.drawCircle(Offset(cx, cy), r, Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h)));

    // Contour translucide
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0x99FFFFFF),
    );

    // Étoile de brillance
    _paintSparkleStar(canvas, Offset(cx - r * 0.3, cy - r * 0.3), r * 0.35, const Color(0xEEFFFFFF));
  }

  // 8. Ours Gélifié Doré (Gummy Bear - Joyau Target)
  void _paintGummyBear(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.5;

    // Ombre 3D
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.56), width: w * 0.78, height: h * 0.84),
      Paint()
        ..color = const Color(0x55B45309)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    final bearGradient = RadialGradient(
      center: const Alignment(-0.2, -0.3),
      radius: 0.85,
      colors: const [
        Color(0xFFFFF066),
        CandyColors.gummyBearGold,
        Color(0xFFD97706),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    final bearPaint = Paint()..shader = bearGradient.createShader(Rect.fromLTWH(0, 0, w, h));

    // Oreilles rondes
    canvas.drawCircle(Offset(cx - w * 0.28, cy - h * 0.28), w * 0.16, bearPaint);
    canvas.drawCircle(Offset(cx + w * 0.28, cy - h * 0.28), w * 0.16, bearPaint);

    // Tête
    canvas.drawCircle(Offset(cx, cy - h * 0.14), w * 0.28, bearPaint);

    // Corps / Ventre bombé
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + h * 0.16), width: w * 0.62, height: h * 0.52),
      bearPaint,
    );

    // Pattes
    canvas.drawCircle(Offset(cx - w * 0.22, cy + h * 0.36), w * 0.14, bearPaint);
    canvas.drawCircle(Offset(cx + w * 0.22, cy + h * 0.36), w * 0.14, bearPaint);

    // Museau mignon
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - h * 0.10), width: w * 0.18, height: h * 0.14),
      Paint()..color = const Color(0x66FFFFFF),
    );

    // Yeux & Nez
    final eyePaint = Paint()..color = const Color(0xFF78350F);
    canvas.drawCircle(Offset(cx - w * 0.10, cy - h * 0.16), w * 0.04, eyePaint);
    canvas.drawCircle(Offset(cx + w * 0.10, cy - h * 0.16), w * 0.04, eyePaint);
    canvas.drawCircle(Offset(cx, cy - h * 0.11), w * 0.045, eyePaint);

    // Reflet étincelant
    _paintSparkleStar(canvas, Offset(cx - w * 0.20, cy - h * 0.12), w * 0.24, Colors.white);
  }

  // 9. Gaufrette Chocolat & Crème (Obstacle Biscuit)
  void _paintWaferChoco(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Biscuit doré à la base
    final biscuitRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, w - 2, h - 2),
      Radius.circular(w * 0.18),
    );
    final biscuitGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [
        Color(0xFFFDE68A),
        CandyColors.waferBiscuitBase,
        CandyColors.waferBiscuitDark,
      ],
      stops: const [0.0, 0.45, 1.0],
    );
    canvas.drawRRect(biscuitRect, Paint()..shader = biscuitGradient.createShader(Rect.fromLTWH(0, 0, w, h)));

    // Dentelure de gaufre sur les bords
    final dentPaint = Paint()
      ..color = const Color(0x4478350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(biscuitRect, dentPaint);

    // Rosace de glaçage au chocolat centrale
    final chocoCenter = Offset(w * 0.5, h * 0.5);
    final chocoRadius = w * 0.32;
    final chocoGradient = RadialGradient(
      center: const Alignment(-0.25, -0.3),
      radius: 0.8,
      colors: const [
        Color(0xFF8B4513),
        CandyColors.chocolateIcing,
        Color(0xFF2C1306),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
    canvas.drawCircle(
      chocoCenter,
      chocoRadius,
      Paint()..shader = chocoGradient.createShader(Rect.fromCircle(center: chocoCenter, radius: chocoRadius)),
    );

    // Tourbillon de chantilly blanche sur le dessus
    canvas.drawCircle(
      chocoCenter + const Offset(-1.5, -1.5),
      chocoRadius * 0.42,
      Paint()..color = CandyColors.creamWhipped,
    );
    canvas.drawCircle(
      chocoCenter + const Offset(-1.5, -1.5),
      chocoRadius * 0.22,
      Paint()..color = Colors.white,
    );
  }

  void _paintSparkleStar(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CandyCustomPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.showGlow != showGlow ||
        oldDelegate.isGhost != isGhost ||
        oldDelegate.isGhostValid != isGhostValid;
  }
}

/// Widget Mascotte Pastry Girl pour le cameo de l'en-tête (Sugar Delight Style)
class MascotCameo extends StatelessWidget {
  final double size;
  final bool isCheering;
  final bool isAlert;

  const MascotCameo({
    Key? key,
    this.size = 54.0,
    this.isCheering = false,
    this.isAlert = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFFF275), Color(0xFFFFB300)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2.2),
      ),
      padding: const EdgeInsets.all(2.5),
      child: ClipOval(
        child: Container(
          color: const Color(0xFFC7E8FD),
          child: Center(
            child: Text(
              isCheering ? '🥳' : (isAlert ? '😮' : '👩‍🍳'),
              style: TextStyle(
                fontSize: size * 0.52,
                shadows: const [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Étoile dorée 3D avec biseau et brillance pour la jauge de progression
class StarBadge extends StatelessWidget {
  final bool isEarned;
  final double size;

  const StarBadge({
    Key? key,
    required this.isEarned,
    this.size = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      scale: isEarned ? 1.15 : 0.9,
      child: CustomPaint(
        size: Size(size, size),
        painter: _StarBadgePainter(isEarned: isEarned),
      ),
    );
  }
}

class _StarBadgePainter extends CustomPainter {
  final bool isEarned;

  _StarBadgePainter({required this.isEarned});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final outerR = size.width * 0.48;
    final innerR = size.width * 0.23;

    final path = Path();
    const points = 5;
    const step = math.pi / points;
    double angle = -math.pi / 2;

    for (int i = 0; i < points * 2; i++) {
      final r = (i % 2 == 0) ? outerR : innerR;
      final x = cx + math.cos(angle) * r;
      final y = cy + math.sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      angle += step;
    }
    path.close();

    if (isEarned) {
      // Étoile dorée brillante
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0x66FFB300)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
      );
      final gradient = RadialGradient(
        center: const Alignment(-0.25, -0.3),
        radius: 0.85,
        colors: const [
          Color(0xFFFFF7A1),
          Color(0xFFFFC107),
          Color(0xFFE65100),
        ],
        stops: const [0.0, 0.55, 1.0],
      );
      canvas.drawPath(path, Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = Colors.white,
      );
    } else {
      // Étoile non acquise (translucide argentée/bleutée)
      canvas.drawPath(
        path,
        Paint()..color = const Color(0x331E3A8A),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = const Color(0x6693C5FD),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarBadgePainter oldDelegate) => oldDelegate.isEarned != isEarned;
}
