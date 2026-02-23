enum PieceType { man, king }
enum PieceColor { white, black }

class Piece {
  final PieceColor color;
  PieceType type;

  Piece({
    required this.color,
    this.type = PieceType.man,
  });

  bool get isKing => type == PieceType.king;

  // To prevent the AI from updating the UI while calculating a move.
  Piece copy() => Piece(color: color, type: type);
}