import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/game_theme.dart';

class BoardCell extends StatelessWidget {
  final int colorIndex;
  final bool isGhost;
  final bool isGhostValid;
  final bool isClearing;
  final GameTheme theme;
  final double size;

  const BoardCell({
    Key? key,
    required this.colorIndex,
    this.isGhost = false,
    this.isGhostValid = true,
    this.isClearing = false,
    required this.theme,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. État de destruction en cours (Flash blanc + explosion)
    if (isClearing) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colorIndex == 2
              ? const Color(0xFF00F2FE)
              : (colorIndex == -1 ? const Color(0xFF64748B) : Colors.white),
          borderRadius: BorderRadius.circular(theme.cellBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: 12,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Center(
          child: Text(
            colorIndex == 2 ? '💎' : (colorIndex == -1 ? '🪨' : '✨'),
            style: TextStyle(fontSize: size * 0.45),
          ),
        ),
      );
    }

    // 2. Aperçu fantôme lors du Drag & Drop
    if (isGhost) {
      final ghostColor = isGhostValid
          ? AppColors.gridCellGhostValid
          : AppColors.gridCellGhostInvalid;
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: ghostColor,
          borderRadius: BorderRadius.circular(theme.cellBorderRadius),
          border: Border.all(
            color: isGhostValid
                ? const Color(0xFF00F2FE).withOpacity(0.8)
                : const Color(0xFFFF0844).withOpacity(0.8),
            width: 1.5,
          ),
        ),
      );
    }

    // 3. Case Joyau (Valeur 2)
    if (colorIndex == 2) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            center: Alignment(-0.3, -0.3),
            radius: 0.9,
            colors: [
              Color(0xFF80FFFF),
              Color(0xFF00C6FF),
              Color(0xFF0072FF),
            ],
          ),
          borderRadius: BorderRadius.circular(theme.cellBorderRadius),
          border: Border.all(
            color: Colors.white,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F2FE).withOpacity(0.65),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '💎',
            style: TextStyle(
              fontSize: size * 0.45,
              shadows: const [
                Shadow(
                  color: Colors.black45,
                  offset: Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 4. Case Roche / Obstacle (Valeur -1)
    if (colorIndex == -1) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3F445A),
              Color(0xFF25293A),
              Color(0xFF181B26),
            ],
          ),
          borderRadius: BorderRadius.circular(theme.cellBorderRadius),
          border: Border.all(
            color: const Color(0xFF5A607C),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '🪨',
            style: TextStyle(
              fontSize: size * 0.45,
              shadows: const [
                Shadow(
                  color: Colors.black80,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 5. Case occupée par un bloc normal ou coloré
    if (colorIndex > 0) {
      final baseColor = theme.blockColors[(colorIndex - 1) % theme.blockColors.length];
      final gradient = AppColors.blockGradient(baseColor);

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(theme.cellBorderRadius),
          border: Border.all(
            color: Colors.white.withOpacity(0.35),
            width: 1.0,
          ),
          boxShadow: theme.hasGlow
              ? [
                  BoxShadow(
                    color: baseColor.withOpacity(0.45),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 2,
              left: 3,
              right: 3,
              height: size * 0.35,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.4),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(theme.cellBorderRadius * 0.7),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 6. Case vide
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.cellEmptyColor,
        borderRadius: BorderRadius.circular(theme.cellBorderRadius),
        border: Border.all(
          color: theme.cellBorderColor,
          width: 1.0,
        ),
      ),
    );
  }
}
