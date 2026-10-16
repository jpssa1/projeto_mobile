import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto_mobile/core/theme/app_theme.dart';
import 'package:projeto_mobile/utils/widgets/game_card.dart';
import 'package:projeto_mobile/features/quiz/view%20model/quiz_view_model.dart';

class Result extends StatelessWidget {
  const Result({super.key, required this.state, required this.onRestart});
  final QuizState state;
  final VoidCallback onRestart;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 24),
      const Icon(Icons.emoji_events_rounded, size: 100, color: AppTheme.gold),
      const SizedBox(height: 20),
      Text(
        'Missão concluída!',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 12),
      const Text(
        'Você deu mais um passo na sua jornada de criar jogos.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 28),
      GameCard(
        child: Column(
          children: [
            Text(
              '${state.xp} XP',
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: AppTheme.purple,
              ),
            ),
            Text(
              '${state.correct} de ${state.questions.length} respostas corretas',
            ),
            const SizedBox(height: 16),
            Text(
              state.correct == state.questions.length
                  ? 'Perfeito! Você dominou esta missão.'
                  : 'Cada tentativa é uma chance de evoluir. Que tal jogar de novo?',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      const SizedBox(height: 28),
      FilledButton.icon(
        onPressed: onRestart,
        icon: const Icon(Icons.replay),
        label: const Text('Jogar novamente'),
      ),
      const SizedBox(height: 12),
      TextButton(
        onPressed: () => context.go('/'),
        child: const Text('Voltar ao início'),
      ),
    ],
  );
}
