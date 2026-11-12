import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class SnakeGameContent extends StatelessWidget {
  const SnakeGameContent({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          Chip(label: Text('ARCADE')),
          Chip(
            avatar: Icon(Icons.gamepad_rounded, color: AppTheme.purple),
            label: Text('Cobrinha'),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Text(
        'Jogo da cobrinha',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 8),
      const Text(
        'Um clássico para testar seus reflexos! Colete comida, cresça e encontre seu próximo caminho.',
        style: TextStyle(fontSize: 16, height: 1.5),
      ),
      const SizedBox(height: 20),
      const Wrap(
        spacing: 24,
        runSpacing: 12,
        children: [
          Text('10 pontos por comida'),
          Text('Toque ou teclado'),
          Text('Modo no seu ritmo'),
        ],
      ),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => context.go('/cobrinha'),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Jogar cobrinha'),
        ),
      ),
    ],
  );
}
