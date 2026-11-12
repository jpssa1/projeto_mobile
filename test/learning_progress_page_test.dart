import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/core/app.dart';
import 'package:projeto_mobile/core/theme/app_theme.dart';
import 'package:projeto_mobile/features/progress/model/learning_progress.dart';
import 'package:projeto_mobile/features/progress/providers/learning_progress_provider.dart';
import 'package:projeto_mobile/features/progress/repository/learning_metrics_repository.dart';
import 'package:projeto_mobile/features/progress/view/learning_progress_page.dart';
import 'package:projeto_mobile/features/quiz/widgets/image_question.dart';
import 'package:projeto_mobile/features/quiz/model/quiz_repository_model.dart';
import 'package:projeto_mobile/features/quiz/model/question_model.dart';
import 'package:projeto_mobile/features/quiz/view%20model/quiz_view_model.dart';
import 'package:projeto_mobile/features/splash/view/splash_screen.dart';

class ImageOnlyRepository implements QuizRepository {
  @override
  Future<List<Question>> loadQuestions() async => [
    Question(
      id: 'image',
      title: 'Encontre a narrativa ambiental',
      topic: 'Narrativa ambiental',
      options: ['Correta', 'Errada'],
      correctIndex: 0,
      explanation: 'O cenário conta uma história.',
      imageAsset: 'assets/images/quiz_cenario_acampamento.png',
      areas: [
        const Rect.fromLTWH(0, 0, 0.5, 1),
        const Rect.fromLTWH(0.5, 0, 0.5, 1),
      ],
    ),
  ];
}

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Registra cada toque na imagem e abre o progresso pelo resultado',
    (tester) async {
      final repository = LearningMetricsRepository();
      addTearDown(repository.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            learningMetricsRepositoryProvider.overrideWithValue(repository),
            quizRepositoryProvider.overrideWithValue(ImageOnlyRepository()),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pump(SplashScreen.duration);
      await tester.pumpAndSettle();
      await tapText(tester, 'Explorar sem entrar');
      await tapText(tester, 'Começar minha missão');
      final image = find.descendant(
        of: find.byType(ImageQuestion),
        matching: find.byType(GestureDetector),
      );
      await tester.ensureVisible(image);
      final rect = tester.getRect(image);
      await tester.tapAt(
        rect.topLeft + Offset(rect.width * 0.8, rect.height * 0.5),
      );
      await tester.pumpAndSettle();
      await tester.tapAt(
        rect.topLeft + Offset(rect.width * 0.2, rect.height * 0.5),
      );
      await tester.pumpAndSettle();
      expect(repository.progress.answers, 2);
      expect(repository.progress.errors, 1);
      await tapText(tester, 'Ver meu resultado');
      await tapText(tester, 'Ver meu progresso');
      expect(find.byType(LearningProgressPage), findsOneWidget);
      expect(find.text('20 XP acumulados'), findsOneWidget);
      expect(
        find.text('1 acertos em 2 respostas enviadas (50%).'),
        findsOneWidget,
      );
      await tester.ensureVisible(
        find.textContaining('Mais erros: Narrativa ambiental'),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Progresso sem respostas é legível em celular com texto ampliado',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const LearningProgressPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Praticar a missão'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Seus assuntos aparecerão'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Quiz desconta segundo plano e preserva tempo ao sair da rota', (
    tester,
  ) async {
    var now = 0;
    final repository = LearningMetricsRepository(now: () => now);
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          learningMetricsRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump(SplashScreen.duration);
    await tester.pumpAndSettle();
    await tapText(tester, 'Explorar sem entrar');
    await tapText(tester, 'Começar minha missão');
    now = 2000;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    now = 102000;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    now = 105000;
    await tester.tap(find.byTooltip('Voltar ao início'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Meu progresso'));
    await tester.pumpAndSettle();
    expect(
      repository.progress.activity(LearningActivity.quiz).activeMilliseconds,
      5000,
    );
    expect(repository.progress.activity(LearningActivity.quiz).attempts, 1);
    expect(repository.progress.activity(LearningActivity.quiz).completed, 0);
    expect(tester.takeException(), isNull);
  });
}
