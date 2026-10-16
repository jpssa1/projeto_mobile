import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto_mobile/core/theme/app_theme.dart';

class GameCardMainContent extends StatelessWidget {
  const GameCardMainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text('MISSÃO 01')),
            Chip(
              avatar: Icon(Icons.bolt, color: AppTheme.purple),
              label: Text('Até 100 XP'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Por dentro dos games',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Descubra o que existe por trás de um jogo e teste seus conhecimentos em um mini quiz.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        const Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            Text('🎯 5 perguntas'),
            Text('⏱ Cerca de 2 minutos'),
            Text('🌱 Nível iniciante'),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => context.go('/questionario'),
            icon: const Icon(Icons.sports_esports),
            label: const Text('Jogar agora'),
          ),
        ),
      ],
    );
  }
}
