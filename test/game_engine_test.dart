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
        name: 'dot',
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
  });

  group('BlockShape Transformation Tests', () {
    test('Rotating piece 90 degrees transposes dimensions correctly', () {
      final horizontalBar = BlockShape(
        name: 'bar_3',
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
        name: 'L',
        matrix: [
          [1, 0],
          [1, 1],
        ],
        colorIndex: 2,
      );
      final mirrored = lShape.mirror();
      expect(mirrored.matrix[0][0], 0);
      expect(mirrored.matrix[0][1], 1);
      expect(mirrored.matrix[1][0], 1);
      expect(mirrored.matrix[1][1], 1);
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
