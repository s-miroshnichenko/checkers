import 'package:flutter/material.dart';
import '../models/board_state.dart';
import '../models/piece.dart';
import '../models/game_mode.dart';
import '../ai/checkers_ai.dart';
import 'move_generator.dart';

/// Тонкая обёртка над BoardState для Flutter UI.
/// Единственный класс, который знает о Flutter (ChangeNotifier).
class GameController extends ChangeNotifier {
  BoardState state;
  final GameMode gameMode;

  // UI-состояние
  (int, int)? selectedPosition;
  List<Move> validMoves = [];
  Set<(int, int)> selectablePieces = {};

  // gameMode в списке параметров, потому что его можно получить извне.
  // state - в списке инициализации, потому что класс задает его сам. 
  GameController({this.gameMode = GameMode.humanVsHuman})
      : state = BoardState.initial() {
    // state нельзя объявить в теле конструктора, потому что BoardState state
    // не nullable, а значит должен быть инициализирован до того как
    // тело конструктора начнет выполняться. 
    _refreshSelectable();
  }

  // ─── Публичные методы ─────────────────────────────────────────

  /// Обрабатывает тап по клетке (r, c).
  void handleTap(int r, int c) {
    // Если нажали на допустимый ход — выполняем его
    final move = _findMove(r, c);
    if (move != null) {
      _executeMove(move);
      return;
    }

    // Иначе пробуем выбрать шашку
    if (selectablePieces.contains((r, c))) {
      _selectPiece(r, c);
    }
  }

  /// Сброс: новая игра.
  void reset() {
    state = BoardState.initial();
    selectedPosition = null;
    validMoves = [];
    _refreshSelectable();
    notifyListeners();
  }

  /// Ход компьютера (вызывается автоматически при смене хода).
  void makeComputerMove() {
    if (state.isGameOver) return;

    final ai = CheckersAI();
    final bestMove = ai.findBestMove(state);
    if (bestMove == null) return;

    _executeMove(bestMove);
  }

  // ─── Приватные методы ─────────────────────────────────────────

  void _selectPiece(int r, int c) {
    selectedPosition = (r, c);
    validMoves = MoveGenerator.getMovesForPiece(state, r, c);
    notifyListeners();
  }

  Move? _findMove(int r, int c) {
    for (final move in validMoves) {
      if (move.toR == r && move.toC == c) return move;
    }
    return null;
  }

  void _executeMove(Move move) {
    state.applyMove(move);
    selectedPosition = null;
    validMoves = [];
    _refreshSelectable();
    notifyListeners();

    // Если ход компьютера — с задержкой
    if (gameMode == GameMode.humanVsComputer &&
        state.turn == PieceColor.black &&
        !state.isGameOver) {
      Future.delayed(const Duration(milliseconds: 500), () {
        makeComputerMove();
      });
    }
  }

  void _refreshSelectable() {
    selectablePieces =
        MoveGenerator.getSelectablePieces(state, state.turn);
  }
}
