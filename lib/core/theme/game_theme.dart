import 'package:flutter/material.dart';
import 'app_colors.dart';

enum GameThemeMode { neonArcade, crystalJewel, classicWood, zenPastel }

class GameTheme {
  final GameThemeMode mode;
  final String displayName;
  final bool isDark;

  // Background & Surfaces
  final Color backgroundColor;
  final Color surfaceColor;
  final Color cardColor;
  final Color elevatedSurfaceColor;

  // Board & Grid
  final Color boardBackground;
  final Color boardBorder;
  final Color cellEmptyColor;
  final Color cellBorderColor;
  final double cellBorderRadius;
  final bool hasGlow;

  // Borders & Dividers
  final Color borderColor;
  final Color dividerColor;

  // Typography
  final Color textColor;
  final Color textMutedColor;

  // Accent & Action Colors
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color buttonColor;
  final Color buttonTextColor;

  // Status & Feedback Colors
  final Color successColor;
  final Color alertColor;
  final Color starGold;

  // Polyomino Block Palette (7 high-contrast vivid colors)
  final List<Color> blockColors;

  const GameTheme({
    required this.mode,
    required this.displayName,
    required this.isDark,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.cardColor,
    required this.elevatedSurfaceColor,
    required this.boardBackground,
    required this.boardBorder,
    required this.cellEmptyColor,
    required this.cellBorderColor,
    required this.cellBorderRadius,
    required this.hasGlow,
    required this.borderColor,
    required this.dividerColor,
    required this.textColor,
    required this.textMutedColor,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.successColor,
    required this.alertColor,
    required this.starGold,
    required this.blockColors,
  });

  // ==========================================
  // 1. NÉON ARCADE (Dark & Light)
  // ==========================================
  static const GameTheme neonDark = GameTheme(
    mode: GameThemeMode.neonArcade,
    displayName: 'Néon Arcade',
    isDark: true,
    backgroundColor: Color(0xFF0F1020),
    surfaceColor: Color(0xFF181A30),
    cardColor: Color(0xFF1F223D),
    elevatedSurfaceColor: Color(0xFF282B4E),
    boardBackground: Color(0xFF141527),
    boardBorder: Color(0xFF2E335E),
    cellEmptyColor: Color(0xFF191A32),
    cellBorderColor: Color(0xFF282A4C),
    cellBorderRadius: 8.0,
    hasGlow: true,
    borderColor: Color(0x3300F2FE),
    dividerColor: Color(0x1FFFFFFF),
    textColor: Color(0xFFF1F5F9),
    textMutedColor: Color(0xFF94A3B8),
    primaryAccent: Color(0xFF00F2FE),
    secondaryAccent: Color(0xFFFF0844),
    buttonColor: Color(0xFF00F2FE),
    buttonTextColor: Color(0xFF0F1020),
    successColor: Color(0xFF00F5A0),
    alertColor: Color(0xFFFF0844),
    starGold: Color(0xFFFFD700),
    blockColors: AppColors.blockPalette,
  );

  static const GameTheme neonLight = GameTheme(
    mode: GameThemeMode.neonArcade,
    displayName: 'Néon Arcade',
    isDark: false,
    backgroundColor: Color(0xFFF1F5F9),
    surfaceColor: Color(0xFFFFFFFF),
    cardColor: Color(0xFFF8FAFC),
    elevatedSurfaceColor: Color(0xFFFFFFFF),
    boardBackground: Color(0xFFE2E8F0),
    boardBorder: Color(0xFFCBD5E1),
    cellEmptyColor: Color(0xFFF1F5F9),
    cellBorderColor: Color(0xFFE2E8F0),
    cellBorderRadius: 8.0,
    hasGlow: false,
    borderColor: Color(0xFFCBD5E1),
    dividerColor: Color(0xFFE2E8F0),
    textColor: Color(0xFF0F172A),
    textMutedColor: Color(0xFF64748B),
    primaryAccent: Color(0xFF0284C7),
    secondaryAccent: Color(0xFFE11D48),
    buttonColor: Color(0xFF0284C7),
    buttonTextColor: Colors.white,
    successColor: Color(0xFF16A34A),
    alertColor: Color(0xFFE11D48),
    starGold: Color(0xFFEAB308),
    blockColors: [
      Color(0xFF0284C7),
      Color(0xFFE11D48),
      Color(0xFFD97706),
      Color(0xFF16A34A),
      Color(0xFF7C3AED),
      Color(0xFFEA580C),
      Color(0xFF0891B2),
    ],
  );

  // ==========================================
  // 2. JOYAUX CÉLESTES (Dark & Light)
  // ==========================================
  static const GameTheme jewelDark = GameTheme(
    mode: GameThemeMode.crystalJewel,
    displayName: 'Joyaux Célestes',
    isDark: true,
    backgroundColor: Color(0xFF0A0F1D),
    surfaceColor: Color(0xFF131C31),
    cardColor: Color(0xFF1B2844),
    elevatedSurfaceColor: Color(0xFF233256),
    boardBackground: Color(0xFF0F172A),
    boardBorder: Color(0xFF2C3E67),
    cellEmptyColor: Color(0xFF131D33),
    cellBorderColor: Color(0xFF223153),
    cellBorderRadius: 6.0,
    hasGlow: true,
    borderColor: Color(0x3338BDF8),
    dividerColor: Color(0x1FFFFFFF),
    textColor: Color(0xFFF8FAFC),
    textMutedColor: Color(0xFF94A3B8),
    primaryAccent: Color(0xFF38BDF8),
    secondaryAccent: Color(0xFFF472B6),
    buttonColor: Color(0xFF38BDF8),
    buttonTextColor: Color(0xFF0A0F1D),
    successColor: Color(0xFF10B981),
    alertColor: Color(0xFFF43F5E),
    starGold: Color(0xFFFFD700),
    blockColors: [
      Color(0xFF06B6D4), // Cyan Gem
      Color(0xFFEC4899), // Pink Sapphire
      Color(0xFFEAB308), // Topaz
      Color(0xFF10B981), // Emerald
      Color(0xFFA855F7), // Amethyst
      Color(0xFFF97316), // Carnelian
      Color(0xFF3B82F6), // Sapphire
    ],
  );

  static const GameTheme jewelLight = GameTheme(
    mode: GameThemeMode.crystalJewel,
    displayName: 'Joyaux Célestes',
    isDark: false,
    backgroundColor: Color(0xFFF0F7FF),
    surfaceColor: Color(0xFFFFFFFF),
    cardColor: Color(0xFFF8FAFC),
    elevatedSurfaceColor: Color(0xFFFFFFFF),
    boardBackground: Color(0xFFDBEAFE),
    boardBorder: Color(0xFF93C5FD),
    cellEmptyColor: Color(0xFFEFF6FF),
    cellBorderColor: Color(0xFFBFDBFE),
    cellBorderRadius: 6.0,
    hasGlow: false,
    borderColor: Color(0xFFBFDBFE),
    dividerColor: Color(0xFFDBEAFE),
    textColor: Color(0xFF1E3A8A),
    textMutedColor: Color(0xFF64748B),
    primaryAccent: Color(0xFF2563EB),
    secondaryAccent: Color(0xFFDB2777),
    buttonColor: Color(0xFF2563EB),
    buttonTextColor: Colors.white,
    successColor: Color(0xFF059669),
    alertColor: Color(0xFFE11D48),
    starGold: Color(0xFFEAB308),
    blockColors: [
      Color(0xFF0284C7),
      Color(0xFFDB2777),
      Color(0xFFD97706),
      Color(0xFF059669),
      Color(0xFF7C3AED),
      Color(0xFFEA580C),
      Color(0xFF2563EB),
    ],
  );

  // ==========================================
  // 3. BOIS RUSTIQUE (Dark & Light)
  // ==========================================
  static const GameTheme woodDark = GameTheme(
    mode: GameThemeMode.classicWood,
    displayName: 'Bois Rustique',
    isDark: true,
    backgroundColor: Color(0xFF1D1009),
    surfaceColor: Color(0xFF2A170D),
    cardColor: Color(0xFF3B2215),
    elevatedSurfaceColor: Color(0xFF4C2D1C),
    boardBackground: Color(0xFF26140B),
    boardBorder: Color(0xFF5A3420),
    cellEmptyColor: Color(0xFF1F1009),
    cellBorderColor: Color(0xFF432516),
    cellBorderRadius: 4.0,
    hasGlow: false,
    borderColor: Color(0x33D97706),
    dividerColor: Color(0x1FFFFFFF),
    textColor: Color(0xFFFDF6EC),
    textMutedColor: Color(0xFFA88C7D),
    primaryAccent: Color(0xFFD97706),
    secondaryAccent: Color(0xFFB45309),
    buttonColor: Color(0xFFD97706),
    buttonTextColor: Color(0xFF1D1009),
    successColor: Color(0xFF65A30D),
    alertColor: Color(0xFFDC2626),
    starGold: Color(0xFFF59E0B),
    blockColors: [
      Color(0xFFD97706), // Chêne doré
      Color(0xFFB45309), // Teck ambré
      Color(0xFF92400E), // Noyer
      Color(0xFF78350F), // Ébène chaud
      Color(0xFFCA8A04), // Cèdre
      Color(0xFFA16207), // Mahogany
      Color(0xFFB45309), // Bois rouge
    ],
  );

  static const GameTheme woodLight = GameTheme(
    mode: GameThemeMode.classicWood,
    displayName: 'Bois Rustique',
    isDark: false,
    backgroundColor: Color(0xFFFDF8F3),
    surfaceColor: Color(0xFFFFFFFF),
    cardColor: Color(0xFFFAF3EC),
    elevatedSurfaceColor: Color(0xFFFFFFFF),
    boardBackground: Color(0xFFEEDCC9),
    boardBorder: Color(0xFFC7A78A),
    cellEmptyColor: Color(0xFFF8EFE6),
    cellBorderColor: Color(0xFFDDC3AC),
    cellBorderRadius: 4.0,
    hasGlow: false,
    borderColor: Color(0xFFDDC3AC),
    dividerColor: Color(0xFFEADBCE),
    textColor: Color(0xFF381F0D),
    textMutedColor: Color(0xFF7C5D46),
    primaryAccent: Color(0xFFB45309),
    secondaryAccent: Color(0xFF92400E),
    buttonColor: Color(0xFFB45309),
    buttonTextColor: Colors.white,
    successColor: Color(0xFF4D7C0F),
    alertColor: Color(0xFFB91C1C),
    starGold: Color(0xFFD97706),
    blockColors: [
      Color(0xFFB45309),
      Color(0xFF92400E),
      Color(0xFF78350F),
      Color(0xFFD97706),
      Color(0xFFA16207),
      Color(0xFFB45309),
      Color(0xFFCA8A04),
    ],
  );

  // ==========================================
  // 4. ZEN PASTEL (Dark & Light)
  // ==========================================
  static const GameTheme pastelDark = GameTheme(
    mode: GameThemeMode.zenPastel,
    displayName: 'Zen Pastel',
    isDark: true,
    backgroundColor: Color(0xFF141724),
    surfaceColor: Color(0xFF1E2235),
    cardColor: Color(0xFF262B42),
    elevatedSurfaceColor: Color(0xFF303653),
    boardBackground: Color(0xFF191D2E),
    boardBorder: Color(0xFF363D5D),
    cellEmptyColor: Color(0xFF1D2133),
    cellBorderColor: Color(0xFF2D334E),
    cellBorderRadius: 10.0,
    hasGlow: false,
    borderColor: Color(0x33A78BFA),
    dividerColor: Color(0x1FFFFFFF),
    textColor: Color(0xFFF8FAFC),
    textMutedColor: Color(0xFF94A3B8),
    primaryAccent: Color(0xFFA78BFA),
    secondaryAccent: Color(0xFFF472B6),
    buttonColor: Color(0xFFA78BFA),
    buttonTextColor: Color(0xFF141724),
    successColor: Color(0xFF4ADE80),
    alertColor: Color(0xFFFB7185),
    starGold: Color(0xFFFDE047),
    blockColors: [
      Color(0xFF38BDF8), // Pastel Sky
      Color(0xFFF472B6), // Pastel Rose
      Color(0xFFFDE047), // Pastel Banana
      Color(0xFF4ADE80), // Pastel Mint
      Color(0xFFC084FC), // Pastel Lavender
      Color(0xFFFB923C), // Pastel Peach
      Color(0xFF60A5FA), // Pastel Periwinkle
    ],
  );

  static const GameTheme pastelLight = GameTheme(
    mode: GameThemeMode.zenPastel,
    displayName: 'Zen Pastel',
    isDark: false,
    backgroundColor: Color(0xFFF8FAFC),
    surfaceColor: Color(0xFFFFFFFF),
    cardColor: Color(0xFFF1F5F9),
    elevatedSurfaceColor: Color(0xFFFFFFFF),
    boardBackground: Color(0xFFE2E8F0),
    boardBorder: Color(0xFFCBD5E1),
    cellEmptyColor: Color(0xFFF1F5F9),
    cellBorderColor: Color(0xFFE2E8F0),
    cellBorderRadius: 10.0,
    hasGlow: false,
    borderColor: Color(0xFFCBD5E1),
    dividerColor: Color(0xFFE2E8F0),
    textColor: Color(0xFF1E293B),
    textMutedColor: Color(0xFF64748B),
    primaryAccent: Color(0xFF8B5CF6),
    secondaryAccent: Color(0xFFEC4899),
    buttonColor: Color(0xFF8B5CF6),
    buttonTextColor: Colors.white,
    successColor: Color(0xFF16A34A),
    alertColor: Color(0xFFE11D48),
    starGold: Color(0xFFEAB308),
    blockColors: [
      Color(0xFF38BDF8),
      Color(0xFFF472B6),
      Color(0xFFEAB308),
      Color(0xFF22C55E),
      Color(0xFF8B5CF6),
      Color(0xFFF97316),
      Color(0xFF3B82F6),
    ],
  );

  // Getters par défaut (Dark)
  static GameTheme get neon => neonDark;
  static GameTheme get jewel => jewelDark;
  static GameTheme get wood => woodDark;
  static GameTheme get pastel => pastelDark;

  static GameTheme getTheme(GameThemeMode mode, {required bool isDark}) {
    switch (mode) {
      case GameThemeMode.neonArcade:
        return isDark ? neonDark : neonLight;
      case GameThemeMode.crystalJewel:
        return isDark ? jewelDark : jewelLight;
      case GameThemeMode.classicWood:
        return isDark ? woodDark : woodLight;
      case GameThemeMode.zenPastel:
        return isDark ? pastelDark : pastelLight;
    }
  }

  static GameTheme fromMode(GameThemeMode mode, {bool isDark = true}) {
    return getTheme(mode, isDark: isDark);
  }
}
