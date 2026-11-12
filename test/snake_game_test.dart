import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/core/app.dart';
import 'package:projeto_mobile/features/snake/model/snake_position_model.dart';
import 'package:projeto_mobile/features/snake/model/snake_state_model.dart';
import 'package:projeto_mobile/features/snake/view/snake_page.dart';
import 'package:projeto_mobile/features/snake/widgets/snake_board.dart';
import 'package:projeto_mobile/features/splash/view/splash_screen.dart';

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> openGame(
  WidgetTester tester, {
  double textScale = 1,
  Size screenSize = const Size(360, 800),
}) async {
  tester.view.physicalSize = screenSize;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(const ProviderScope(child: MyApp()));
  await tester.pump(SplashScreen.duration);
  await tester.pumpAndSettle();
  await tapText(tester, 'Explorar sem entrar');
  await tapText(tester, 'Jogar cobrinha');
  expect(find.byType(SnakePage), findsOneWidget);
}

SnakeState current(WidgetTester tester) =>
    tester.widget<SnakeBoard>(find.byType(SnakeBoard)).state;

void main() {
  testWidgets('Home abre cobrinha, teclado e toque movem, pausa e volta', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await openGame(tester);
    await tapText(tester, 'Jogar no meu ritmo');
    await tapText(tester, 'Começar jogo');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(current(tester).head, const SnakePosition(7, 7));
    expect(
      find.bySemanticsLabel('Tabuleiro de 16 linhas e colunas'),
      findsOneWidget,
    );
    final board = tester.getSemantics(
      find.bySemanticsLabel('Tabuleiro de 16 linhas e colunas'),
    );
    expect(board.value, contains('Cabeça na coluna 8, linha 8'));

    await tester.ensureVisible(find.byTooltip('Mover para a direita'));
    await tester.tap(find.byTooltip('Mover para a direita'));
    await tester.pump();
    expect(current(tester).head, const SnakePosition(8, 7));
    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.pump();
    expect(current(tester).status, SnakeStatus.paused);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(current(tester).head, const SnakePosition(8, 7));
    await tapText(tester, 'Continuar jogo');
    await tester.sendKeyEvent(LogicalKeyboardKey.keyW);
    await tester.pump();
    expect(current(tester).head, const SnakePosition(8, 6));

    await tester.tap(find.byTooltip('Voltar ao início'));
    await tester.pumpAndSettle();
    expect(find.text('Começar minha missão'), findsOneWidget);
    await tapText(tester, 'Jogar cobrinha');
    expect(current(tester).status, SnakeStatus.ready);
    expect(current(tester).score, 0);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets(
    'Temporizador move, pausa ao sair do app e é descartado na saída',
    (tester) async {
      await openGame(tester);
      await tester.ensureVisible(find.text('Começar jogo'));
      await tester.tap(find.text('Começar jogo'));
      await tester.pump();
      final screen = Offset.zero & const Size(360, 800);
      final board = tester.getRect(find.byType(SnakeBoard));
      final controls = tester.getRect(find.byTooltip('Mover para a direita'));
      expect(screen.contains(board.topLeft), isTrue);
      expect(screen.contains(board.bottomRight), isTrue);
      expect(screen.contains(controls.bottomRight), isTrue);
      await tester.pump(SnakeState.tickDuration);
      expect(current(tester).head, const SnakePosition(8, 8));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(current(tester).status, SnakeStatus.paused);
      await tester.pump(const Duration(seconds: 2));
      expect(current(tester).head, const SnakePosition(8, 8));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(current(tester).status, SnakeStatus.paused);

      await tapText(tester, 'Continuar jogo');
      await tester.tap(find.byTooltip('Voltar ao início'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Modo por passos mostra fim de jogo e permite reiniciar', (
    tester,
  ) async {
    await openGame(tester);
    await tapText(tester, 'Jogar no meu ritmo');
    await tapText(tester, 'Começar jogo');
    for (var i = 0; i < SnakeState.boardSize; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
    }
    expect(current(tester).status, SnakeStatus.gameOver);
    expect(find.textContaining('Fim de jogo!'), findsOneWidget);
    await tapText(tester, 'Jogar novamente');
    expect(current(tester).status, SnakeStatus.ready);
    expect(current(tester).snake.length, 3);
    expect(current(tester).score, 0);
    expect(current(tester).stepMode, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cobrinha suporta texto ampliado e controles acessíveis', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await openGame(tester, textScale: 2, screenSize: const Size(320, 800));
    expect(
      MediaQuery.textScalerOf(tester.element(find.byType(SnakePage))).scale(16),
      32,
    );
    await tapText(tester, 'Jogar no meu ritmo');
    await tapText(tester, 'Começar jogo');
    await tester.ensureVisible(find.byTooltip('Mover para cima'));
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
