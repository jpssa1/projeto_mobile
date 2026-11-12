import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../utils/widgets/game_card.dart';
import '../model/learning_progress.dart';
import '../providers/learning_progress_provider.dart';

class LearningProgressPage extends ConsumerWidget {
  const LearningProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(learningMetricsRepositoryProvider);
    final progress =
        ref.watch(learningProgressProvider).asData?.value ??
        repository.progress;
    final topics = progress.topicsByErrors;
    final mostErrors = topics.where((entry) => entry.value.errors > 0).toList();
    final worstTopics = mostErrors.isEmpty
        ? <String>[]
        : mostErrors
              .where(
                (entry) => entry.value.errors == mostErrors.first.value.errors,
              )
              .map((entry) => entry.key)
              .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar ao início',
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Meu progresso'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Cada tentativa conta.',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Acompanhe seu tempo de prática e descubra o que revisar. '
                    'Este progresso reúne as atividades feitas neste dispositivo.',
                    style: TextStyle(height: 1.5),
                  ),
                  if (repository.storageFailed) ...[
                    const SizedBox(height: 16),
                    const GameCard(
                      child: Text(
                        'Não foi possível acessar o progresso salvo. As atividades '
                        'continuam disponíveis, mas os novos dados podem ficar '
                        'apenas nesta sessão.',
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  GameCard(
                    color: const Color(0xFFECE4F6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.insights_rounded,
                          color: AppTheme.purple,
                          size: 36,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${formatLearningTime(progress.activeMilliseconds)} de prática',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          progress.answers == 0
                              ? 'Responda à missão para começar seu histórico de aprendizagem.'
                              : '${progress.answers - progress.errors} acertos em '
                                    '${progress.answers} respostas enviadas '
                                    '(${((progress.answers - progress.errors) / progress.answers * 100).round()}%).',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${progress.activity(LearningActivity.quiz).totalScore} XP acumulados',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Tempo e tentativas por atividade',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  for (final activity in LearningActivity.values) ...[
                    _ActivityCard(
                      activity: activity,
                      metrics: progress.activity(activity),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const Text(
                    'Cada entrada na missão ou início de partida conta uma tentativa. '
                    'O tempo considera somente a atividade aberta e ativa, '
                    'descontando pausas e períodos em segundo plano.',
                    style: TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Assuntos para revisar',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  GameCard(
                    child: Text(
                      progress.answers == 0
                          ? 'Seus assuntos aparecerão aqui depois da primeira resposta.'
                          : worstTopics.isEmpty
                          ? 'Nenhum erro registrado. Continue praticando!'
                          : 'Mais erros: ${worstTopics.join(', ')}. '
                                'Revise as explicações desses assuntos na próxima missão.',
                      style: const TextStyle(
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final entry in topics) ...[
                    GameCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            entry.key,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${entry.value.errors} erros • ${entry.value.correct} acertos '
                            '• ${entry.value.answers} respostas',
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: entry.value.answers == 0
                                ? 0
                                : entry.value.correct / entry.value.answers,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(8),
                            semanticsLabel: 'Acertos em ${entry.key}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const Text(
                    'Cada resposta confirmada e cada toque na pergunta com imagem '
                    'contam como uma resposta enviada. A cobrinha registra tempo, '
                    'partidas e pontos; seus pontos são independentes do XP da missão.',
                    style: TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.go('/questionario'),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Praticar a missão'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity, required this.metrics});
  final LearningActivity activity;
  final ActivityMetrics metrics;

  @override
  Widget build(BuildContext context) => GameCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(activity.label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            Chip(
              avatar: const Icon(Icons.timer_outlined),
              label: Text(formatLearningTime(metrics.activeMilliseconds)),
            ),
            Chip(label: Text('${metrics.attempts} tentativas')),
            Chip(
              label: Text(
                '${metrics.completed} ${activity == LearningActivity.quiz ? 'concluídas' : 'encerradas'}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          activity == LearningActivity.quiz
              ? 'Melhor tentativa: ${metrics.bestScore} XP'
              : 'Melhor partida: ${metrics.bestScore} pontos',
        ),
      ],
    ),
  );
}
