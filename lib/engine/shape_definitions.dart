import 'block_shape.dart';

/// Bibliothèque exhaustive des formes de blocs classiques du genre Block Blast
class ShapeDefinitions {
  static const List<List<List<int>>> templates = [
    // 0: Point 1x1
    [
      [1],
    ],

    // 1-2: Barre 2
    [
      [1, 1],
    ],
    [
      [1],
      [1],
    ],

    // 3-4: Barre 3
    [
      [1, 1, 1],
    ],
    [
      [1],
      [1],
      [1],
    ],

    // 5-6: Barre 4
    [
      [1, 1, 1, 1],
    ],
    [
      [1],
      [1],
      [1],
      [1],
    ],

    // 7-8: Barre 5
    [
      [1, 1, 1, 1, 1],
    ],
    [
      [1],
      [1],
      [1],
      [1],
      [1],
    ],

    // 9: Carré 2x2
    [
      [1, 1],
      [1, 1],
    ],

    // 10: Carré Géant 3x3
    [
      [1, 1, 1],
      [1, 1, 1],
      [1, 1, 1],
    ],

    // 11-14: Petit Coin / L 3 blocs (2x2)
    [
      [1, 1],
      [1, 0],
    ],
    [
      [1, 1],
      [0, 1],
    ],
    [
      [1, 0],
      [1, 1],
    ],
    [
      [0, 1],
      [1, 1],
    ],

    // 15-18: Grand L 4 blocs (3x2 ou 2x3)
    [
      [1, 0],
      [1, 0],
      [1, 1],
    ],
    [
      [0, 1],
      [0, 1],
      [1, 1],
    ],
    [
      [1, 1, 1],
      [1, 0, 0],
    ],
    [
      [1, 1, 1],
      [0, 0, 1],
    ],

    // 19-22: Forme T (4 blocs)
    [
      [1, 1, 1],
      [0, 1, 0],
    ],
    [
      [0, 1, 0],
      [1, 1, 1],
    ],
    [
      [1, 0],
      [1, 1],
      [1, 0],
    ],
    [
      [0, 1],
      [1, 1],
      [0, 1],
    ],

    // 23-24: Formes Z et S
    [
      [1, 1, 0],
      [0, 1, 1],
    ],
    [
      [0, 1, 1],
      [1, 1, 0],
    ],

    // 25-28: Grand coin 3x3 (5 blocs)
    [
      [1, 1, 1],
      [1, 0, 0],
      [1, 0, 0],
    ],
    [
      [1, 1, 1],
      [0, 0, 1],
      [0, 0, 1],
    ],
    [
      [1, 0, 0],
      [1, 0, 0],
      [1, 1, 1],
    ],
    [
      [0, 0, 1],
      [0, 0, 1],
      [1, 1, 1],
    ],
  ];

  static final Map<String, List<List<int>>> namedShapes = {
    '1x1': [
      [1]
    ],
    '1x2_h': [
      [1, 1]
    ],
    '1x2_v': [
      [1],
      [1]
    ],
    '1x3_h': [
      [1, 1, 1]
    ],
    '1x3_v': [
      [1],
      [1],
      [1]
    ],
    '1x4_h': [
      [1, 1, 1, 1]
    ],
    '1x4_v': [
      [1],
      [1],
      [1],
      [1]
    ],
    '1x5_h': [
      [1, 1, 1, 1, 1]
    ],
    '1x5_v': [
      [1],
      [1],
      [1],
      [1],
      [1]
    ],
    '2x2': [
      [1, 1],
      [1, 1]
    ],
    '3x3': [
      [1, 1, 1],
      [1, 1, 1],
      [1, 1, 1]
    ],
    'L_normal': [
      [1, 0],
      [1, 0],
      [1, 1]
    ],
    'L_inv': [
      [0, 1],
      [0, 1],
      [1, 1]
    ],
    'L_giant': [
      [1, 0, 0],
      [1, 0, 0],
      [1, 1, 1]
    ],
    'S_shape': [
      [0, 1, 1],
      [1, 1, 0]
    ],
    'Z_shape': [
      [1, 1, 0],
      [0, 1, 1]
    ],
    'T_shape': [
      [1, 1, 1],
      [0, 1, 0]
    ],
    'U_shape': [
      [1, 0, 1],
      [1, 1, 1]
    ],
    'plus_5': [
      [0, 1, 0],
      [1, 1, 1],
      [0, 1, 0]
    ],
  };

  static BlockShape? createShapeByName(String name, int colorIndex) {
    final matrix = namedShapes[name];
    if (matrix == null) return null;
    return BlockShape(
      id: 'shape_${name}_$colorIndex',
      matrix: matrix,
      colorIndex: colorIndex,
    );
  }

  static BlockShape createShape(int index, int colorIndex) {
    final template = templates[index % templates.length];
    return BlockShape(
      id: 'shape_${index}_$colorIndex',
      matrix: template,
      colorIndex: colorIndex,
    );
  }
}
