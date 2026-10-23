import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto_mobile/features/quiz/widgets/answer_card.dart';
import 'package:projeto_mobile/features/quiz/widgets/image_question.dart';
import 'package:projeto_mobile/features/quiz/widgets/result_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/widgets/game_card.dart';
import '../view model/quiz_view_model.dart';

class QuizPage extends ConsumerWidget {
  const QuizPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quiz = ref.watch(quizProvider);
    final vm = ref.read(quizProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar ao início',
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Missão 01 • Games'),
      ),
      body: quiz.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Não foi possível carregar a missão.'),
              FilledButton(
                onPressed: vm.restart,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        data: (state) => SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: state.finished
                    ? Result(state: state, onRestart: vm.restart)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pergunta ${state.index + 1} de ${state.questions.length}',
                              ),
                              Chip(
                                avatar: const Icon(
                                  Icons.bolt,
                                  color: AppTheme.purple,
                                ),
                                label: Text('${state.xp} XP'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: state.progress,
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(10),
                            semanticsLabel: 'Progresso da missão',
                          ),
                          const SizedBox(height: 32),
                          Text(
                            state.question.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.question.isImageQuestion
                                ? 'Toque na imagem. Você tem 3 tentativas.'
                                : 'Escolha uma alternativa para continuar.',
                          ),
                          const SizedBox(height: 24),
                          if (state.question.isImageQuestion)
                            ImageQuestion(
                              // A chave reinicia as tentativas a cada pergunta.
                              key: ValueKey(state.question.id),
                              question: state.question,
                              confirmed: state.confirmed,
                              onResult: (isCorrect) =>
                                  vm.answerImage(isCorrect: isCorrect),
                            )
                          else
                            for (
                              var i = 0;
                              i < state.question.options.length;
                              i++
                            )
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Answer(
                                  label: state.question.options[i],
                                  index: i,
                                  selected: state.selected == i,
                                  correct:
                                      state.confirmed &&
                                      state.question.correctIndex == i,
                                  wrong:
                                      state.confirmed &&
                                      state.selected == i &&
                                      state.question.correctIndex != i,
                                  onTap: state.confirmed
                                      ? null
                                      : () => vm.select(i),
                                ),
                              ),
                          if (state.confirmed) ...[
                            const SizedBox(height: 12),
                            GameCard(
                              color: const Color(0xFFECE4F6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.selected ==
                                            state.question.correctIndex
                                        ? 'Mandou bem! +20 XP ⚡'
                                        : 'Mais uma descoberta! 💡',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.question.explanation,
                                    style: const TextStyle(height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          // Na pergunta de imagem não há "Confirmar": a
                          // resposta vale assim que acerta ou acabam as tentativas.
                          if (state.confirmed ||
                              !state.question.isImageQuestion)
                            FilledButton(
                              onPressed: state.confirmed
                                  ? vm.next
                                  : state.selected == null
                                  ? null
                                  : vm.confirm,
                              child: Text(
                                state.confirmed
                                    ? (state.index == state.questions.length - 1
                                          ? 'Ver meu resultado'
                                          : 'Próxima pergunta')
                                    : 'Confirmar resposta',
                              ),
                            ),
                          const SizedBox(height: 16),
                          const Text(
                            'Sem pressa. O importante é aprender!',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
