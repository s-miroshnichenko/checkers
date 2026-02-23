import 'piece.dart';

/// Represents the board state, purely isolated from Flutter UI dependencies.
/// This clean separation allows for efficient AI evaluation and testing.
class BoardState {
  List<List<Piece?>> grid;
  PieceColor turn;

  // Cached counters for quick evaluation by the AI.
  int whiteCount = 0;
  int blackCount = 0;
  int whiteKings = 0;
  int blackKings = 0;

  BoardState({required this.grid, required this.turn}) {
    _updateCounts();
  }

  /// Creates the initial board setup for a standard game of checkers.
  factory BoardState.initial() {
    final grid = List.generate(8, (_) => List<Piece?>.filled(8, null));

    // Black pieces occupy the top 3 rows.
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 8; c++) {
        if ((r + c) % 2 != 0) {
          grid[r][c] = Piece(color: PieceColor.black);
        }
      }
    }

    // White pieces occupy the bottom 3 rows.
    for (int r = 5; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if ((r + c) % 2 != 0) {
          grid[r][c] = Piece(color: PieceColor.white);
        }
      }
    }

    return BoardState(grid: grid, turn: PieceColor.white);
  }

  /// Creates a deep copy of the board state.
  /// Used to avoid mutating the visible board state during AI evaluation.
  BoardState clone() {
    final newGrid = List.generate(
      8,
      (r) => List.generate(8, (c) {
        final p = grid[r][c];
        return p?.copy(); // Ensure your Piece class has a .copy() method
      }),
    );
    return BoardState(grid: newGrid, turn: turn);
  }

  /// Applies a move, mutating the current object.
  void applyMove(Move move) {
    final piece = grid[move.fromR][move.fromC];
    if (piece == null) return;

    grid[move.toR][move.toC] = piece;
    grid[move.fromR][move.fromC] = null;

    // Remove captured pieces.
    for (final (r, c) in move.captured) {
      grid[r][c] = null;
    }

    // Handle piece promotion (kinging).
    if (piece.type == PieceType.man) {
      if ((piece.color == PieceColor.white && move.toR == 0) ||
          (piece.color == PieceColor.black && move.toR == 7)) {
        piece.type = PieceType.king;
      }
    }

    // Switch turns.
    turn = (turn == PieceColor.white) ? PieceColor.black : PieceColor.white;
    _updateCounts();
  }

  /// Returns the winning color, or null if the game is still ongoing.
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

/// Represents a single move on the board, including coordinates and any captured pieces.
class Move {
  final int fromR, fromC, toR, toC;
  final List<(int, int)> captured;

  const Move(
    this.fromR,
    this.fromC,
    this.toR,
    this.toC, {
    this.captured = const [],
  });
}