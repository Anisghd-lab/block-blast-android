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

/// Palette gourmande "Sugar Delight / Candy Burst" (inspirée du jeu modèle Play Store)
class CandyColors {
  // Fond & Ciel Sucré Pastel
  static const Color skyTop = Color(0xFFC7E8FD);
  static const Color skyMid = Color(0xFFE9F3FE);
  static const Color skyBottom = Color(0xFFFDE8F1);
  static const Color cloudWhite = Color(0xEEFFFFFF);

  // Plateau de jeu façon boîte de confiserie nacrée
  static const Color boardContainer = Color(0xFF2C4E7E);
  static const Color boardBorder = Color(0xFF4C75AB);
  static const Color cellEmpty = Color(0xFF1E385D);
  static const Color cellBorder = Color(0xFF385E92);
  static const Color cellInnerShadow = Color(0x44000000);

  // Prévisualisation Ghost
  static const Color ghostValid = Color(0x7700E5FF);
  static const Color ghostInvalid = Color(0x77FF1744);

  // Bonbons Polyominos (Vifs, sucrés et contrastés)
  static const Color rubyHeart = Color(0xFFFF2E63);    // 1: Cœur Fraise Rubis
  static const Color lemonStar = Color(0xFFFFBE0B);    // 2: Étoile Citron Dorée
  static const Color limeDrop = Color(0xFF10B981);     // 3: Goutte Pomme Verte
  static const Color plumBonbon = Color(0xFFA855F7);   // 4: Coussin Violet Myrtille
  static const Color aquaRing = Color(0xFF00C8FF);     // 5: Anneau Cyan Glacé
  static const Color orangeTangerine = Color(0xFFFF7A00); // 6: Quartier d'Orange
  static const Color tangerineOrange = orangeTangerine;
  static const Color berryPink = Color(0xFFFF4D94);    // 7: Bonbon Framboise Guimauve

  static const List<Color> candyPalette = [
    rubyHeart,
    lemonStar,
    limeDrop,
    plumBonbon,
    aquaRing,
    orangeTangerine,
    berryPink,
  ];

  // Obstacles & Spéciaux
  static const Color gummyBearGold = Color(0xFFFFB300);
  static const Color waferBiscuitBase = Color(0xFFD97706);
  static const Color waferBiscuitDark = Color(0xFF92400E);
  static const Color chocolateIcing = Color(0xFF532410);
  static const Color creamWhipped = Color(0xFFFFFBEB);

  // Interface HUD Cartoon
  static const Color hudBannerBlue = Color(0xFF2E86DE);
  static const Color hudBannerBlueDark = Color(0xFF1B62AB);
  static const Color hudCardWhite = Color(0xFFFFFFFF);
  static const Color hudCardBorder = Color(0xFFD8EBFF);
  static const Color textCaramel = Color(0xFF5C3317);
  static const Color starGold = Color(0xFFFFC107);
  static const Color starGoldGlow = Color(0xFFFFD54F);
  static const Color greenSuccess = Color(0xFF00E676);

  /// Dégradé de bonbon bombé avec brillance zénithale
  static LinearGradient candyShineGradient(Color baseColor) {
    final HSLColor hsl = HSLColor.fromColor(baseColor);
    final Color highlight = hsl.withLightness((hsl.lightness + 0.22).clamp(0.0, 1.0)).toColor();
    final Color shade = hsl.withLightness((hsl.lightness - 0.20).clamp(0.0, 1.0)).toColor();

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [highlight, baseColor, shade],
      stops: const [0.0, 0.40, 1.0],
    );
  }
}

