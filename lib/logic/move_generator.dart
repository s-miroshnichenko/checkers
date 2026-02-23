import '../models/board_state.dart';
import '../models/piece.dart';

/// Генератор ходов — вся логика правил шашек (чистый Dart, без Flutter).
class MoveGenerator {
  static const List<(int, int)> _allDiagonals = [
    (-1, -1), (-1, 1), (1, -1), (1, 1),
  ];

  /// Все допустимые ходы для указанного цвета.
  /// Если есть обязательные взятия — возвращает только их.
  static List<Move> getAllMoves(BoardState board, PieceColor color) {
    final captures = <Move>[];

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.grid[r][c];
        if (piece == null || piece.color != color) continue;
        captures.addAll(getCaptureSequences(board, r, c));
      }
    }

    // Обязательное взятие — если есть хоть одно, только взятия
    if (captures.isNotEmpty) return captures;

    // Иначе — обычные ходы
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

  /// Ходы для конкретной шашки на (r, c).
  static List<Move> getMovesForPiece(BoardState board, int r, int c) {
    final piece = board.grid[r][c];
    if (piece == null) return [];

    // Проверяем, есть ли у кого-то обязательные взятия
    final allCaptures = <Move>[];
    for (int rr = 0; rr < 8; rr++) {
      for (int cc = 0; cc < 8; cc++) {
        final p = board.grid[rr][cc];
        if (p == null || p.color != piece.color) continue;
        allCaptures.addAll(getCaptureSequences(board, rr, cc));
      }
    }

    if (allCaptures.isNotEmpty) {
      // Есть обязательные взятия — вернуть только взятия этой шашки
      return allCaptures.where((m) => m.fromR == r && m.fromC == c).toList();
    }

    return _getSimpleMoves(board, r, c, piece);
  }

  /// Есть ли у цвета обязательные взятия?
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

  /// Какими шашками можно ходить (учитывая обязательные взятия).
  static Set<(int, int)> getSelectablePieces(BoardState board, PieceColor color) {
    final Set<(int, int)> result = {};

    // Сначала проверяем, есть ли обязательные взятия
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

    // Нет взятий — все шашки с ходами
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

  // ─── Серии взятий (рекурсивный поиск) ────────────────────────

  /// Возвращает все полные серии взятий начиная с (r, c).
  /// Каждый Move содержит финальную позицию и ВСЕ сбитые шашки в серии.
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
    List<(int, int)> pathSoFar, // чтобы не возвращаться
    List<Move> results,
  ) {
    final jumps = _getSingleJumps(board, r, c, piece,
        alreadyCaptured: capturedSoFar);

    if (jumps.isEmpty) {
      // Конец серии — если что-то сбили, добавляем Move
      if (capturedSoFar.isNotEmpty) {
        results.add(Move(
          pathSoFar.first.$1, pathSoFar.first.$2, // from
          r, c, // to (текущая позиция)
          captured: List.of(capturedSoFar),
        ));
      }
      return;
    }

    for (final (landR, landC, enemyR, enemyC) in jumps) {
      // Симулируем прыжок
      // Распаковываем capturedSoFar, создаем новый массив с capturedSoFar and
      // (enemyR, enemyC)
      final newCaptured = [...capturedSoFar, (enemyR, enemyC)];
      final newPath = pathSoFar.isEmpty
          ? [(r, c), (landR, landC)]
          : [...pathSoFar, (landR, landC)];

      // Временно перемещаем шашку
      board.grid[landR][landC] = board.grid[r][c];
      board.grid[r][c] = null;
      final enemyPiece = board.grid[enemyR][enemyC];
      board.grid[enemyR][enemyC] = null;

      // Проверяем коронацию (в русских шашках дамка может продолжить серию)
      bool wasPromoted = false;
      if (piece.type == PieceType.man) {
        if ((piece.color == PieceColor.white && landR == 0) ||
            (piece.color == PieceColor.black && landR == 7)) {
          piece.type = PieceType.king;
          wasPromoted = true;
        }
      }

      // Рекурсивно ищем продолжения
      _buildCaptureChain(board, landR, landC, piece, newCaptured, newPath, results);

      // Откатываем
      if (wasPromoted) piece.type = PieceType.man;
      board.grid[r][c] = board.grid[landR][landC];
      board.grid[landR][landC] = null;
      board.grid[enemyR][enemyC] = enemyPiece;
    }
  }

  /// Одиночные прыжки (без серий) — возвращает (landR, landC, enemyR, enemyC).
  static List<(int, int, int, int)> _getSingleJumps(
    BoardState board,
    int r,
    int c,
    Piece piece, {
    // именованный параметр со значением по умолчанию. Можно вызвать так:
    // _getSingleJumps(board, r, c, piece, alreadyCaptured: [(1, 2)]);
    List<(int, int)> alreadyCaptured = const [],
  }) {
    final result = <(int, int, int, int)>[];

    if (piece.isKing) {
      for (final (rDir, cDir) in _allDiagonals) {
        int curR = r + rDir;
        int curC = c + cDir;

        // Пропускаем пустые клетки
        while (_isOnBoard(curR, curC) && board.grid[curR][curC] == null) {
          curR += rDir;
          curC += cDir;
        }

        // Нашли фигуру
        if (!_isOnBoard(curR, curC)) continue;
        final target = board.grid[curR][curC];
        if (target == null || target.color == piece.color) continue;
        if (alreadyCaptured.contains((curR, curC))) continue;

        // Все пустые клетки за ней — допустимые приземления
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

  // ─── Простые ходы ──────────────────────────────────────────────

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

  // ─── Утилиты ───────────────────────────────────────────────────

  static bool _isOnBoard(int r, int c) => r >= 0 && r < 8 && c >= 0 && c < 8;
}
