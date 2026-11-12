import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/features/splash/view/splash_screen.dart';

void main() {
  testWidgets('Marca aparece com animação antes de liberar o conteúdo', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SplashScreen(child: Text('Destino'))),
    );
    final animation = find.byKey(const ValueKey('splash-logo-animation'));
    final opacity = find.descendant(
      of: animation,
      matching: find.byType(Opacity),
    );
    expect(tester.widget<Opacity>(opacity).opacity, 0);
    expect(find.text('Maragames'), findsOneWidget);
    expect(find.text('Destino'), findsNothing);
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.widget<Opacity>(opacity).opacity, inExclusiveRange(0, 1));
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.widget<Opacity>(opacity).opacity, 1);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.text('Destino'), findsOneWidget);
    expect(find.text('Maragames'), findsNothing);
  });

  testWidgets('Movimento reduzido mantém marca estática e conclui abertura', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: SplashScreen(child: Text('Destino')),
        ),
      ),
    );
    final animation = find.byKey(const ValueKey('splash-logo-animation'));
    final opacity = find.descendant(
      of: animation,
      matching: find.byType(Opacity),
    );
    expect(tester.widget<Opacity>(opacity).opacity, 1);
    await tester.pump(SplashScreen.duration);
    await tester.pumpAndSettle();
    expect(find.text('Destino'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
