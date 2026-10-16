import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/auth/view/register_page.dart';
import '../../features/auth/view/recover_password_page.dart';
import '../../features/home/view/home_page.dart';
import '../../features/quiz/view/quiz_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/recuperar-senha',
        builder: (context, state) => const RecoverPasswordPage(),
      ),
      GoRoute(
        path: '/cadastro',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/questionario',
        builder: (context, state) => const QuizPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => context.go('/'),
          child: const Text('Voltar ao início'),
        ),
      ),
    ),
  );
  ref.onDispose(router.dispose);
  return router;
});
