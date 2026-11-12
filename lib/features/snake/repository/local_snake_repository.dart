import 'dart:math';

import '../model/snake_position_model.dart';
import '../model/snake_repository_model.dart';

class LocalSnakeRepository implements SnakeRepository {
  LocalSnakeRepository({Random? random}) : _random = random ?? Random();

  final Random _random;

  @override
  SnakePosition? createFood({
    required int boardSize,
    required List<SnakePosition> snake,
  }) {
    final occupied = snake.toSet();
    final available = <SnakePosition>[
      for (var y = 0; y < boardSize; y++)
        for (var x = 0; x < boardSize; x++)
          if (!occupied.contains(SnakePosition(x, y))) SnakePosition(x, y),
    ];
    return available.isEmpty
        ? null
        : available[_random.nextInt(available.length)];
  }
}
