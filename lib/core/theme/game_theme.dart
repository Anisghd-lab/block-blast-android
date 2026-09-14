import 'package:flutter/material.dart';
import 'app_colors.dart';

enum GameThemeMode { neonArcade, crystalJewel, classicWood, zenPastel }

class GameTheme {
  final GameThemeMode mode;
  final String displayName;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color cellEmptyColor;
  final Color cellBorderColor;
  final List<Color> blockColors;
  final double cellBorderRadius;
  final bool hasGlow;

  const GameTheme({
    required this.mode,
    required this.displayName,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.cellEmptyColor,
    required this.cellBorderColor,
    required this.blockColors,
    required this.cellBorderRadius,
    required this.hasGlow,
  });

  static const GameTheme neon = GameTheme(
    mode: GameThemeMode.neonArcade,
    displayName: 'Néon Arcade',
    backgroundColor: AppColors.background,
    surfaceColor: AppColors.surfaceContainer,
    cellEmptyColor: AppColors.gridCellEmpty,
    cellBorderColor: AppColors.gridCellBorder,
    blockColors: AppColors.blockPalette,
    cellBorderRadius: 8.0,
    hasGlow: true,
  );

  static const GameTheme jewel = GameTheme(
    mode: GameThemeMode.crystalJewel,
    displayName: 'Joyaux Célestes',
    backgroundColor: Color(0xFF0F172A),
    surfaceColor: Color(0xFF1E293B),
    cellEmptyColor: Color(0xFF141E33),
    cellBorderColor: Color(0xFF334155),
    blockColors: [
      Color(0xFF06B6D4), // Cyan Gem
      Color(0xFFEC4899), // Pink Sapphire
      Color(0xFFEAB308), // Topaz
      Color(0xFF10B981), // Emerald
      Color(0xFFA855F7), // Amethyst
      Color(0xFFF97316), // Carnelian
      Color(0xFF3B82F6), // Sapphire
    ],
    cellBorderRadius: 6.0,
    hasGlow: true,
  );

  static const GameTheme wood = GameTheme(
    mode: GameThemeMode.classicWood,
    displayName: 'Bois Rustique',
    backgroundColor: Color(0xFF2C1810),
    surfaceColor: Color(0xFF3D2314),
    cellEmptyColor: Color(0xFF23120A),
    cellBorderColor: Color(0xFF5A3825),
    blockColors: [
      Color(0xFFD97706), // Chêne doré
      Color(0xFFB45309), // Teck ambré
      Color(0xFF92400E), // Noyer
      Color(0xFF78350F), // Ébène chaud
      Color(0xFFCA8A04), // Cèdre
      Color(0xFFA16207), // Mahogany
      Color(0xFFB45309), // Bois rouge
    ],
    cellBorderRadius: 4.0,
    hasGlow: false,
  );

  static const GameTheme pastel = GameTheme(
    mode: GameThemeMode.zenPastel,
    displayName: 'Zen Pastel',
    backgroundColor: Color(0xFFF8FAFC),
    surfaceColor: Color(0xFFEDF2F7),
    cellEmptyColor: Color(0xFFE2E8F0),
    cellBorderColor: Color(0xFFCBD5E1),
    blockColors: [
      Color(0xFF38BDF8), // Pastel Sky
      Color(0xFFF472B6), // Pastel Rose
      Color(0xFFFDE047), // Pastel Banana
      Color(0xFF4ADE80), // Pastel Mint
      Color(0xFFC084FC), // Pastel Lavender
      Color(0xFFFB923C), // Pastel Peach
      Color(0xFF60A5FA), // Pastel Periwinkle
    ],
    cellBorderRadius: 10.0,
    hasGlow: false,
  );

  static GameTheme fromMode(GameThemeMode mode) {
    switch (mode) {
      case GameThemeMode.neonArcade:
        return neon;
      case GameThemeMode.crystalJewel:
        return jewel;
      case GameThemeMode.classicWood:
        return wood;
      case GameThemeMode.zenPastel:
        return pastel;
    }
  }
}
