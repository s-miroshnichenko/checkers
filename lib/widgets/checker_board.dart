import 'package:flutter/material.dart';
import '../logic/game_controller.dart';
import '../models/piece.dart';

class CheckerBoard extends StatelessWidget {
  final GameController controller;

  const CheckerBoard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder даёт нам доступный размер, чтобы рамки были
    // пропорциональны размеру доски
    return LayoutBuilder(
      builder: (context, constraints) {
        // Берём минимальную сторону (доска квадратная)
        final double boardSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        // Толщины рамок как доля от размера доски
        final double outerBorder = boardSize * 0.04;  // ~4%
        final double innerBorder = boardSize * 0.008; // ~0.8%
        final double shadowBlur = boardSize * 0.008;  // ~0.8%

        // ListenableBuilder следит за изменениями в game (ChangeNotifier)
        // и перерисовывает доску при вызове notifyListeners()
        return ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: const Color.fromARGB(255, 194, 103, 6),
                    width: outerBorder),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 222, 190, 6),
                      width: innerBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: shadowBlur,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: AspectRatio(
                  aspectRatio: 1, // Квадратная доска
                  child: GridView.builder(
                    // Отключаем скролл внутри доски, чтобы не было эффекта прокрутки
                    // при свайпе
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 64,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    // Эта функция вызывается 64 раза. 
                    // index - это индекс ячейки от 0 до 63
                    itemBuilder: (context, index) {
                      int r = index ~/ 8;
                      int c = index % 8;
                      bool isDark = (r + c) % 2 != 0;

                      return GestureDetector(
                        onTap: () {
                          _handleTap(context, r, c);
                        },
                        child: Container(
                          color: isDark
                              ? const Color.fromARGB(255, 130, 72, 18)
                              : const Color.fromARGB(255, 220, 220, 220),
                          child: Stack(
                            children: [
                              // Подсветка доступных ходов
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

                              // Шашка
                              if (controller.state.grid[r][c] != null)
                                _buildPiece(controller.state.grid[r][c]!),

                              // Подсветка выбранной клетки
                              if (controller.selectedPosition?.$1 == r &&
                                  controller.selectedPosition?.$2 == c)
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.green, width: 3),
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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(controller.state.winner == PieceColor.white
              ? 'Белые победили!'
              : 'Черные победили!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.reset();
              },
              child: const Text('ОК'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPiece(Piece piece) {
    return Padding(
      padding: const EdgeInsets.all(4.0), // Отступ, чтобы шашка не прилипала к краям
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
                offset: Offset(2, 2))
          ],
        ),
        child: piece.isKing
            ? const Center(
                child: Icon(Icons.star, color: Colors.amber, size: 24))
            : null,
      ),
    );
  }
}
