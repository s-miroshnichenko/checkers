import '../models/board_state.dart';
import '../models/piece.dart';

/// Generates valid moves based on standard checkers rules.
/// Pure Dart logic, no Flutter dependencies.
class MoveGenerator {
  static const List<(int, int)> _allDiagonals = [
    (-1, -1), (-1, 1), (1, -1), (1, 1),
  ];

  /// Returns all valid moves for the specified [color].
  /// Enforces the mandatory capture rule: if captures are available, 
  /// only capture moves are returned.
  static List<Move> getAllMoves(BoardState board, PieceColor color) {
    final captures = <Move>[];

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.grid[r][c];
        if (piece == null || piece.color != color) continue;

        captures.addAll(getCaptureSequences(board, r, c));
      }
    }

    // Mandatory captures: if any capture is available, return only captures.
    if (captures.isNotEmpty) return captures;

    // Otherwise, calculate normal moves.
    final moves = <Move>[];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.grid[r][c];
        if (piece == null || piece.color != color) continue;

        moves.addAll(_getSimpleMoves(board, r, c, piece));
      }
    }

    return moves;
  }

  /// Returns all valid moves for a specific piece at ([r], [c]).
  static List<Move> getMovesForPiece(BoardState board, int r, int c) {
    final piece = board.grid[r][c];
    if (piece == null) return [];

    // Check globally if the player has any mandatory captures.
    final allCaptures = <Move>[];
    for (int rr = 0; rr < 8; rr++) {
      for (int cc = 0; cc < 8; cc++) {
        final p = board.grid[rr][cc];
        if (p == null || p.color != piece.color) continue;
        allCaptures.addAll(getCaptureSequences(board, rr, cc));
      }
    }

    if (allCaptures.isNotEmpty) {
      // If mandatory captures exist, return only the captures for this specific piece.
      return allCaptures.where((m) => m.fromR == r && m.fromC == c).toList();
    }

    return _getSimpleMoves(board, r, c, piece);
  }

  /// Checks if the given [color] has any mandatory captures available.
  static bool hasCaptures(BoardState board, PieceColor color) {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.grid[r][c];
        if (piece == null || piece.color != color) continue;
        if (_getSingleJumps(board, r, c, piece).isNotEmpty) return true;
      }
    }
    return false;
  }

  /// Returns a set of piece coordinates that are legally allowed to move.
  static Set<(int, int)> getSelectablePieces(BoardState board, PieceColor color) {
    final Set<(int, int)> result = {};

    // First, check for pieces that can capture.
    final Set<(int, int)> piecesWithCaptures = {};
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.grid[r][c];
        if (piece == null || piece.color != color) continue;
        if (_getSingleJumps(board, r, c, piece).isNotEmpty) {
          piecesWithCaptures.add((r, c));
        }
      }
    }

    if (piecesWithCaptures.isNotEmpty) return piecesWithCaptures;

    // No captures available, return all pieces with valid normal moves.
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.grid[r][c];
        if (piece == null || piece.color != color) continue;
        if (_getSimpleMoves(board, r, c, piece).isNotEmpty) {
          result.add((r, c));
        }
      }
    }

    return result;
  }

  // --- Capture Sequences (Recursive DFS) ---

  /// Returns all complete capture sequences starting from ([r], [c]).
  /// Each [Move] contains the final destination and ALL captured pieces in the sequence.
  static List<Move> getCaptureSequences(BoardState board, int r, int c) {
    final piece = board.grid[r][c];
    if (piece == null) return [];

    final results = <Move>[];
    _buildCaptureChain(board, r, c, piece, [], [], results);
    return results;
  }

  static void _buildCaptureChain(
    BoardState board,
    int r,
    int c,
    Piece piece,
    List<(int, int)> capturedSoFar,
    List<(int, int)> pathSoFar,
    List<Move> results,
  ) {
    final jumps = _getSingleJumps(board, r, c, piece, alreadyCaptured: capturedSoFar);

    if (jumps.isEmpty) {
      // End of sequence: if captures were made, register the full multi-jump move.
      if (capturedSoFar.isNotEmpty) {
        results.add(Move(
          pathSoFar.first.$1,
          pathSoFar.first.$2,
          r, c,
          captured: List.of(capturedSoFar),
        ));
      }
      return;
    }

    for (final (landR, landC, enemyR, enemyC) in jumps) {
      final newCaptured = [...capturedSoFar, (enemyR, enemyC)];
      final newPath = pathSoFar.isEmpty
          ? [(r, c), (landR, landC)]
          : [...pathSoFar, (landR, landC)];

      // Temporarily mutate the board state to simulate the jump.
      board.grid[landR][landC] = board.grid[r][c];
      board.grid[r][c] = null;
      final enemyPiece = board.grid[enemyR][enemyC];
      board.grid[enemyR][enemyC] = null;

      // Check for promotion. In Russian checkers, a newly promoted king 
      // can continue jumping in the same sequence.
      bool wasPromoted = false;
      if (piece.type == PieceType.man) {
        if ((piece.color == PieceColor.white && landR == 0) ||
            (piece.color == PieceColor.black && landR == 7)) {
          piece.type = PieceType.king;
          wasPromoted = true;
        }
      }

      // Recursively search for further jumps.
      _buildCaptureChain(board, landR, landC, piece, newCaptured, newPath, results);

      // Backtrack: restore the board state for the next iteration.
      if (wasPromoted) piece.type = PieceType.man;
      board.grid[r][c] = board.grid[landR][landC];
      board.grid[landR][landC] = null;
      board.grid[enemyR][enemyC] = enemyPiece;
    }
  }

  /// Finds single jump opportunities. 
  /// Returns a list of tuples containing (landR, landC, enemyR, enemyC).
  static List<(int, int, int, int)> _getSingleJumps(
    BoardState board,
    int r,
    int c,
    Piece piece, {
    List<(int, int)> alreadyCaptured = const [],
  }) {
    final result = <(int, int, int, int)>[];

    if (piece.isKing) {
      for (final (rDir, cDir) in _allDiagonals) {
        int curR = r + rDir;
        int curC = c + cDir;

        // Skip empty squares.
        while (_isOnBoard(curR, curC) && board.grid[curR][curC] == null) {
          curR += rDir;
          curC += cDir;
        }

        if (!_isOnBoard(curR, curC)) continue;

        // Found a piece, check if it's an enemy.
        final target = board.grid[curR][curC];
        if (target == null || target.color == piece.color) continue;
        if (alreadyCaptured.contains((curR, curC))) continue;

        // All empty squares behind the captured piece are valid landing spots.
        int landR = curR + rDir;
        int landC = curC + cDir;
        while (_isOnBoard(landR, landC) && board.grid[landR][landC] == null) {
          result.add((landR, landC, curR, curC));
          landR += rDir;
          landC += cDir;
        }
      }
    } else {
      for (final (rDir, cDir) in _allDiagonals) {
        int midR = r + rDir;
        int midC = c + cDir;
        int jumpR = r + rDir * 2;
        int jumpC = c + cDir * 2;

        if (_isOnBoard(jumpR, jumpC) &&
            board.grid[jumpR][jumpC] == null &&
            board.grid[midR][midC] != null &&
            board.grid[midR][midC]!.color != piece.color &&
            !alreadyCaptured.contains((midR, midC))) {
          result.add((jumpR, jumpC, midR, midC));
        }
      }
    }

    return result;
  }

  // --- Simple Moves ---

  static List<Move> _getSimpleMoves(BoardState board, int r, int c, Piece piece) {
    final result = <Move>[];

    if (piece.isKing) {
      for (final (rDir, cDir) in _allDiagonals) {
        int newR = r + rDir;
        int newC = c + cDir;

        while (_isOnBoard(newR, newC) && board.grid[newR][newC] == null) {
          result.add(Move(r, c, newR, newC));
          newR += rDir;
          newC += cDir;
        }
      }
    } else {
      int forward = piece.color == PieceColor.white ? -1 : 1;
      for (int cDir in [-1, 1]) {
        int newR = r + forward;
        int newC = c + cDir;

        if (_isOnBoard(newR, newC) && board.grid[newR][newC] == null) {
          result.add(Move(r, c, newR, newC));
        }
      }
    }

    return result;
  }

  // --- Utilities ---

  static bool _isOnBoard(int r, int c) => r >= 0 && r < 8 && c >= 0 && c < 8;
}
