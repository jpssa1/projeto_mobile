import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projeto_mobile/features/progress/model/learning_progress.dart';
import 'package:projeto_mobile/features/progress/providers/learning_progress_provider.dart';
import 'package:projeto_mobile/features/progress/repository/learning_metrics_repository.dart';
import 'package:projeto_mobile/features/quiz/view%20model/quiz_view_model.dart';
import 'package:projeto_mobile/features/snake/view%20model/snake_view_model.dart';
import 'package:projeto_mobile/features/snake/model/snake_position_model.dart';
import 'package:projeto_mobile/features/snake/model/snake_repository_model.dart';

class PredictableFood implements SnakeRepository {
  int _calls = 0;
  @override
  SnakePosition? createFood({
    required int boardSize,
    required List<SnakePosition> snake,
  }) => _calls++ == 0 ? const SnakePosition(8, 8) : const SnakePosition(0, 0);
}

class FailingStorage implements MetricsStorage {
  bool fail = true;
  @override
  String? read() => null;
  @override
  Future<void> write(String data) async {
    if (fail) throw StateError('storage unavailable');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Tempo exclui pausa, fechamento é idempotente e dados são restaurados',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storage = PreferencesMetricsStorage(
        await SharedPreferences.getInstance(),
      );
      var now = 0;
      final repository = LearningMetricsRepository(
        storage: storage,
        now: () => now,
      );
      addTearDown(repository.dispose);
      final session = repository.start(LearningActivity.quiz);
      now = 12000;
      session.answer(topic: 'Game design', correct: false);
      session.pause();
      now = 112000;
      session.checkpoint();
      session.resume();
      now = 120000;
      session.answer(topic: 'Game design', correct: true);
      session.score(20);
      session.score(20);
      session.close(completed: true);
      session.close(completed: true);
      now = 150000;
      session.checkpoint();
      await repository.saved;

      // Uma nova instância lê os dados gravados, como ao reabrir o app.
      final restored = LearningMetricsRepository(storage: storage);
      addTearDown(restored.dispose);
      final metrics = restored.progress.activity(LearningActivity.quiz);
      expect(metrics.activeMilliseconds, 20000);
      expect(metrics.attempts, 1);
      expect(metrics.completed, 1);
      expect(metrics.bestScore, 20);
      expect(metrics.totalScore, 20);
      expect(restored.progress.topics['Game design']!.errors, 1);
      expect(restored.progress.topics['Game design']!.correct, 1);
    },
  );

  test(
    'Quiz guarda erros intermediários, evita duplicação e acumula reinícios',
    () async {
      final repository = LearningMetricsRepository();
      final container = ProviderContainer(
        overrides: [
          learningMetricsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);
      final subscription = container.listen(quizProvider, (_, _) {});
      await container.read(quizProvider.future);
      final vm = container.read(quizProvider.notifier);
      for (var i = 0; i < 5; i++) {
        final question = container.read(quizProvider).requireValue.question;
        vm.select(question.correctIndex);
        vm.confirm();
        vm.confirm();
        vm.next();
      }
      vm.recordImageRetry();
      vm.recordImageRetry();
      vm.answerImage(isCorrect: true);
      vm.answerImage(isCorrect: true);
      vm.recordImageRetry();
      vm.next();
      vm.next();
      expect(repository.progress.answers, 8);
      expect(repository.progress.errors, 2);
      expect(
        repository.progress.topicsByErrors.first.key,
        'Narrativa ambiental',
      );
      expect(repository.progress.activity(LearningActivity.quiz).completed, 1);
      expect(
        repository.progress.activity(LearningActivity.quiz).totalScore,
        120,
      );

      vm.restart();
      await container.read(quizProvider.future);
      expect(repository.progress.activity(LearningActivity.quiz).attempts, 2);
      vm.select(0);
      vm.confirm();
      subscription.close();
      await container.pump();
      expect(repository.progress.errors, 3);
      expect(repository.progress.activity(LearningActivity.quiz).completed, 1);
    },
  );

  test('Cobrinha conta partidas somente ao começar e desconta pausa', () async {
    var now = 0;
    final repository = LearningMetricsRepository(now: () => now);
    final container = ProviderContainer(
      overrides: [
        learningMetricsRepositoryProvider.overrideWithValue(repository),
        snakeRepositoryProvider.overrideWithValue(PredictableFood()),
      ],
    );
    addTearDown(repository.dispose);
    addTearDown(container.dispose);
    final subscription = container.listen(snakeProvider, (_, _) {});
    final vm = container.read(snakeProvider.notifier);
    vm.setStepMode(true);
    expect(repository.progress.activity(LearningActivity.snake).attempts, 0);
    vm.start();
    vm.start();
    now = 3000;
    vm.pause();
    now = 103000;
    vm.resume();
    now = 105000;
    for (var i = 0; i < 16; i++) {
      vm.tick();
    }
    final first = repository.progress.activity(LearningActivity.snake);
    expect(first.attempts, 1);
    expect(first.completed, 1);
    expect(first.activeMilliseconds, 5000);
    expect(first.bestScore, 10);
    expect(first.totalScore, 10);
    vm.restart();
    vm.start();
    now = 106000;
    subscription.close();
    await container.pump();
    final finalMetrics = repository.progress.activity(LearningActivity.snake);
    expect(finalMetrics.attempts, 2);
    expect(finalMetrics.completed, 1);
    expect(finalMetrics.activeMilliseconds, 6000);
    expect(repository.progress.answers, 0);
  });

  test(
    'Falha de gravação mantém métricas e uma gravação posterior recupera',
    () async {
      final storage = FailingStorage();
      final repository = LearningMetricsRepository(storage: storage);
      addTearDown(repository.dispose);
      final statuses = <bool>[];
      final subscription = repository.watch().listen((_) {
        statuses.add(repository.storageFailed);
      });
      addTearDown(subscription.cancel);
      final session = repository.start(LearningActivity.quiz);
      await repository.saved;
      await Future<void>.delayed(Duration.zero);
      expect(repository.storageFailed, isTrue);
      expect(statuses.last, isTrue);
      expect(repository.progress.activity(LearningActivity.quiz).attempts, 1);
      storage.fail = false;
      session.answer(topic: 'Game design', correct: true);
      session.close(completed: true);
      await repository.saved;
      await Future<void>.delayed(Duration.zero);
      expect(repository.storageFailed, isFalse);
      expect(statuses.last, isFalse);
      expect(repository.progress.answers, 1);
    },
  );
}
