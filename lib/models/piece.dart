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

  // Чтобы ИИ не изменил фигуру на экране, когда обдумывал ход
  Piece copy() => Piece(color: color, type: type);
}