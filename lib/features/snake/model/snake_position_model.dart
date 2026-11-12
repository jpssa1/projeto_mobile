class SnakePosition {
  const SnakePosition(this.x, this.y);

  final int x;
  final int y;

  @override
  bool operator ==(Object other) =>
      other is SnakePosition && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}

enum SnakeDirection {
  up(0, -1),
  right(1, 0),
  down(0, 1),
  left(-1, 0);

  const SnakeDirection(this.dx, this.dy);

  final int dx;
  final int dy;

  bool isOpposite(SnakeDirection other) => dx == -other.dx && dy == -other.dy;
}
