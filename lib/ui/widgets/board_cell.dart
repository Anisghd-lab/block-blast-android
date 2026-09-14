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
          color: Colors.white,
          borderRadius: BorderRadius.circular(theme.cellBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: 12,
              spreadRadius: 3,
            ),
          ],
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

    // 3. Case occupée par un bloc coloré
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
            // Reflet supérieur poli (Glossy Acrylic highlight)
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

    // 4. Case vide (Puits encastré tactile)
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
