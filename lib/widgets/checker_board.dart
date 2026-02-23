import 'package:flutter/material.dart';

import '../logic/game_controller.dart';
import '../models/piece.dart';

class CheckerBoard extends StatelessWidget {
  final GameController controller;

  const CheckerBoard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to dynamically calculate the board size,
    // ensuring it remains proportionate regardless of screen dimensions.
    return LayoutBuilder(
      builder: (context, constraints) {
        final double boardSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        // Calculate border and shadow sizes relative to the board size
        // to maintain a consistent look across different devices.
        final double outerBorder = boardSize * 0.04;
        final double innerBorder = boardSize * 0.008;
        final double shadowBlur = boardSize * 0.008;

        // ListenableBuilder ensures that only the board is rebuilt when the game state changes,
        // optimizing performance by avoiding full screen rebuilds.
        return ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 194, 103, 6),
                  width: outerBorder,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 222, 190, 6),
                    width: innerBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: shadowBlur,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: AspectRatio(
                  aspectRatio: 1, // Enforces a square aspect ratio for the board
                  child: GridView.builder(
                    // Disable scrolling to prevent interference with piece interactions
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 64,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemBuilder: (context, index) {
                      int r = index ~/ 8;
                      int c = index % 8;
                      bool isDark = (r + c) % 2 != 0;

                      return GestureDetector(
                        onTap: () => _handleTap(context, r, c),
                        child: Container(
                          color: isDark
                              ? const Color.fromARGB(255, 130, 72, 18)
                              : const Color.fromARGB(255, 220, 220, 220),
                          child: Stack(
                            children: [
                              if (_isValidMove(r, c))
                                Center(
                                  child: Container(
                                    width: 15,
                                    height: 15,
                                    decoration: const BoxDecoration(
                                      color: Colors.greenAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              if (controller.state.grid[r][c] != null)
                                _buildPiece(controller.state.grid[r][c]!),
                              if (controller.selectedPosition?.$1 == r &&
                                  controller.selectedPosition?.$2 == c)
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.green,
                                      width: 3,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _isValidMove(int r, int c) {
    return controller.validMoves.any((m) => m.toR == r && m.toC == c);
  }

  void _handleTap(BuildContext context, int r, int c) {
    controller.handleTap(r, c);

    if (controller.state.isGameOver) {
      _showGameOverDialog(context);
    }
  }

  // Extracted dialog logic into a separate method for cleaner code
  void _showGameOverDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          controller.state.winner == PieceColor.white
              ? 'White Wins!'
              : 'Black Wins!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.reset();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildPiece(Piece piece) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          color: piece.color == PieceColor.white
              ? Colors.grey[100]
              : Colors.grey[900],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey, width: 2),
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              color: Colors.black45,
              offset: Offset(2, 2),
            )
          ],
        ),
        child: piece.isKing
            ? const Center(
                child: Icon(Icons.star, color: Colors.amber, size: 24),
              )
            : null,
      ),
    );
  }
}
