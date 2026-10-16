import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/core/app.dart';
import 'package:projeto_mobile/features/splash/view/splash_screen.dart';

void main() {
  testWidgets('Home abre missão, confirma resposta e volta ao início', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    expect(find.text('Maragames'), findsOneWidget);
    expect(find.text('Aprenda jogando'), findsOneWidget);
    expect(find.text('Começar minha missão'), findsNothing);
    await tester.pump(SplashScreen.duration);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Começar minha missão'));
    await tester.pumpAndSettle();
    expect(find.text('Pergunta 1 de 5'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Confirmar resposta'),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Definir regras e experiências do jogo'));
    await tester.pump();
    await tester.tap(find.text('Confirmar resposta'));
    await tester.pumpAndSettle();
    expect(find.text('20 XP'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar ao início'));
    await tester.pumpAndSettle();
    expect(find.text('Começar minha missão'), findsOneWidget);
    expect(find.text('Aprenda jogando'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Fechar a splash cancela a transição pendente', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(SplashScreen.duration);
    expect(tester.takeException(), isNull);
  });
}
