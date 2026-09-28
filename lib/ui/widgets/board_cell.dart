import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/game_theme.dart';

class BoardCell extends StatelessWidget {
  final int colorIndex;
  final bool isGhost;
  final bool isGhostValid;
  final bool isClearing;
  /// Lueur subtile : case dans une ligne/colonne à 1 case d'être complète
  final bool isNearComplete;
  final GameTheme theme;
  final double size;

  const BoardCell({
    Key? key,
    required this.colorIndex,
    this.isGhost = false,
    this.isGhostValid = true,
    this.isClearing = false,
    this.isNearComplete = false,
    required this.theme,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. État de destruction en cours (Flash éclatant + particule étoilée)
    if (isClearing) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(theme.cellBorderRadius),
          boxShadow: [
            BoxShadow(
              color: theme.starGold.withValues(alpha: 0.9),
              blurRadius: 14,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Center(
          child: Text(
            colorIndex == 2 ? '💎' : '✨',
            style: TextStyle(fontSize: size * 0.52),
          ),
        ),
      );
    }

    // 2. Aperçu fantôme lors du Drag & Drop
    if (isGhost) {
      final ghostBg = isGhostValid
          ? theme.primaryAccent.withValues(alpha: 0.35)
          : theme.alertColor.withValues(alpha: 0.35);
      final ghostBorder = isGhostValid
          ? theme.primaryAccent.withValues(alpha: 0.8)
          : theme.alertColor.withValues(alpha: 0.8);

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: ghostBg,
          borderRadius: BorderRadius.circular(theme.cellBorderRadius),
          border: Border.all(
            color: ghostBorder,
            width: 1.5,
          ),
        ),
      );
    }

    // 3. Case Joyau / Target (Valeur 2)
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
              color: theme.primaryAccent.withValues(alpha: 0.65),
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.isDark
                ? const [Color(0xFF3F445A), Color(0xFF25293A), Color(0xFF181B26)]
                : const [Color(0xFF94A3B8), Color(0xFF64748B), Color(0xFF475569)],
          ),
          borderRadius: BorderRadius.circular(theme.cellBorderRadius),
          border: Border.all(
            color: theme.isDark ? const Color(0xFF5A607C) : const Color(0xFFCBD5E1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.isDark ? Colors.black45 : Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
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
                  color: Colors.black87,
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
            color: Colors.white.withValues(alpha: 0.35),
            width: 1.0,
          ),
          boxShadow: theme.hasGlow
              ? [
                  BoxShadow(
                    color: baseColor.withValues(alpha: 0.45),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: theme.isDark ? Colors.black26 : const Color(0x1F000000),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
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
                      Colors.white.withValues(alpha: 0.4),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(theme.cellBorderRadius * 0.7),
                ),
              ),
            ),
            // Lueur dorée si la ligne/colonne est presque complète
            if (isNearComplete)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(theme.cellBorderRadius),
                    border: Border.all(
                      color: theme.starGold.withValues(alpha: 0.8),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.starGold.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
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
        boxShadow: theme.isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 1.0,
                  offset: Offset(0, 1),
                ),
              ],
      ),
    );
  }
}
