import 'dart:math';
import 'block_shape.dart';
import 'board_state.dart';
import 'shape_definitions.dart';

/// Générateur intelligent de pièces évitant la frustration du joueur
class ShapeGenerator {
  final Random _random = Random();

  /// Génère un trio de 3 pièces équilibré et jouable
  List<BlockShape> generateTrio(BoardState board, {List<String>? allowedShapes}) {
    final List<BlockShape> trio = [];

    // Si des formes spécifiques sont imposées par le niveau
    if (allowedShapes != null && allowedShapes.isNotEmpty) {
      for (int i = 0; i < 3; i++) {
        final key = allowedShapes[_random.nextInt(allowedShapes.length)];
        final color = (_random.nextInt(7)) + 1;
        final shape = ShapeDefinitions.createShapeByName(key, color) ??
            ShapeDefinitions.createShape(0, color);
        trio.add(shape);
      }
      return trio;
    }

    // Indices des formes de petite taille (1x1, 1x2, 2x1, coin 3)
    final smallIndices = [0, 1, 2, 11, 12, 13, 14];
    // Indices des formes moyennes (barres 3, T, carrés 2x2, L 4)
    final mediumIndices = [3, 4, 9, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24];
    // Indices des grandes formes (barres 4/5, carré 3x3, grand coin)
    final largeIndices = [5, 6, 7, 8, 10, 25, 26, 27, 28];

    // Pièce 1: Petite forme (sécurité)
    final p1Index = smallIndices[_random.nextInt(smallIndices.length)];
    final p1Color = (_random.nextInt(7)) + 1;
    trio.add(ShapeDefinitions.createShape(p1Index, p1Color));

    // Pièce 2: Forme moyenne
    final p2Index = mediumIndices[_random.nextInt(mediumIndices.length)];
    int p2Color = (_random.nextInt(7)) + 1;
    while (p2Color == p1Color) {
      p2Color = (_random.nextInt(7)) + 1;
    }
    trio.add(ShapeDefinitions.createShape(p2Index, p2Color));

    // Pièce 3: Forme aléatoire selon la place disponible
    List<int> pool;
    if (board.occupiedCellsCount > 40) {
      // Si la grille est très encombrée, favoriser les pièces moyennes/petites
      pool = [...smallIndices, ...mediumIndices];
    } else {
      pool = [...mediumIndices, ...largeIndices];
    }
    final p3Index = pool[_random.nextInt(pool.length)];
    int p3Color = (_random.nextInt(7)) + 1;
    while (p3Color == p1Color || p3Color == p2Color) {
      p3Color = (_random.nextInt(7)) + 1;
    }
    trio.add(ShapeDefinitions.createShape(p3Index, p3Color));

    // Vérification anti-blocage : s'assurer qu'au moins UNE pièce peut être posée
    bool hasValidMove = board.hasAnyValidMove(trio);
    if (!hasValidMove) {
      // Remplacer la première pièce par une pièce qui rentre avec certitude (1x1 ou barre 2)
      for (int candidateIndex in [0, 1, 2, 9, 3, 4]) {
        final candidate = ShapeDefinitions.createShape(candidateIndex, p1Color);
        if (board.canFitAnywhere(candidate)) {
          trio[0] = candidate;
          break;
        }
      }
    }

    return trio;
  }
}
