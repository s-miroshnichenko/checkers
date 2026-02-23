import 'piece.dart';

/// Чистое состояние доски (без Flutter-зависимостей).
class BoardState {
  List<List<Piece?>> grid;
  PieceColor turn;

  // Кэшированные счётчики для быстрой оценки
  int whiteCount = 0;
  int blackCount = 0;
  int whiteKings = 0;
  int blackKings = 0;

  BoardState({required this.grid, required this.turn}) {
    _updateCounts();
  }

  /// Начальная расстановка шашек.
  factory BoardState.initial() {
    final grid = List.generate(8, (_) => List<Piece?>.filled(8, null));

    // Чёрные — верхние 3 ряда
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 8; c++) {
        if ((r + c) % 2 != 0) {
          grid[r][c] = Piece(color: PieceColor.black);
        }
      }
    }

    // Белые — нижние 3 ряда
    for (int r = 5; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if ((r + c) % 2 != 0) {
          grid[r][c] = Piece(color: PieceColor.white);
        }
      }
    }

    return BoardState(grid: grid, turn: PieceColor.white);
  }

  /// Глубокая копия состояния.
  BoardState clone() {
    final newGrid = List.generate(
      8,
      (r) => List.generate(8, (c) {
        final p = grid[r][c];
        return p?.copy();
      }),
    );
    return BoardState(grid: newGrid, turn: turn);
  }

  /// Применяет ход (мутирует текущий объект).
  void applyMove(Move move) {
    final piece = grid[move.fromR][move.fromC];
    if (piece == null) return;

    // Перемещаем шашку
    grid[move.toR][move.toC] = piece;
    grid[move.fromR][move.fromC] = null;

    // Удаляем все сбитые шашки
    for (final (r, c) in move.captured) {
      grid[r][c] = null;
    }

    // Коронация
    if (piece.type == PieceType.man) {
      if ((piece.color == PieceColor.white && move.toR == 0) ||
          (piece.color == PieceColor.black && move.toR == 7)) {
        piece.type = PieceType.king;
      }
    }

    // Передаём ход
    turn = (turn == PieceColor.white) ? PieceColor.black : PieceColor.white;

    _updateCounts();
  }

  /// Победитель (null если игра продолжается).
  PieceColor? get winner {
    if (whiteCount == 0) return PieceColor.black;
    if (blackCount == 0) return PieceColor.white;
    return null;
  }

  bool get isGameOver => winner != null;

  void _updateCounts() {
    whiteCount = 0;
    blackCount = 0;
    whiteKings = 0;
    blackKings = 0;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = grid[r][c];
        if (p == null) continue;
        if (p.color == PieceColor.white) {
          whiteCount++;
          if (p.isKing) whiteKings++;
        } else {
          blackCount++;
          if (p.isKing) blackKings++;
        }
      }
    }
  }
}

/// Ход: откуда, куда, список сбитых координат.
class Move {
  final int fromR, fromC, toR, toC;
  final List<(int, int)> captured;

  const Move(this.fromR, this.fromC, this.toR, this.toC,
      {this.captured = const []});
}
