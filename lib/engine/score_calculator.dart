import 'block_shape.dart';

/// Moteur de calcul du score et des bonus de combos (Dopamine Loop)
/// ─────────────────────────────────────────────────────────────────
/// ÉQUILIBRAGE v1.0.1 :
///   • Points de pose  : blockCount × 15  (↑ vs 10 : gratifiant dès le départ)
///   • Scores de clear : x1.5 sur single line, doubles/triples bien récompensés
///   • Multiplicateur combo : +0.35 par cran (plus doux, progression linéaire)
///   • Formule 3★ cible : 60-70% des points max théoriques d'un niveau
class ScoreCalculator {
  /// Points accordés lors de la pose d'une pièce
  /// Avant : blockCount × 10  →  Après : blockCount × 15
  /// Une barre 5 = 75 pts de pose au lieu de 50 — récompense visible
  static int calculatePlacementPoints(BlockShape shape) {
    return shape.blockCount * 15;
  }

  /// Points accordés lors de l'effacement de [lineCount] lignes/colonnes
  /// avec [streak] combos consécutifs depuis le dernier coup sans clear.
  ///
  /// Nouvelle barème :
  ///   1 ligne  → 150 pts  (était 100)
  ///   2 lignes → 420 pts  (était 300)
  ///   3 lignes → 800 pts  (était 600)
  ///   4 lignes → 1 400 pts (était 1 000)
  ///   5+       → +700 par ligne supplémentaire (était +500)
  ///
  /// Multiplicateur combo : 1.0 + (streak-1) × 0.35
  ///   Combo x2 → ×1.35 | Combo x3 → ×1.70 | Combo x5 → ×2.40
  static int calculateClearPoints(int lineCount, int streak) {
    if (lineCount <= 0) return 0;

    int baseScore;
    switch (lineCount) {
      case 1:
        baseScore = 150;
        break;
      case 2:
        baseScore = 420;
        break;
      case 3:
        baseScore = 800;
        break;
      case 4:
        baseScore = 1400;
        break;
      default:
        baseScore = 1400 + (lineCount - 4) * 700;
        break;
    }

    // Multiplicateur de combo consécutif (progression plus douce)
    double multiplier = 1.0;
    if (streak > 1) {
      multiplier = 1.0 + (streak - 1) * 0.35;
    }

    return (baseScore * multiplier).round();
  }

  /// Points bonus accordés pour chaque gemme effacée dans une ligne
  static const int jewelsBonus = 75;

  /// Points bonus accordés pour chaque rocher brisé dans une ligne
  static const int rocksBonus = 45;
}
