/// Modèle représentant une pièce (Polyomino) pouvant être placée sur la grille
class BlockShape {
  final String id;
  final List<List<int>> matrix;
  final int colorIndex;

  const BlockShape({
    required this.id,
    required this.matrix,
    required this.colorIndex,
  });

  int get rows => matrix.length;
  int get cols => matrix.isEmpty ? 0 : matrix[0].length;

  /// Nombre de blocs réels occupés par la pièce
  int get blockCount {
    int count = 0;
    for (final row in matrix) {
      for (final cell in row) {
        if (cell > 0) count++;
      }
    }
    return count;
  }

  /// Fait pivoter la forme de 90 degrés dans le sens horaire
  BlockShape rotate90() {
    final oldRows = matrix.length;
    final oldCols = matrix.isEmpty ? 0 : matrix[0].length;
    final rotatedMatrix = List.generate(
      oldCols,
      (c) => List.generate(oldRows, (r) => matrix[oldRows - 1 - r][c]),
    );
    return BlockShape(
      id: '${id}_rot',
      matrix: rotatedMatrix,
      colorIndex: colorIndex,
    );
  }

  /// Inverse la forme horizontalement (effet miroir gauche <-> droite)
  BlockShape mirror() {
    final mirroredMatrix = matrix.map((row) => row.reversed.toList()).toList();
    return BlockShape(
      id: '${id}_mir',
      matrix: mirroredMatrix,
      colorIndex: colorIndex,
    );
  }

  /// Crée une copie de la forme avec une couleur différente
  BlockShape withColor(int newColorIndex) {
    return BlockShape(
      id: id,
      matrix: matrix,
      colorIndex: newColorIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matrix': matrix,
      'colorIndex': colorIndex,
    };
  }

  factory BlockShape.fromJson(Map<String, dynamic> json) {
    return BlockShape(
      id: json['id'] as String,
      matrix: (json['matrix'] as List)
          .map((r) => (r as List).map((c) => c as int).toList())
          .toList(),
      colorIndex: json['colorIndex'] as int,
    );
  }
}
