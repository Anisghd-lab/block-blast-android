import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum ParticleShape {
  star,
  sugarCrystal,
  candyDisc,
  sparkle,
}

class JuiceParticle {
  double x;
  double y;
  double vx;
  double vy;
  double gravity;
  double drag;
  double rotation;
  double vRot;
  double size;
  Color color;
  ParticleShape shape;
  double life; // 1.0 -> 0.0
  double maxLife;

  JuiceParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    this.gravity = 350.0,
    this.drag = 0.96,
    this.rotation = 0.0,
    required this.vRot,
    required this.size,
    required this.color,
    required this.shape,
    required this.life,
  }) : maxLife = life;

  bool update(double dt) {
    life -= dt;
    if (life <= 0) return false;

    x += vx * dt;
    y += vy * dt;
    vy += gravity * dt;
    vx *= drag;
    rotation += vRot * dt;
    return true;
  }
}

class ShockwaveRing {
  final double cx;
  final double cy;
  final double maxRadius;
  final Color color;
  double progress; // 0.0 -> 1.0
  final double duration; // seconds

  ShockwaveRing({
    required this.cx,
    required this.cy,
    required this.maxRadius,
    required this.color,
    this.progress = 0.0,
    this.duration = 0.45,
  });

  bool update(double dt) {
    progress += dt / duration;
    return progress < 1.0;
  }
}

class FloatingJuiceText {
  final String text;
  double x;
  double y;
  final Color color;
  final double initialScale;
  final double targetScale;
  final double angle;
  double progress; // 0.0 -> 1.0
  final double duration;

  FloatingJuiceText({
    required this.text,
    required this.x,
    required this.y,
    required this.color,
    this.initialScale = 0.4,
    this.targetScale = 1.25,
    required this.angle,
    this.progress = 0.0,
    this.duration = 0.85,
  });

  bool update(double dt) {
    progress += dt / duration;
    y -= 45.0 * dt; // Monte doucement
    return progress < 1.0;
  }
}

/// Overlay complet gérant l'émission et le rendu 60-120 FPS de tous les effets "Juice"
class JuiceOverlay extends StatefulWidget {
  final Widget child;

  const JuiceOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  static JuiceOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<JuiceOverlayState>();
  }

  @override
  State<JuiceOverlay> createState() => JuiceOverlayState();
}

class JuiceOverlayState extends State<JuiceOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  DateTime _lastTime = DateTime.now();

  final List<JuiceParticle> _particles = [];
  final List<ShockwaveRing> _shockwaves = [];
  final List<FloatingJuiceText> _floatingTexts = [];
  final math.Random _rng = math.Random();

  // Screen shake
  double _shakeProgress = 1.0;
  double _shakeMagnitude = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_onTick);
  }

  void _onTick() {
    final now = DateTime.now();
    final dt = (now.difference(_lastTime).inMicroseconds / 1000000.0).clamp(0.001, 0.05);
    _lastTime = now;

    bool hasActive = false;

    // Mise à jour des particules
    _particles.removeWhere((p) => !p.update(dt));
    if (_particles.isNotEmpty) hasActive = true;

    // Mise à jour des ondes de choc
    _shockwaves.removeWhere((s) => !s.update(dt));
    if (_shockwaves.isNotEmpty) hasActive = true;

    // Mise à jour des textes flottants
    _floatingTexts.removeWhere((t) => !t.update(dt));
    if (_floatingTexts.isNotEmpty) hasActive = true;

    // Mise à jour du tremblement d'écran
    if (_shakeProgress < 1.0) {
      _shakeProgress += dt / 0.22;
      if (_shakeProgress > 1.0) _shakeProgress = 1.0;
      hasActive = true;
    }

    if (hasActive) {
      setState(() {});
    } else {
      _ticker.stop();
    }
  }

  void _ensureTicking() {
    if (!_ticker.isAnimating) {
      _lastTime = DateTime.now();
      _ticker.repeat();
    }
  }

  /// Déclenche un tremblement d'écran physique (Juice Impact)
  void triggerScreenShake({double magnitude = 4.5}) {
    _shakeProgress = 0.0;
    _shakeMagnitude = magnitude;
    _ensureTicking();
  }

  /// Émet une explosion de sucre et étoiles sur des coordonnées spécifiques du plateau
  void emitBurst({
    required Offset position,
    required List<Color> colors,
    int particleCount = 20,
    bool emitShockwave = true,
  }) {
    for (int i = 0; i < particleCount; i++) {
      final angle = _rng.nextDouble() * 2 * math.pi;
      final speed = 120.0 + _rng.nextDouble() * 280.0;
      final color = colors[_rng.nextInt(colors.length)];
      final shapeIndex = _rng.nextInt(4);
      final shape = ParticleShape.values[shapeIndex];

      _particles.add(
        JuiceParticle(
          x: position.dx,
          y: position.dy,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed - 60.0, // Impulsion légèrement ascendante
          gravity: 400.0,
          drag: 0.94,
          vRot: (_rng.nextDouble() - 0.5) * 12.0,
          size: 4.5 + _rng.nextDouble() * 6.5,
          color: color,
          shape: shape,
          life: 0.45 + _rng.nextDouble() * 0.35,
        ),
      );
    }

    if (emitShockwave) {
      _shockwaves.add(
        ShockwaveRing(
          cx: position.dx,
          cy: position.dy,
          maxRadius: 75.0,
          color: colors.isNotEmpty ? colors.first : CandyColors.starGold,
        ),
      );
    }

    _ensureTicking();
  }

  /// Affiche un texte flottant rebondissant ("SUCRÉ !", "+250", etc.)
  void spawnFloatingText({
    required Offset position,
    required String text,
    Color color = CandyColors.starGold,
  }) {
    final angle = (_rng.nextDouble() - 0.5) * 0.18; // Léger tilt aléatoire
    _floatingTexts.add(
      FloatingJuiceText(
        text: text,
        x: position.dx,
        y: position.dy - 10.0,
        color: color,
        angle: angle,
      ),
    );
    _ensureTicking();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calcul de l'offset de tremblement
    double shakeDx = 0.0;
    double shakeDy = 0.0;
    if (_shakeProgress < 1.0) {
      final decay = (1.0 - _shakeProgress);
      final freq = _shakeProgress * math.pi * 10;
      shakeDx = math.sin(freq) * _shakeMagnitude * decay;
      shakeDy = math.cos(freq * 0.8) * (_shakeMagnitude * 0.6) * decay;
    }

    return Transform.translate(
      offset: Offset(shakeDx, shakeDy),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          // Couche CustomPaint des effets physiques (isolée pour 60-120 FPS)
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _JuicePainter(
                    particles: _particles,
                    shockwaves: _shockwaves,
                    floatingTexts: _floatingTexts,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JuicePainter extends CustomPainter {
  final List<JuiceParticle> particles;
  final List<ShockwaveRing> shockwaves;
  final List<FloatingJuiceText> floatingTexts;

  _JuicePainter({
    required this.particles,
    required this.shockwaves,
    required this.floatingTexts,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dessin des ondes de choc concentriques
    for (final s in shockwaves) {
      final alpha = (1.0 - s.progress).clamp(0.0, 1.0);
      final radius = s.maxRadius * Curves.easeOutCubic.transform(s.progress);
      final strokeW = (4.0 * (1.0 - s.progress)).clamp(1.0, 4.0);

      final paint = Paint()
        ..color = s.color.withOpacity(alpha * 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

      canvas.drawCircle(Offset(s.cx, s.cy), radius, paint);
    }

    // 2. Dessin des particules de bonbon & sucre
    for (final p in particles) {
      final normLife = (p.life / p.maxLife).clamp(0.0, 1.0);
      final alpha = (normLife).clamp(0.0, 1.0);
      final currentSize = p.size * (0.4 + 0.6 * normLife);

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      final paint = Paint()
        ..color = p.color.withOpacity(alpha)
        ..style = PaintingStyle.fill;

      switch (p.shape) {
        case ParticleShape.star:
        case ParticleShape.sparkle:
          _paintSparkle(canvas, currentSize, paint);
          break;
        case ParticleShape.sugarCrystal:
          _paintCrystal(canvas, currentSize, paint);
          break;
        case ParticleShape.candyDisc:
          canvas.drawCircle(Offset.zero, currentSize * 0.5, paint);
          // Petit reflet blanc sur le disque
          canvas.drawCircle(
            Offset(-currentSize * 0.15, -currentSize * 0.15),
            currentSize * 0.18,
            Paint()..color = Colors.white.withOpacity(alpha * 0.8),
          );
          break;
      }
      canvas.restore();
    }

    // 3. Dessin des textes flottants rebondissants
    for (final t in floatingTexts) {
      final p = t.progress;
      double scale = 1.0;
      if (p < 0.25) {
        scale = t.initialScale + (t.targetScale - t.initialScale) * Curves.easeOutBack.transform(p / 0.25);
      } else {
        scale = t.targetScale - (t.targetScale - 1.0) * ((p - 0.25) / 0.75);
      }
      final alpha = (1.0 - math.pow(p, 2.5)).clamp(0.0, 1.0);

      final textSpan = TextSpan(
        text: t.text,
        style: TextStyle(
          fontFamily: 'Rubik',
          fontSize: 22.0,
          fontWeight: FontWeight.w900,
          color: Colors.white.withOpacity(alpha),
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(alpha * 0.75),
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
            Shadow(
              color: t.color.withOpacity(alpha * 0.85),
              offset: Offset.zero,
              blurRadius: 12,
            ),
          ],
        ),
      );

      final tp = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      canvas.save();
      canvas.translate(t.x, t.y);
      canvas.rotate(t.angle);
      canvas.scale(scale);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  void _paintSparkle(Canvas canvas, double size, Paint paint) {
    final r = size * 0.75;
    final path = Path()
      ..moveTo(0, -r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..quadraticBezierTo(0, 0, 0, r)
      ..quadraticBezierTo(0, 0, -r, 0)
      ..quadraticBezierTo(0, 0, 0, -r)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _paintCrystal(Canvas canvas, double size, Paint paint) {
    final w = size * 0.55;
    final h = size * 0.75;
    final path = Path()
      ..moveTo(0, -h)
      ..lineTo(w, 0)
      ..lineTo(0, h)
      ..lineTo(-w, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _JuicePainter oldDelegate) => true;
}
