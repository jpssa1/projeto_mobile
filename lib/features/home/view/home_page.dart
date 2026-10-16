import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto_mobile/features/home/widgets/card_game_content.dart';
import 'package:projeto_mobile/utils/widgets/mascote_icon.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/widgets/game_card.dart';
import '../view model/home_view_model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(homeViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.sports_esports_rounded),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Maragames',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'APRENDA • JOGUE • EVOLUA',
                    style: TextStyle(
                      color: AppTheme.purple,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final copy = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            content.title,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            content.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () => context.go('/questionario'),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Começar minha missão'),
                          ),
                        ],
                      );
                      return constraints.maxWidth > 680
                          ? Row(
                              children: [
                                Expanded(child: copy),
                                const SizedBox(width: 24),
                                Expanded(child: Mascote()),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                copy,
                                Center(child: Mascote()),
                              ],
                            );
                    },
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Sua próxima aventura',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pequenas descobertas. Grandes conquistas.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  GameCard(child: GameCardMainContent()),
                  const SizedBox(height: 24),
                  const GameCard(
                    color: Color(0xFFECE4F6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.auto_awesome, color: AppTheme.purple),
                        SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Aqui, cada tentativa ensina. Ganhe 20 XP por acerto e descubra a explicação de cada resposta.',
                            style: TextStyle(height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Center(
                    child: Text(
                      'FEITO PARA QUEM APRENDE JOGANDO',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        color: Color(0xFF615971),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
