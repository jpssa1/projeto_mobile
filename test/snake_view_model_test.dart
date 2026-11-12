import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/features/snake/model/snake_position_model.dart';
import 'package:projeto_mobile/features/snake/model/snake_repository_model.dart';
import 'package:projeto_mobile/features/snake/model/snake_state_model.dart';
import 'package:projeto_mobile/features/snake/repository/local_snake_repository.dart';
import 'package:projeto_mobile/features/snake/view%20model/snake_view_model.dart';

class FixedFoodRepository implements SnakeRepository {
  FixedFoodRepository(this.food);

  final List<SnakePosition> food;
  int _index = 0;

  @override
  SnakePosition? createFood({
    required int boardSize,
    required List<SnakePosition> snake,
  }) => food[(_index++).clamp(0, food.length - 1)];
}

class AlmostFullSnakeViewModel extends SnakeViewModel {
  @override
  SnakeState build() {
    super.build();
    return SnakeState(
      snake: [
        const SnakePosition(7, 8),
        for (var y = 0; y < SnakeState.boardSize; y++)
          for (var x = 0; x < SnakeState.boardSize; x++)
            if (SnakePosition(x, y) != const SnakePosition(7, 8) &&
                SnakePosition(x, y) != const SnakePosition(8, 8))
              SnakePosition(x, y),
      ],
      food: const SnakePosition(8, 8),
      stepMode: true,
    );
  }
}

void main() {
  late ProviderContainer container;
  late SnakeViewModel vm;

  void createGame(List<SnakePosition> food, {bool stepMode = true}) {
    container = ProviderContainer(
      overrides: [
        snakeRepositoryProvider.overrideWithValue(FixedFoodRepository(food)),
      ],
    );
    addTearDown(container.dispose);
    container.listen(snakeProvider, (_, _) {});
    vm = container.read(snakeProvider.notifier);
    vm.setStepMode(stepMode);
  }

  SnakeState current() => container.read(snakeProvider);

  test('Não move antes de começar, cresce ao comer e soma 10 pontos', () {
    createGame([const SnakePosition(8, 8), const SnakePosition(0, 0)]);
    vm.tick();
    vm.turn(SnakeDirection.up);
    expect(current().head, const SnakePosition(7, 8));
    vm.start();
    vm.turn(SnakeDirection.right);
    expect(current().score, 10);
    expect(current().snake.length, 4);
    expect(current().head, const SnakePosition(8, 8));
    expect(current().food, const SnakePosition(0, 0));
    vm.tick();
    expect(current().score, 10);
    expect(current().snake.length, 4);
  });

  test('Bloqueia inversão e mais de uma mudança no mesmo intervalo', () {
    createGame([const SnakePosition(0, 0)], stepMode: false);
    vm.start();
    vm.turn(SnakeDirection.left);
    expect(current().nextDirection, isNull);
    vm.turn(SnakeDirection.up);
    vm.turn(SnakeDirection.left);
    vm.tick();
    expect(current().head, const SnakePosition(7, 7));
    expect(current().direction, SnakeDirection.up);
    vm.turn(SnakeDirection.left);
    vm.tick();
    expect(current().head, const SnakePosition(6, 7));
  });

  test('Pausa bloqueia comandos; continuar e reiniciar preservam o modo', () {
    createGame([const SnakePosition(8, 8), const SnakePosition(0, 0)]);
    vm.start();
    vm.turn(SnakeDirection.right);
    vm.pause();
    final paused = current();
    vm.turn(SnakeDirection.down);
    vm.tick();
    expect(current(), same(paused));
    vm.resume();
    vm.turn(SnakeDirection.down);
    expect(current().head, const SnakePosition(8, 9));
    vm.restart();
    expect(current().status, SnakeStatus.ready);
    expect(current().score, 0);
    expect(current().snake.length, 3);
    expect(current().stepMode, isTrue);
    expect(current().nextDirection, isNull);
  });

  test('Colisão com parede encerra e bloqueia novas jogadas e pontuação', () {
    createGame([const SnakePosition(0, 0)]);
    vm.start();
    for (var i = 0; i < SnakeState.boardSize; i++) {
      vm.tick();
    }
    expect(current().status, SnakeStatus.gameOver);
    expect(current().head.x, SnakeState.boardSize - 1);
    final ended = current();
    vm.turn(SnakeDirection.up);
    vm.tick();
    vm.resume();
    vm.start();
    expect(current(), same(ended));
  });

  test('Colisão com o corpo encerra o jogo', () {
    createGame([
      const SnakePosition(8, 8),
      const SnakePosition(8, 9),
      const SnakePosition(7, 9),
      const SnakePosition(0, 0),
    ]);
    vm.start();
    vm.turn(SnakeDirection.right);
    vm.turn(SnakeDirection.down);
    vm.turn(SnakeDirection.left);
    vm.turn(SnakeDirection.up);
    expect(current().status, SnakeStatus.gameOver);
    expect(current().score, 30);
  });

  test('Pode entrar na posição da cauda que sai no mesmo passo', () {
    createGame([const SnakePosition(8, 8), const SnakePosition(0, 0)]);
    vm.start();
    vm.turn(SnakeDirection.right);
    vm.turn(SnakeDirection.down);
    vm.turn(SnakeDirection.left);
    vm.turn(SnakeDirection.up);
    expect(current().status, SnakeStatus.playing);
    expect(current().head, const SnakePosition(7, 8));
  });

  test(
    'Comida ocupa somente casas livres e retorna null no tabuleiro cheio',
    () {
      final repository = LocalSnakeRepository(random: Random(42));
      final occupied = [
        const SnakePosition(0, 0),
        const SnakePosition(0, 1),
        const SnakePosition(1, 0),
      ];
      expect(
        repository.createFood(boardSize: 2, snake: occupied),
        const SnakePosition(1, 1),
      );
      expect(
        repository.createFood(
          boardSize: 2,
          snake: [...occupied, const SnakePosition(1, 1)],
        ),
        isNull,
      );
      for (var i = 0; i < 50; i++) {
        final food = repository.createFood(boardSize: 16, snake: occupied)!;
        expect(occupied.contains(food), isFalse);
        expect(food.x, inInclusiveRange(0, 15));
        expect(food.y, inInclusiveRange(0, 15));
      }
    },
  );

  test('Preencher o tabuleiro gera vitória sem tentar sortear comida', () {
    container = ProviderContainer(
      overrides: [snakeProvider.overrideWith(AlmostFullSnakeViewModel.new)],
    );
    addTearDown(container.dispose);
    container.listen(snakeProvider, (_, _) {});
    vm = container.read(snakeProvider.notifier);
    vm.start();
    vm.tick();
    expect(current().status, SnakeStatus.won);
    expect(current().food, isNull);
    expect(current().snake.length, 256);
    expect(current().score, 10);
  });
}
