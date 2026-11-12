import 'snake_position_model.dart';

enum SnakeStatus { ready, playing, paused, gameOver, won }

class SnakeState {
  SnakeState({
    required List<SnakePosition> snake,
    required this.food,
    this.direction = SnakeDirection.right,
    this.nextDirection,
    this.status = SnakeStatus.ready,
    this.score = 0,
    this.stepMode = false,
  }) : snake = List.unmodifiable(snake);

  static const boardSize = 16;
  static const tickDuration = Duration(milliseconds: 280);

  final List<SnakePosition> snake;
  final SnakePosition? food;
  final SnakeDirection direction;
  final SnakeDirection? nextDirection;
  final SnakeStatus status;
  final int score;
  final bool stepMode;

  SnakePosition get head => snake.first;
  bool get ended => status == SnakeStatus.gameOver || status == SnakeStatus.won;

  SnakeState copyWith({
    SnakeStatus? status,
    bool? stepMode,
    SnakeDirection? nextDirection,
  }) => SnakeState(
    snake: snake,
    food: food,
    direction: direction,
    nextDirection: nextDirection ?? this.nextDirection,
    status: status ?? this.status,
    score: score,
    stepMode: stepMode ?? this.stepMode,
  );
}
