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
