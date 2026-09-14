import 'package:flutter/material.dart';

class ComboBanner extends StatelessWidget {
  final int comboStreak;

  const ComboBanner({Key? key, required this.comboStreak}) : super(key: key);

  String _getComboTitle(int streak) {
    if (streak == 2) return '🔥 COMBO x2! NICE!';
    if (streak == 3) return '⚡ COMBO x3! MEGA BLAST!';
    if (streak == 4) return '💥 COMBO x4! UNSTOPPABLE!';
    if (streak == 5) return '👑 COMBO x5! GODLIKE!';
    return '🌟 COMBO x$streak! LEGENDARY!';
  }

  @override
  Widget build(BuildContext context) {
    if (comboStreak < 2) {
      return const SizedBox(height: 38);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF0844), Color(0xFFFF6A00), Color(0xFFFED929)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6A00).withOpacity(0.5),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getComboTitle(comboStreak),
            style: const TextStyle(
              fontFamily: 'Rubik',
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
