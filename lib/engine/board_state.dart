import 'block_shape.dart';

/// Gestionnaire de l'état de la grille 8x8 (supportant blocs, joyaux et roches)
class BoardState {
  static const int size = 8;
  late List<List<int>> grid;

  BoardState() {
    grid = List.generate(size, (_) => List.filled(size, 0));
  }

  BoardState.fromGrid(List<List<int>> initialGrid) {
    grid = initialGrid.map((row) => List<int>.from(row)).toList();
  }

  /// Vérifie si une pièce peut être posée à la coordonnée (row, col)
  /// Une cellule est occupée si sa valeur n'est pas 0 (bloc, joyau 2 ou roche -1)
  bool canPlace(BlockShape shape, int startRow, int startCol) {
    if (startRow < 0 || startCol < 0) return false;
    if (startRow + shape.rows > size || startCol + shape.cols > size) {
      return false;
    }

    for (int r = 0; r < shape.rows; r++) {
      for (int c = 0; c < shape.cols; c++) {
        if (shape.matrix[r][c] > 0) {
          if (grid[startRow + r][startCol + c] != 0) {
            return false; // Cellule déjà occupée
          }
        }
      }
    }
    return true;
  }

  /// Place la pièce sur la grille
  void place(BlockShape shape, int startRow, int startCol) {
    for (int r = 0; r < shape.rows; r++) {
      for (int c = 0; c < shape.cols; c++) {
        if (shape.matrix[r][c] > 0) {
          grid[startRow + r][startCol + c] = shape.colorIndex;
        }
      }
    }
  }

  /// Détecte toutes les lignes et colonnes entièrement complétées
  LineClearResult checkCompletedLines() {
    final List<int> fullRows = [];
    final List<int> fullCols = [];

    // Vérification des lignes horizontales (aucune case à 0)
    for (int r = 0; r < size; r++) {
      bool isFull = true;
      for (int c = 0; c < size; c++) {
        if (grid[r][c] == 0) {
          isFull = false;
          break;
        }
      }
      if (isFull) fullRows.add(r);
    }

    // Vérification des colonnes verticales (aucune case à 0)
    for (int c = 0; c < size; c++) {
      bool isFull = true;
      for (int r = 0; r < size; r++) {
        if (grid[r][c] == 0) {
          isFull = false;
          break;
        }
      }
      if (isFull) fullCols.add(c);
    }

    // Calcul des joyaux et roches détruits dans les lignes complètes
    int jewels = 0;
    int rocks = 0;
    final Set<String> visited = {};

    void checkCell(int r, int c) {
      final key = '$r-$c';
      if (!visited.add(key)) return;
      final val = grid[r][c];
      if (val == 2) jewels++;
      if (val == -1) rocks++;
    }

    for (final r in fullRows) {
      for (int c = 0; c < size; c++) {
        checkCell(r, c);
      }
    }

    for (final c in fullCols) {
      for (int r = 0; r < size; r++) {
        checkCell(r, c);
      }
    }

    return LineClearResult(
      rows: fullRows,
      cols: fullCols,
      jewelsCleared: jewels,
      rocksCleared: rocks,
    );
  }

  /// Efface les lignes et colonnes indiquées
  void clearLines(List<int> rows, List<int> cols) {
    for (final r in rows) {
      for (int c = 0; c < size; c++) {
        grid[r][c] = 0;
      }
    }
    for (final c in cols) {
      for (int r = 0; r < size; r++) {
        grid[r][c] = 0;
      }
    }
  }

  /// Efface une seule cellule et renvoie sa valeur précédente (ou 0 si vide)
  int clearSingleCell(int r, int c) {
    if (r < 0 || r >= size || c < 0 || c >= size) return 0;
    final val = grid[r][c];
    grid[r][c] = 0;
    return val;
  }

  /// Efface une zone 3x3 centrée en (centerR, centerC) et renvoie les cellules modifiées avec leur ancienne valeur
  List<(int, int, int)> clear3x3Area(int centerR, int centerC) {
    final List<(int, int, int)> cleared = [];
    for (int r = centerR - 1; r <= centerR + 1; r++) {
      if (r < 0 || r >= size) continue;
      for (int c = centerC - 1; c <= centerC + 1; c++) {
        if (c < 0 || c >= size) continue;
        final val = grid[r][c];
        if (val != 0) {
          grid[r][c] = 0;
          cleared.add((r, c, val));
        }
      }
    }
    return cleared;
  }

  /// Vérifie si une pièce donnée peut être placée n'importe où sur la grille
  bool canFitAnywhere(BlockShape shape) {
    for (int r = 0; r <= size - shape.rows; r++) {
      for (int c = 0; c <= size - shape.cols; c++) {
        if (canPlace(shape, r, c)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Vérifie si au moins une pièce parmi la sélection peut être jouée
  bool hasAnyValidMove(List<BlockShape?> pieces) {
    for (final piece in pieces) {
      if (piece != null && canFitAnywhere(piece)) {
        return true;
      }
    }
    return false;
  }

  /// Crée un clone indépendant de la grille
  BoardState clone() {
    return BoardState.fromGrid(grid);
  }

  /// Nombre de cases actuellement occupées
  int get occupiedCellsCount {
    int count = 0;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c] != 0) count++;
      }
    }
    return count;
  }

  /// Réinitialise la grille
  void reset() {
    grid = List.generate(size, (_) => List.filled(size, 0));
  }

  List<List<int>> toJson() => grid.map((r) => List<int>.from(r)).toList();

  factory BoardState.fromJson(List<dynamic> json) {
    final parsed = json
        .map((r) => (r as List).map((c) => c as int).toList())
        .toList();
    return BoardState.fromGrid(parsed);
  }
}

class LineClearResult {
  final List<int> rows;
  final List<int> cols;
  final int jewelsCleared;
  final int rocksCleared;

  const LineClearResult({
    required this.rows,
    required this.cols,
    this.jewelsCleared = 0,
    this.rocksCleared = 0,
  });

  int get totalLines => rows.length + cols.length;
  bool get hasClear => totalLines > 0;
}
