import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/widgets/game_card.dart';
import '../model/snake_position_model.dart';
import '../model/snake_state_model.dart';
import '../view model/snake_view_model.dart';
import '../widgets/snake_board.dart';
import '../widgets/snake_controls.dart';

class SnakePage extends ConsumerStatefulWidget {
  const SnakePage({super.key});

  @override
  ConsumerState<SnakePage> createState() => _SnakePageState();
}

class _SnakePageState extends ConsumerState<SnakePage>
    with WidgetsBindingObserver {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      ref.read(snakeProvider.notifier).pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(snakeProvider);
    final vm = ref.read(snakeProvider.notifier);
    final playing = state.status == SnakeStatus.playing;
    final ready = state.status == SnakeStatus.ready;
    final score = Semantics(
      liveRegion: true,
      child: Chip(
        avatar: const Icon(Icons.stars_rounded, color: AppTheme.purple),
        label: Text('${state.score} pontos'),
      ),
    );
    final message = switch (state.status) {
      SnakeStatus.ready => 'Vamos jogar?',
      SnakeStatus.playing =>
        state.stepMode
            ? 'Cada comando move uma casa.'
            : 'Pegue a comida e continue crescendo!',
      SnakeStatus.paused => 'Jogo pausado. Continue quando quiser.',
      SnakeStatus.gameOver => 'Fim de jogo! Você fez ${state.score} pontos.',
      SnakeStatus.won => 'Você venceu! O tabuleiro está completo.',
    };

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
            vm.turn(SnakeDirection.up),
        const SingleActivator(LogicalKeyboardKey.keyW): () =>
            vm.turn(SnakeDirection.up),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            vm.turn(SnakeDirection.right),
        const SingleActivator(LogicalKeyboardKey.keyD): () =>
            vm.turn(SnakeDirection.right),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            vm.turn(SnakeDirection.down),
        const SingleActivator(LogicalKeyboardKey.keyS): () =>
            vm.turn(SnakeDirection.down),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            vm.turn(SnakeDirection.left),
        const SingleActivator(LogicalKeyboardKey.keyA): () =>
            vm.turn(SnakeDirection.left),
        const SingleActivator(LogicalKeyboardKey.keyP): vm.togglePause,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Voltar ao início',
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text('Jogo da cobrinha'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (ready) ...[
                        Semantics(
                          header: true,
                          child: Text(
                            'Pequena cobrinha,\ngrande desafio.',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          score,
                          if (ready || state.ended)
                            Chip(label: Text('${state.snake.length} segmentos'))
                          else
                            FilledButton.icon(
                              onPressed: vm.togglePause,
                              icon: Icon(
                                playing
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                              label: Text(
                                playing ? 'Pausar jogo' : 'Continuar jogo',
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (ready) ...[
                        const GameCard(
                          child: Text(
                            'Guie a cobrinha até o losango vermelho. Cada comida vale 10 pontos. '
                            'Evite as paredes e o próprio corpo. A cobrinha não pode voltar na direção contrária.',
                            style: TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Jogar no meu ritmo'),
                          subtitle: const Text(
                            'Move uma casa por comando, sem movimento automático.',
                          ),
                          value: state.stepMode,
                          onChanged: vm.setStepMode,
                        ),
                        const SizedBox(height: 12),
                      ],
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          message,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (ready || state.ended)
                        FilledButton.icon(
                          onPressed: () {
                            _scrollController.jumpTo(0);
                            state.ended ? vm.restart() : vm.start();
                          },
                          icon: Icon(
                            state.ended
                                ? Icons.replay_rounded
                                : Icons.play_arrow_rounded,
                          ),
                          label: Text(
                            state.ended ? 'Jogar novamente' : 'Começar jogo',
                          ),
                        ),
                      const SizedBox(height: 16),
                      SnakeBoard(state: state),
                      const SizedBox(height: 16),
                      if (state.stepMode && !state.ended && !ready) ...[
                        OutlinedButton.icon(
                          onPressed: playing ? vm.tick : null,
                          icon: const Icon(Icons.skip_next_rounded),
                          label: const Text('Avançar um passo'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 52),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      SnakeControls(enabled: playing, onDirection: vm.turn),
                      const SizedBox(height: 16),
                      const Text(
                        'Use os botões, as setas do teclado ou WASD. P pausa ou continua o jogo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(height: 1.5, color: Color(0xFF615971)),
                      ),
                      if (!ready && !state.ended) ...[
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () {
                            _scrollController.jumpTo(0);
                            vm.restart();
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reiniciar jogo'),
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
