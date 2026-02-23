import '../models/board_state.dart';
import '../models/piece.dart';
import '../logic/move_generator.dart';

/// Minimax с Alpha-Beta отсечением для шашек.
/// Работает только с BoardState + MoveGenerator (без Flutter).
class CheckersAI {
  static const int _defaultDepth = 5;

  /// Возвращает лучший ход для текущего игрока.
  Move? findBestMove(BoardState board, {int depth = _defaultDepth}) {
    final color = board.turn;
    final allMoves = MoveGenerator.getAllMoves(board, color);
    if (allMoves.isEmpty) return null;

    Move? bestMove;
    double bestScore = double.negativeInfinity;

    for (final move in allMoves) {
      final sim = board.clone();
      sim.applyMove(move);
      final score = _minimax(
          sim, depth - 1, double.negativeInfinity, double.infinity, false, color);
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  // ─── Minimax ─────────────────────────────────────────────────

  double _minimax(
    BoardState board,
    int depth,
    double alpha,
    double beta,
    bool isMaximizing,
    PieceColor aiColor,
  ) {
    if (depth == 0 || board.isGameOver) {
      return _evaluate(board, aiColor);
    }

    final color = isMaximizing ? aiColor : _opponent(aiColor);
    final allMoves = MoveGenerator.getAllMoves(board, color);

    if (allMoves.isEmpty) {
      return isMaximizing ? -1000.0 : 1000.0;
    }

    if (isMaximizing) {
      double maxEval = double.negativeInfinity;
      for (final move in allMoves) {
        final sim = board.clone();
        sim.applyMove(move);
        final eval =
            _minimax(sim, depth - 1, alpha, beta, false, aiColor);
        if (eval > maxEval) maxEval = eval;
        if (eval > alpha) alpha = eval;
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      double minEval = double.infinity;
      for (final move in allMoves) {
        final sim = board.clone();
        sim.applyMove(move);
        final eval =
            _minimax(sim, depth - 1, alpha, beta, true, aiColor);
        if (eval < minEval) minEval = eval;
        if (eval < beta) beta = eval;
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  // ─── Оценка позиции ──────────────────────────────────────────

  double _evaluate(BoardState board, PieceColor aiColor) {
    double score = 0;
    final opponent = _opponent(aiColor);

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.grid[r][c];
        if (piece == null) continue;

        double value = piece.isKing ? 3.0 : 1.0;

        // Бонус за продвижение
        if (!piece.isKing) {
          if (piece.color == PieceColor.white) {
            value += (7 - r) * 0.1;
          } else {
            value += r * 0.1;
          }
        }

        // Бонус за центр
        if (c >= 2 && c <= 5 && r >= 2 && r <= 5) {
          value += 0.05;
        }

        score += (piece.color == aiColor) ? value : -value;
      }
    }

    // Победа/проигрыш
    final winner = board.winner;
    if (winner == aiColor) score += 500;
    if (winner == opponent) score -= 500;

    return score;
  }

  PieceColor _opponent(PieceColor color) =>
      color == PieceColor.white ? PieceColor.black : PieceColor.white;
}
