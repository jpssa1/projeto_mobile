import 'snake_position_model.dart';

abstract interface class SnakeRepository {
  SnakePosition? createFood({
    required int boardSize,
    required List<SnakePosition> snake,
  });
}
