import 'package:flutter_test/flutter_test.dart';
import 'package:block_blast_android/engine/block_shape.dart';
import 'package:block_blast_android/engine/board_state.dart';
import 'package:block_blast_android/engine/score_calculator.dart';

void main() {
  group('BoardState Tests', () {
    test('Initial board is empty (8x8 zeros)', () {
      final board = BoardState();
      expect(board.grid.length, 8);
      expect(board.grid[0].length, 8);
      expect(board.occupiedCellsCount, 0);
    });

    test('Can place a valid single dot piece', () {
      final board = BoardState();
      final dot = BlockShape(
        id: 'dot',
        matrix: [[1]],
        colorIndex: 1,
      );

      expect(board.canPlace(dot, 0, 0), isTrue);
      board.place(dot, 0, 0);
      expect(board.grid[0][0], 1);
      expect(board.occupiedCellsCount, 1);
    });

    test('clearSingleCell clears targeted cell', () {
      final board = BoardState();
      board.grid[3][4] = 2; // Gummy jewel
      final cleared = board.clearSingleCell(3, 4);
      expect(cleared, 2);
      expect(board.grid[3][4], 0);
    });

    test('clear3x3Area clears surrounding block cells', () {
      final board = BoardState();
      for (int r = 1; r <= 3; r++) {
        for (int c = 1; c <= 3; c++) {
          board.grid[r][c] = 1;
        }
      }
      expect(board.occupiedCellsCount, 9);
      final cleared = board.clear3x3Area(2, 2);
      expect(cleared.length, 9);
      expect(board.occupiedCellsCount, 0);
    });

    test('checkCompletedLines detects full rows and full columns accurately', () {
      final board = BoardState();
      // Remplir la ligne 7 entièrement
      for (int c = 0; c < 8; c++) {
        board.grid[7][c] = 1;
      }
      // Remplir la colonne 2 entièrement
      for (int r = 0; r < 8; r++) {
        board.grid[r][2] = 3;
      }

      final result = board.checkCompletedLines();
      expect(result.rows, contains(7));
      expect(result.cols, contains(2));
      expect(result.totalLines, 2);
    });

    test('applyGravity makes suspended blocks drop into empty spaces', () {
      final board = BoardState();
      // Bloc en ligne 5, ligne 6 et 7 vides
      board.grid[5][3] = 4;
      // Bloc en ligne 2
      board.grid[2][3] = 6;

      final moved = board.applyGravity();
      expect(moved, isTrue);
      // Le bloc le plus bas (ligne 5) doit atterrir en ligne 7
      expect(board.grid[7][3], 4);
      // Le bloc en ligne 2 doit atterrir en ligne 6
      expect(board.grid[6][3], 6);
      // Les lignes 2 et 5 doivent être vides
      expect(board.grid[5][3], 0);
      expect(board.grid[2][3], 0);
    });
  });

  group('BlockShape Transformation Tests', () {
    test('Rotating piece 90 degrees transposes dimensions correctly', () {
      final horizontalBar = BlockShape(
        id: 'bar_3',
        matrix: [
          [1, 1, 1],
        ],
        colorIndex: 3,
      );
      expect(horizontalBar.rows, 1);
      expect(horizontalBar.cols, 3);

      final verticalBar = horizontalBar.rotate90();
      expect(verticalBar.rows, 3);
      expect(verticalBar.cols, 1);
      expect(verticalBar.matrix[0][0], 1);
      expect(verticalBar.matrix[1][0], 1);
      expect(verticalBar.matrix[2][0], 1);
    });

    test('Mirroring piece inverts columns', () {
      final lShape = BlockShape(
        id: 'L',
        matrix: [
          [1, 0],
          [1, 1],
        ],
        colorIndex: 2,
      );
      expect(lShape.mirror().matrix[0][0], 0);
      expect(lShape.mirror().matrix[0][1], 1);
      expect(lShape.mirror().matrix[1][0], 1);
      expect(lShape.mirror().matrix[1][1], 1);
    });
  });

  group('ScoreCalculator Tests', () {
    test('Calculates clear points with combo escalation', () {
      final ptsCombo1 = ScoreCalculator.calculateClearPoints(1, 1);
      final ptsCombo2 = ScoreCalculator.calculateClearPoints(1, 2);
      final ptsCombo3 = ScoreCalculator.calculateClearPoints(1, 3);

      expect(ptsCombo1, greaterThan(0));
      expect(ptsCombo2, greaterThan(ptsCombo1));
      expect(ptsCombo3, greaterThan(ptsCombo2));
    });
  });
}
