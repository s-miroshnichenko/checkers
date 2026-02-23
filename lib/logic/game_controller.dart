import 'package:flutter/material.dart';

import '../models/board_state.dart';
import '../models/piece.dart';
import '../models/game_mode.dart';
import '../ai/checkers_ai.dart';
import 'move_generator.dart';

/// A lightweight wrapper around [BoardState] for the Flutter UI.
/// Acts as the presentation layer (ViewModel) implementing [ChangeNotifier]
/// to keep the core game logic completely independent of the UI framework.
class GameController extends ChangeNotifier {
  BoardState state;
  final GameMode gameMode;

  // UI State
  (int, int)? selectedPosition;
  List<Move> validMoves = [];
  Set<(int, int)> selectablePieces = {};

  GameController({this.gameMode = GameMode.humanVsHuman})
      : state = BoardState.initial() {
    _refreshSelectable();
  }

  // --- Public Methods ---

  /// Handles a user tap on the board at row [r], column [c].
  void handleTap(int r, int c) {
    final move = _findMove(r, c);
    if (move != null) {
      _executeMove(move);
      return;
    }

    if (selectablePieces.contains((r, c))) {
      _selectPiece(r, c);
    }
  }

  /// Resets the game to its initial state.
  void reset() {
    state = BoardState.initial();
    selectedPosition = null;
    validMoves = [];
    _refreshSelectable();
    notifyListeners();
  }

  /// Initiates the AI move calculation.
  void makeComputerMove() {
    if (state.isGameOver) return;

    final ai = CheckersAI();
    final bestMove = ai.findBestMove(state);

    if (bestMove == null) return;
    _executeMove(bestMove);
  }

  // --- Private Helpers ---

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

    // Trigger AI turn with a slight delay for a better UX,
    // so the human player can see the board update first.
    if (gameMode == GameMode.humanVsComputer &&
        state.turn == PieceColor.black &&
        !state.isGameOver) {
      Future.delayed(const Duration(milliseconds: 500), () {
        makeComputerMove();
      });
    }
  }

  void _refreshSelectable() {
    selectablePieces = MoveGenerator.getSelectablePieces(state, state.turn);
  }
}
