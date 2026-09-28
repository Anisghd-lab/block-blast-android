import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/game_theme.dart';
import '../../engine/block_shape.dart';
import '../../engine/board_state.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import 'board_cell.dart';
import 'juice_effects.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  final GlobalKey _boardKey = GlobalKey();
  final GlobalKey<JuiceOverlayState> _juiceKey = GlobalKey<JuiceOverlayState>();
  int _lastHandledClearTimestamp = 0;

  // Décalage tactile vertical standard pour mobile (la pièce flotte au-dessus du doigt)
  static const double fingerVerticalOffset = -75.0;

  void _handleClearEffects(
    ClearEvent event,
    double boardSize,
    double cellSize,
    double spacing,
    double padding,
    bool isCandyTheme,
  ) {
    final juice = _juiceKey.currentState;
    if (juice == null) return;

    final colors = isCandyTheme
        ? CandyColors.candyPalette
        : const [
            Color(0xFF00F2FE),
            Color(0xFFFF0844),
            Color(0xFFFED929),
            Color(0xFF00F5A0),
            Color(0xFF8B5CF6),
          ];

    // 1. Particules éclatantes sur chaque ligne détruite
    for (final r in event.rows) {
      final y = padding + r * (cellSize + spacing) + cellSize / 2;
      for (int c = 0; c < BoardState.size; c += 2) {
        final x = padding + c * (cellSize + spacing) + cellSize / 2;
        juice.emitBurst(
          position: Offset(x, y),
          colors: colors,
          particleCount: 10,
          emitShockwave: c == 0,
        );
      }
    }

    // 2. Particules éclatantes sur chaque colonne détruite
    for (final c in event.cols) {
      final x = padding + c * (cellSize + spacing) + cellSize / 2;
      for (int r = 0; r < BoardState.size; r += 2) {
        final y = padding + r * (cellSize + spacing) + cellSize / 2;
        juice.emitBurst(
          position: Offset(x, y),
          colors: colors,
          particleCount: 10,
          emitShockwave: r == 0,
        );
      }
    }

    // 3. Tremblement d'écran physique (Juice)
    if (event.totalLines >= 2 || event.comboStreak >= 2) {
      final mag = (3.5 + event.totalLines * 1.5 + event.comboStreak * 1.0).clamp(3.0, 9.0);
      juice.triggerScreenShake(magnitude: mag);
    }

    // 4. Textes flottants rebondissants
    String phrase;
    if (event.comboStreak >= 4) {
      phrase = '💥 INCROYABLE !';
    } else if (event.comboStreak == 3) {
      phrase = '🍭 SUCRÉ !';
    } else if (event.comboStreak == 2) {
      phrase = '🍬 DÉLICIEUX !';
    } else if (event.totalLines >= 3) {
      phrase = '⚡ TRIPLE BURST !';
    } else if (event.totalLines == 2) {
      phrase = '✨ DOUBLE COMBO !';
    } else {
      phrase = '+${event.points}';
    }

    juice.spawnFloatingText(
      position: Offset(boardSize / 2, boardSize * 0.45),
      text: phrase,
      color: event.comboStreak >= 2 ? CandyColors.rubyHeart : CandyColors.starGoldGlow,
    );
  }

  void _applyHammerAt(
    int r,
    int c,
    double cellSize,
    double spacing,
    double padding,
    GameProvider provider,
  ) {
    final juice = _juiceKey.currentState;
    final x = padding + c * (cellSize + spacing) + cellSize / 2;
    final y = padding + r * (cellSize + spacing) + cellSize / 2;

    juice?.emitBurst(
      position: Offset(x, y),
      colors: CandyColors.candyPalette,
      particleCount: 22,
      emitShockwave: true,
    );
    juice?.triggerScreenShake(magnitude: 4.5);
    juice?.spawnFloatingText(
      position: Offset(x, y - 20),
      text: '🔨 SMASH !',
      color: CandyColors.lemonStar,
    );

    provider.applyHammer(r, c);
  }

  void _applyBombAt(
    int centerR,
    int centerC,
    double cellSize,
    double spacing,
    double padding,
    GameProvider provider,
  ) {
    final juice = _juiceKey.currentState;
    final x = padding + centerC * (cellSize + spacing) + cellSize / 2;
    final y = padding + centerR * (cellSize + spacing) + cellSize / 2;

    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        final pr = centerR + dr;
        final pc = centerC + dc;
        if (pr >= 0 && pr < BoardState.size && pc >= 0 && pc < BoardState.size) {
          final cx = padding + pc * (cellSize + spacing) + cellSize / 2;
          final cy = padding + pr * (cellSize + spacing) + cellSize / 2;
          juice?.emitBurst(
            position: Offset(cx, cy),
            colors: CandyColors.candyPalette,
            particleCount: 14,
            emitShockwave: dr == 0 && dc == 0,
          );
        }
      }
    }

    juice?.triggerScreenShake(magnitude: 8.0);
    juice?.spawnFloatingText(
      position: Offset(x, y - 30),
      text: '💣 BOOM !',
      color: CandyColors.tangerineOrange,
    );

    provider.applyBomb(centerR, centerC);
  }

  Widget _buildBoosterTargetBanner(GameProvider provider) {
    final isHammer = provider.activeBooster == ActiveBooster.hammer;
    final text = isHammer
        ? "🔨 Touchez un bonbon à écraser !"
        : "💣 Touchez la zone 3x3 à exploser !";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CandyColors.boardBorder, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF5D3600),
              fontWeight: FontWeight.w900,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => provider.cancelActiveBooster(),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final theme = settingsProvider.currentTheme;
    final isCandyTheme = theme.mode == GameThemeMode.sugarDelight;

    final screenSize = MediaQuery.of(context).size;
    final availableWidth = screenSize.width - 32.0;
    final availableHeight = screenSize.height * 0.48;
    final boardSize = (availableWidth < availableHeight ? availableWidth : availableHeight)
        .clamp(240.0, 420.0);
    const double padding = 10.0;
    const double spacing = 4.0;
    final cellSize = (boardSize - (padding * 2) - (spacing * 7)) / BoardState.size;

    // Déclencher les effets dès qu'un nouvel événement de destruction survient
    final clearEvent = gameProvider.lastClearEvent;
    if (clearEvent != null && clearEvent.timestamp != _lastHandledClearTimestamp) {
      _lastHandledClearTimestamp = clearEvent.timestamp;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleClearEffects(clearEvent, boardSize, cellSize, spacing, padding, isCandyTheme);
      });
    }

    return Center(
      child: JuiceOverlay(
        key: _juiceKey,
        child: SizedBox(
          width: boardSize,
          // Extension verticale invisible (+110px) pour que le doigt puisse descendre
          // sous le plateau lors de la pose sur les 3 dernières lignes sans déclencher onLeave
          height: boardSize + 110.0,
          child: DragTarget<Map<String, dynamic>>(
            hitTestBehavior: HitTestBehavior.translucent,
            onWillAcceptWithDetails: (details) => true,
            onMove: (details) {
              final shape = details.data['shape'] as BlockShape;
              final target = _calculateTargetCell(details.offset, boardSize, cellSize, spacing, padding, shape);
              if (target != null) {
                gameProvider.setDragPreview(shape, target.$1, target.$2);
              } else {
                gameProvider.setDragPreview(null, null, null);
              }
            },
            onLeave: (_) {
              gameProvider.setDragPreview(null, null, null);
            },
            onAcceptWithDetails: (details) {
              final shape = details.data['shape'] as BlockShape;
              final target = _calculateTargetCell(details.offset, boardSize, cellSize, spacing, padding, shape);
              if (target != null) {
                final pieceIndex = details.data['pieceIndex'] as int;
                gameProvider.tryPlacePiece(pieceIndex, target.$1, target.$2);
              }
            },
            builder: (context, candidateData, rejectedData) {
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    key: _boardKey,
                    width: boardSize,
                    height: boardSize,
                    padding: const EdgeInsets.all(padding),
                    decoration: isCandyTheme
                  ? BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF345B92),
                          Color(0xFF233E65),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: CandyColors.boardBorder,
                        width: 3.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x660F2648),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Color(0x33FFFFFF),
                          blurRadius: 4,
                          offset: Offset(0, -1),
                        ),
                      ],
                    )
                  : BoxDecoration(
                      color: theme.surfaceColor,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
              child: Builder(
                builder: (context) {
                  // Calcul des lignes/colonnes "presque pleines" (7/8 remplies) — lueur d'aperçu
                  final Set<int> nearFullRows = {};
                  final Set<int> nearFullCols = {};
                  final grid = gameProvider.board.grid;
                  for (int r = 0; r < BoardState.size; r++) {
                    int filled = 0;
                    for (int c = 0; c < BoardState.size; c++) {
                      if (grid[r][c] != 0) filled++;
                    }
                    if (filled >= BoardState.size - 1) nearFullRows.add(r);
                  }
                  for (int c = 0; c < BoardState.size; c++) {
                    int filled = 0;
                    for (int r = 0; r < BoardState.size; r++) {
                      if (grid[r][c] != 0) filled++;
                    }
                    if (filled >= BoardState.size - 1) nearFullCols.add(c);
                  }

                  // Grille construite manuellement (Column/Row) pour que les hitboxes
                  // correspondent EXACTEMENT au calcul pixel de _calculateTargetCell.
                  // GridView peut étirer les cellules et décaler le mapping tactile,
                  // rendant les 3 dernières lignes inaccessibles au drag-and-drop.
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(BoardState.size, (r) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(BoardState.size, (c) {
                          final rawColor = gameProvider.board.grid[r][c];
                          final isClearing = gameProvider.clearingRows.contains(r) ||
                              gameProvider.clearingCols.contains(c);
                          // Lueur subtile sur les blocs d'une ligne/colonne presque complète
                          final isNearComplete =
                              (nearFullRows.contains(r) || nearFullCols.contains(c)) &&
                              rawColor != 0;

                          // Ghost (aperçu de placement en cours)
                          bool isGhost = false;
                          bool isGhostValid = true;
                          if (gameProvider.previewShape != null &&
                              gameProvider.previewRow != null &&
                              gameProvider.previewCol != null) {
                            final pShape = gameProvider.previewShape!;
                            final pRow = gameProvider.previewRow!;
                            final pCol = gameProvider.previewCol!;
                            final dr = r - pRow;
                            final dc = c - pCol;
                            if (dr >= 0 && dr < pShape.rows && dc >= 0 && dc < pShape.cols) {
                              if (pShape.matrix[dr][dc] > 0) {
                                isGhost = true;
                                isGhostValid = gameProvider.isPreviewValid;
                              }
                            }
                          }

                          final double rightPadding = c < BoardState.size - 1 ? spacing : 0;
                          final double bottomPadding = r < BoardState.size - 1 ? spacing : 0;

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (gameProvider.activeBooster == ActiveBooster.hammer) {
                                _applyHammerAt(r, c, cellSize, spacing, padding, gameProvider);
                              } else if (gameProvider.activeBooster == ActiveBooster.bomb) {
                                _applyBombAt(r, c, cellSize, spacing, padding, gameProvider);
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: rightPadding,
                                bottom: bottomPadding,
                              ),
                              child: BoardCell(
                                colorIndex: rawColor,
                                isGhost: isGhost,
                                isGhostValid: isGhostValid,
                                isClearing: isClearing,
                                isNearComplete: isNearComplete,
                                theme: theme,
                                size: cellSize,
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  );
                },
              ),
            ),
            // Bannière de ciblage lorsque le marteau ou la bombe est actif
            if (gameProvider.activeBooster != ActiveBooster.none)
              Positioned(
                top: -46,
                left: 0,
                right: 0,
                child: Center(
                  child: _buildBoosterTargetBanner(gameProvider),
                ),
              ),
          ],
        );
      },
    ),
  ),
),
    );
  }

  (int, int)? _calculateTargetCell(
    Offset globalTouchPosition,
    double boardSize,
    double cellSize,
    double spacing,
    double padding,
    BlockShape shape,
  ) {
    final renderBox = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final localTouch = renderBox.globalToLocal(globalTouchPosition);
    final visualCenter = Offset(localTouch.dx, localTouch.dy + fingerVerticalOffset);

    // Dimensions exactes de la pièce avec espacement
    final pieceWidth = shape.cols * cellSize + (shape.cols - 1) * spacing;
    final pieceHeight = shape.rows * cellSize + (shape.rows - 1) * spacing;

    // Coin supérieur gauche de la pièce
    final pieceLeft = visualCenter.dx - pieceWidth / 2;
    final pieceTop = visualCenter.dy - pieceHeight / 2;

    final totalStep = cellSize + spacing;
    final col = ((pieceLeft - padding) / totalStep).round();
    final row = ((pieceTop - padding) / totalStep).round();

    if (row < 0 || row + shape.rows > BoardState.size ||
        col < 0 || col + shape.cols > BoardState.size) {
      return null;
    }
    return (row, col);
  }
}
