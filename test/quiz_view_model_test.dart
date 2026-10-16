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
    for (var i = 0; i < 5; i++) {
      final question = container.read(quizProvider).requireValue.question;
      vm.select(i == 0 ? 0 : question.correctIndex);
      vm.confirm();
      vm.confirm();
      vm.select(0);
      vm.next();
    }
    final result = container.read(quizProvider).requireValue;
    expect(result.finished, isTrue);
    expect(result.xp, 80);
    expect(result.progress, 1);
    vm.restart();
    final restarted = await container.read(quizProvider.future);
    expect(restarted.xp, 0);
    expect(restarted.index, 0);
    expect(restarted.selected, isNull);
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
