import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/learning_progress.dart';
import '../repository/learning_metrics_repository.dart';

// A entrada do app injeta o armazenamento persistente. Testes usam memória.
final learningMetricsRepositoryProvider = Provider<LearningMetricsRepository>((
  ref,
) {
  final repository = LearningMetricsRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final learningProgressProvider = StreamProvider<LearningProgress>(
  (ref) => ref.watch(learningMetricsRepositoryProvider).watch(),
);
