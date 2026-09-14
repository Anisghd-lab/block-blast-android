import 'block_shape.dart';

/// Moteur de calcul du score et des bonus de combos (Dopamine Loop)
class ScoreCalculator {
  /// Points accordés lors de la pose d'une pièce
  static int calculatePlacementPoints(BlockShape shape) {
    return shape.blockCount * 10;
  }

  /// Points accordés lors de l'effacement simultané de plusieurs lignes
  static int calculateClearPoints(int lineCount, int streak) {
    if (lineCount <= 0) return 0;

    int baseScore;
    switch (lineCount) {
      case 1:
        baseScore = 100;
        break;
      case 2:
        baseScore = 300;
        break;
      case 3:
        baseScore = 600;
        break;
      case 4:
        baseScore = 1000;
        break;
      default:
        baseScore = 1000 + (lineCount - 4) * 500;
        break;
    }

    // Multiplicateur de combo consécutif
    double multiplier = 1.0;
    if (streak > 1) {
      multiplier = 1.0 + (streak - 1) * 0.5;
    }

    return (baseScore * multiplier).round();
  }
}
