import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ComboBanner extends StatefulWidget {
  final int comboStreak;

  const ComboBanner({Key? key, required this.comboStreak}) : super(key: key);

  @override
  State<ComboBanner> createState() => _ComboBannerState();
}

class _ComboBannerState extends State<ComboBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  int _lastStreak = 0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    if (widget.comboStreak >= 2) {
      _anim.forward();
    }
    _lastStreak = widget.comboStreak;
  }

  @override
  void didUpdateWidget(covariant ComboBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.comboStreak != oldWidget.comboStreak) {
      if (widget.comboStreak >= 2) {
        _anim.reset();
        _anim.forward();
      } else {
        _anim.reverse();
      }
      _lastStreak = widget.comboStreak;
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  String _getComboTitle(int streak) {
    if (streak == 2) return '🍬 COMBO x2 ! DÉLICIEUX !';
    if (streak == 3) return '🍭 COMBO x3 ! SUCRÉ !';
    if (streak == 4) return '🧁 COMBO x4 ! FÉERIQUE !';
    if (streak == 5) return '👑 COMBO x5 ! SUGAR CRUSH !';
    return '🌟 COMBO x$streak ! DIVIN !';
  }

  List<Color> _getComboGradient(int streak) {
    if (streak <= 2) {
      return const [Color(0xFFFF3366), Color(0xFFFF7A00)];
    } else if (streak == 3) {
      return const [Color(0xFFFF7A00), Color(0xFFFFCC00)];
    } else if (streak == 4) {
      return const [Color(0xFFA855F7), Color(0xFFFF3366), Color(0xFFFFCC00)];
    } else {
      return const [Color(0xFF00E5FF), Color(0xFFA855F7), Color(0xFFFF3366), Color(0xFFFFD700)];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.comboStreak < 2 && _anim.value == 0) {
      return const SizedBox(height: 38);
    }

    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _anim,
        curve: Curves.elasticOut,
      ),
      child: FadeTransition(
        opacity: _anim,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getComboGradient(widget.comboStreak),
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: _getComboGradient(widget.comboStreak).first.withOpacity(0.55),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            _getComboTitle(widget.comboStreak),
            style: const TextStyle(
              fontFamily: 'Rubik',
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14.5,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
