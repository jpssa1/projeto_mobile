import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_mobile/core/app.dart';
import 'package:projeto_mobile/features/splash/view/splash_screen.dart';

Future<void> openApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const ProviderScope(child: MyApp()));
  await tester.pump(SplashScreen.duration);
  await tester.pumpAndSettle();
}

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Recuperação valida e-mail, simula envio e retorna ao login', (
    tester,
  ) async {
    await openApp(tester);
    await tapText(tester, 'Esqueci minha senha');
    expect(find.text('Recuperar senha'), findsOneWidget);
    await tapText(tester, 'Simular recuperação');
    expect(find.text('Informe seu e-mail.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'invalido');
    await tapText(tester, 'Simular recuperação');
    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'jogador@example.com');
    await tapText(tester, 'Simular recuperação');
    expect(find.text('Solicitação simulada!'), findsOneWidget);
    expect(find.textContaining('Nenhum e-mail foi enviado.'), findsOneWidget);
    await tapText(tester, 'Tentar outro e-mail');
    expect(find.text('Recuperar senha'), findsOneWidget);
    await tapText(tester, 'Voltar ao login');
    expect(find.text('Sua aventura começa aqui'), findsOneWidget);
    await tapText(tester, 'Explorar sem entrar');
    expect(find.text('Começar minha missão'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cadastro valida os campos e simula a criação sem salvar dados', (
    tester,
  ) async {
    await openApp(tester);
    await tapText(tester, 'Criar conta');
    expect(find.text('Crie sua conta'), findsOneWidget);
    await tapText(tester, 'Criar conta');
    expect(find.text('Informe seu e-mail.'), findsOneWidget);
    expect(find.text('Confirme sua senha.'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Jogador');
    await tester.enterText(fields.at(1), 'invalido');
    await tester.enterText(fields.at(2), 'senha123');
    await tester.enterText(fields.at(3), 'outrasenha');
    await tapText(tester, 'Criar conta');
    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
    expect(find.text('As senhas precisam ser iguais.'), findsOneWidget);

    await tester.enterText(fields.at(1), 'jogador@example.com');
    await tester.enterText(fields.at(3), 'senha123');
    await tapText(tester, 'Criar conta');
    expect(find.text('Cadastro simulado!'), findsOneWidget);
    await tapText(tester, 'Explorar o app');
    expect(find.text('Começar minha missão'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar ao login'));
    await tester.pumpAndSettle();
    expect(find.text('Sua aventura começa aqui'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      isEmpty,
    );
    expect(tester.takeException(), isNull);
  });
}
