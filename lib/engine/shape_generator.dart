import 'dart:math';
import 'block_shape.dart';
import 'board_state.dart';
import 'shape_definitions.dart';

/// Générateur intelligent de pièces — Équilibrage v1.0.1
/// ──────────────────────────────────────────────────────
/// Règles d'équilibrage :
///   1. Toujours 1 pièce petite (<=3 blocs) dans le trio  → soupape de sécurité
///   2. Pièce 2 : moyenne, biaisée vers les barres 3-4 (combo-friendly)
///   3. Pièce 3 : dépend du taux de remplissage de la grille
///   4. Vérification anti-blocage renforcée : si 2 pièces sur 3 ne rentrent pas,
///      on remplace aussi la 2e par une pièce de secours
///   5. Quand la grille est à ≥55% de remplissage, favorise ENCORE plus les petites
class ShapeGenerator {
  final Random _random = Random();

  // Petits (1-3 blocs) — "safe pieces"
  static const List<int> _small = [0, 1, 2, 11, 12, 13, 14];
  // Barres 3 & 4, carrés 2×2, T, L courts — combo-friendly
  static const List<int> _medium = [3, 4, 9, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24];
  // Barres 4/5, carré 3×3, grands coins — pièces choc
  static const List<int> _large = [5, 6, 7, 8, 10, 25, 26, 27, 28];
  // Barres longues (3-4) maximisant les chances de compléter une ligne seul
  static const List<int> _comboFriendly = [3, 4, 5, 6]; // barres H/V 3 et 4

  /// Génère un trio de 3 pièces équilibré et jouable
  List<BlockShape> generateTrio(BoardState board, {List<String>? allowedShapes}) {
    final List<BlockShape> trio = [];

    // Si des formes spécifiques sont imposées par le niveau
    if (allowedShapes != null && allowedShapes.isNotEmpty) {
      for (int i = 0; i < 3; i++) {
        final key = allowedShapes[_random.nextInt(allowedShapes.length)];
        final color = _randomColor(0);
        final shape = ShapeDefinitions.createShapeByName(key, color) ??
            ShapeDefinitions.createShape(0, color);
        trio.add(shape);
      }
      return trio;
    }

    final double fillRate = board.occupiedCellsCount / 64.0;
    final bool congested = fillRate >= 0.55; // grille encombrée

    // ── Pièce 1 : TOUJOURS petite (soupape de sécurité)
    final p1Color = _randomColor(0);
    final p1Index = _small[_random.nextInt(_small.length)];
    trio.add(ShapeDefinitions.createShape(p1Index, p1Color));

    // ── Pièce 2 : barre ou forme combo-friendly (50%) ou moyenne (50%)
    final p2Color = _randomColor(p1Color);
    final bool favorCombo = _random.nextBool();
    final List<int> p2Pool = favorCombo ? _comboFriendly : _medium;
    final p2Index = p2Pool[_random.nextInt(p2Pool.length)];
    trio.add(ShapeDefinitions.createShape(p2Index, p2Color));

    // ── Pièce 3 : s'adapte au remplissage de la grille
    final p3Color = _randomColor3(p1Color, p2Color);
    final List<int> p3Pool;
    if (congested) {
      // Grille chargée → petite ou moyenne seulement
      p3Pool = [..._small, ..._medium];
    } else if (fillRate < 0.30) {
      // Grille vide → on peut se permettre une grande pièce
      p3Pool = [..._medium, ..._large];
    } else {
      p3Pool = [..._medium];
    }
    final p3Index = p3Pool[_random.nextInt(p3Pool.length)];
    trio.add(ShapeDefinitions.createShape(p3Index, p3Color));

    // ── Anti-blocage renforcé : compter combien de pièces sont jouables
    int playableCount = 0;
    for (final piece in trio) {
      if (board.canFitAnywhere(piece)) playableCount++;
    }

    // Si moins de 2 pièces sont jouables, on remplace les pièces bloquantes
    if (playableCount < 2) {
      const fallbackCandidates = [0, 1, 2, 3, 4, 9, 11, 12];
      for (int i = 0; i < 3; i++) {
        if (!board.canFitAnywhere(trio[i])) {
          for (final ci in fallbackCandidates) {
            final candidate = ShapeDefinitions.createShape(ci, _randomColor(0));
            if (board.canFitAnywhere(candidate)) {
              trio[i] = candidate;
              break;
            }
          }
        }
      }
    }

    return trio;
  }

  int _randomColor(int exclude1) {
    int c;
    do {
      c = _random.nextInt(7) + 1;
    } while (c == exclude1);
    return c;
  }

  int _randomColor3(int ex1, int ex2) {
    int c;
    do {
      c = _random.nextInt(7) + 1;
    } while (c == ex1 || c == ex2);
    return c;
  }
}
