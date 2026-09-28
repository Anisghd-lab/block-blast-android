import 'dart:math' as math;

/// Gestionnaire des assets de fonds et boosters avec sélection aléatoire
class GameAssets {
  static final math.Random _rng = math.Random();

  // Liste des 9 fonds visuels
  static const List<String> backgrounds = [
    'assets/backgrounds/fonds_01.png',
    'assets/backgrounds/fonds_02.png',
    'assets/backgrounds/fonds_03.png',
    'assets/backgrounds/fonds_04.png',
    'assets/backgrounds/fonds_05.png',
    'assets/backgrounds/fonds_06.png',
    'assets/backgrounds/fonds_07.png',
    'assets/backgrounds/fonds_08.png',
    'assets/backgrounds/fonds_09.png',
  ];

  // Liste des 4 assets de boosters signatures
  // Index 0: Marteau, Index 1: Bombe, Index 2: Gant Magique, Index 3: +5 Coups Extra
  static const List<String> boosters = [
    'assets/boosters/booster_01.png', // Marteau
    'assets/boosters/booster_02.png', // Bombe
    'assets/boosters/booster_04.png', // Gant Magique
    'assets/boosters/booster_03.png', // +5 Coups Extra
  ];

  /// Retourne un fond aléatoire
  static String getRandomBackground() {
    return backgrounds[_rng.nextInt(backgrounds.length)];
  }

  /// Retourne l'asset du booster par index (0: Marteau, 1: Bombe, 2: Gant, 3: +5 Coups)
  static String getBoosterAsset(int index) {
    return boosters[index % boosters.length];
  }

  /// Retourne un booster aléatoire parmi les assets
  static String getRandomBooster() {
    return boosters[_rng.nextInt(boosters.length)];
  }
}
