import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/features/quiz/view%20model/quiz_view_model.dart';
import 'package:projeto_mobile/features/quiz/model/quiz_repository_model.dart';
import 'package:projeto_mobile/features/quiz/model/question_model.dart';

class FailingRepository implements QuizRepository {
  @override
  Future<List<Question>> loadQuestions() async => throw Exception('offline');
}

void main() {
  test('Fluxo completo, sem pontuação duplicada, e reinício', () async {
    final container = ProviderContainer(retry: (_, _) => null);
    addTearDown(container.dispose);
    container.listen(quizProvider, (_, _) {});
    await container.read(quizProvider.future);
    final vm = container.read(quizProvider.notifier);
    vm.confirm();
    vm.next();
    expect(container.read(quizProvider).requireValue.index, 0);
    for (var i = 0; i < 6; i++) {
      final question = container.read(quizProvider).requireValue.question;
      vm.select(i == 0 ? 0 : question.correctIndex);
      vm.confirm();
      vm.confirm();
      vm.select(0);
      vm.next();
    }
    final result = container.read(quizProvider).requireValue;
    expect(result.finished, isTrue);
    expect(result.xp, 100);
    expect(result.progress, 1);
    vm.restart();
    final restarted = await container.read(quizProvider.future);
    expect(restarted.xp, 0);
    expect(restarted.index, 0);
    expect(restarted.selected, isNull);
  });
  test(
    'Pergunta de imagem: acerto vale XP e a segunda resposta é ignorada',
    () async {
      final container = ProviderContainer(retry: (_, _) => null);
      addTearDown(container.dispose);
      container.listen(quizProvider, (_, _) {});
      await container.read(quizProvider.future);
      final vm = container.read(quizProvider.notifier);
      // Vai até a última pergunta (a de imagem) errando todas as outras.
      for (var i = 0; i < 5; i++) {
        final q = container.read(quizProvider).requireValue.question;
        vm.select((q.correctIndex + 1) % q.options.length);
        vm.confirm();
        vm.next();
      }
      var state = container.read(quizProvider).requireValue;
      expect(state.question.isImageQuestion, isTrue);
      expect(state.xp, 0);
      vm.answerImage(isCorrect: true);
      state = container.read(quizProvider).requireValue;
      expect(state.confirmed, isTrue);
      expect(state.selected, state.question.correctIndex);
      expect(state.xp, 20);
      vm.answerImage(isCorrect: false); // ignorada: já foi respondida
      expect(container.read(quizProvider).requireValue.xp, 20);
    },
  );
  test('Pergunta de imagem: erro não dá XP', () async {
    final container = ProviderContainer(retry: (_, _) => null);
    addTearDown(container.dispose);
    container.listen(quizProvider, (_, _) {});
    await container.read(quizProvider.future);
    final vm = container.read(quizProvider.notifier);
    for (var i = 0; i < 5; i++) {
      vm.select(0);
      vm.confirm();
      vm.next();
    }
    final before = container.read(quizProvider).requireValue.xp;
    vm.answerImage(isCorrect: false);
    final state = container.read(quizProvider).requireValue;
    expect(state.confirmed, isTrue);
    expect(state.selected, isNot(state.question.correctIndex));
    expect(state.xp, before);
  });
  test('Falha do repositório é exposta como erro', () async {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        quizRepositoryProvider.overrideWithValue(FailingRepository()),
      ],
    );
    addTearDown(container.dispose);
    container.listen(quizProvider, (_, _) {});
    await expectLater(container.read(quizProvider.future), throwsException);
    expect(container.read(quizProvider).hasError, isTrue);
  });
}
