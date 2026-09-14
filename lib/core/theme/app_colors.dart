import 'package:flutter/material.dart';

/// Palette de couleurs moderne et néon pour Block Blast Android
class AppColors {
  // Fond et surfaces du thème Néon Arcade
  static const Color background = Color(0xFF111223);
  static const Color backgroundDark = Color(0xFF0C0D1D);
  static const Color surfaceContainer = Color(0xFF1D1E30);
  static const Color surfaceElevated = Color(0xFF28283B);
  static const Color gridCellEmpty = Color(0xFF16172B);
  static const Color gridCellBorder = Color(0xFF252742);
  static const Color gridCellGhostValid = Color(0x6600F2FE);
  static const Color gridCellGhostInvalid = Color(0x66FF0844);

  // Couleurs vives et saturées des blocs (Polyominos)
  static const List<Color> blockPalette = [
    Color(0xFF00F2FE), // 1: Cyan Électrique
    Color(0xFFFF0844), // 2: Magenta / Rose Néon
    Color(0xFFFED929), // 3: Jaune Solaire
    Color(0xFF00F5A0), // 4: Vert Lime Burst
    Color(0xFF8B5CF6), // 5: Violet Royal Astral
    Color(0xFFFF6A00), // 6: Orange Sunset Flare
    Color(0xFF38BDF8), // 7: Bleu Azur Céleste
  ];

  // Dégradés 3D pour donner du relief et de la brillance aux blocs
  static LinearGradient blockGradient(Color baseColor) {
    // Calcul de teintes plus claires pour le haut et plus sombres pour le bas
    final HSLColor hsl = HSLColor.fromColor(baseColor);
    final Color topLight = hsl.withLightness((hsl.lightness + 0.18).clamp(0.0, 1.0)).toColor();
    final Color bottomDark = hsl.withLightness((hsl.lightness - 0.18).clamp(0.0, 1.0)).toColor();

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [topLight, baseColor, bottomDark],
      stops: const [0.0, 0.45, 1.0],
    );
  }

  // Accents UI
  static const Color goldBest = Color(0xFFFFD700);
  static const Color textLight = Color(0xFFE1E0F9);
  static const Color textMuted = Color(0xFF849495);
  static const Color fireOrange = Color(0xFFFF4500);
  static const Color fireYellow = Color(0xFFFFA500);
}
