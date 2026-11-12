import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../progress/model/learning_progress.dart';
import '../../progress/providers/learning_progress_provider.dart';
import '../../progress/repository/learning_metrics_repository.dart';

import '../model/snake_position_model.dart';
import '../model/snake_repository_model.dart';
import '../model/snake_state_model.dart';
import '../repository/local_snake_repository.dart';

final snakeRepositoryProvider = Provider<SnakeRepository>(
  (ref) => LocalSnakeRepository(),
);

final snakeProvider = NotifierProvider.autoDispose<SnakeViewModel, SnakeState>(
  SnakeViewModel.new,
);

class SnakeViewModel extends Notifier<SnakeState> {
  Timer? _timer;
  ActivitySession? _session;
  late LearningMetricsRepository _metrics;

  @override
  SnakeState build() {
    ref.watch(snakeRepositoryProvider);
    _metrics = ref.watch(learningMetricsRepositoryProvider);
    ref.onDispose(() {
      _cancelTimer();
      _session?.close();
    });
    return _initialState();
  }

  SnakeState _initialState({bool stepMode = false}) {
    const snake = [
      SnakePosition(7, 8),
      SnakePosition(6, 8),
      SnakePosition(5, 8),
    ];
    return SnakeState(
      snake: snake,
      stepMode: stepMode,
      food: ref
          .read(snakeRepositoryProvider)
          .createFood(boardSize: SnakeState.boardSize, snake: snake),
    );
  }

  void setStepMode(bool enabled) {
    if (state.status != SnakeStatus.ready) return;
    state = state.copyWith(stepMode: enabled);
  }

  void start() {
    if (state.status != SnakeStatus.ready) return;
    _session = _metrics.start(LearningActivity.snake);
    state = state.copyWith(status: SnakeStatus.playing);
    _startTimer();
  }

  void turn(SnakeDirection direction) {
    if (state.status != SnakeStatus.playing ||
        state.nextDirection != null ||
        direction.isOpposite(state.direction)) {
      return;
    }
    state = state.copyWith(nextDirection: direction);
    if (state.stepMode) tick();
  }

  void tick() {
    if (state.status != SnakeStatus.playing) return;
    final direction = state.nextDirection ?? state.direction;
    final head = SnakePosition(
      state.head.x + direction.dx,
      state.head.y + direction.dy,
    );
    final eating = head == state.food;
    // A cauda sai da posição atual neste passo, exceto ao comer.
    final body = eating
        ? state.snake
        : state.snake.take(state.snake.length - 1);
    if (head.x < 0 ||
        head.y < 0 ||
        head.x >= SnakeState.boardSize ||
        head.y >= SnakeState.boardSize ||
        body.contains(head)) {
      _cancelTimer();
      _session?.close(completed: true);
      state = state.copyWith(status: SnakeStatus.gameOver);
      return;
    }
    final snake = [head, ...state.snake];
    if (!eating) snake.removeLast();
    final food = eating
        ? ref
              .read(snakeRepositoryProvider)
              .createFood(boardSize: SnakeState.boardSize, snake: snake)
        : state.food;
    final won = food == null;
    _session?.score(state.score + (eating ? 10 : 0));
    if (won) _session?.close(completed: true);
    if (won) _cancelTimer();
    state = SnakeState(
      snake: snake,
      food: food,
      direction: direction,
      status: won ? SnakeStatus.won : SnakeStatus.playing,
      score: state.score + (eating ? 10 : 0),
      stepMode: state.stepMode,
    );
  }

  void pause() {
    if (state.status != SnakeStatus.playing) return;
    _cancelTimer();
    _session?.pause();
    state = state.copyWith(status: SnakeStatus.paused);
  }

  void resume() {
    if (state.status != SnakeStatus.paused) return;
    _session?.resume();
    state = state.copyWith(status: SnakeStatus.playing);
    _startTimer();
  }

  void togglePause() {
    if (state.status == SnakeStatus.playing) {
      pause();
    } else if (state.status == SnakeStatus.paused) {
      resume();
    }
  }

  void restart() {
    _cancelTimer();
    _session?.close();
    _session = null;
    state = _initialState(stepMode: state.stepMode);
  }

  void _startTimer() {
    _cancelTimer();
    if (!state.stepMode) {
      _timer = Timer.periodic(SnakeState.tickDuration, (_) => tick());
    }
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
