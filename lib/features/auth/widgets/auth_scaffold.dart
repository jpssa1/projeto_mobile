import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/widgets/mascote_icon.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBack = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (showBack)
                      IconButton(
                        onPressed: () => context.go('/login'),
                        tooltip: 'Voltar ao login',
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppTheme.purple,
                      ),
                    const Icon(
                      Icons.sports_esports_rounded,
                      color: AppTheme.purple,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Maragames',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.purple,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFECE4F6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 112, child: Mascote()),
                      const SizedBox(height: 20),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      child,
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Modo demonstração\nUse dados fictícios. Nada será salvo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF615971),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
