import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app.dart';
import 'features/progress/providers/learning_progress_provider.dart';
import 'features/progress/repository/learning_metrics_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LearningMetricsRepository repository;
  try {
    final preferences = await SharedPreferences.getInstance();
    repository = LearningMetricsRepository(
      storage: PreferencesMetricsStorage(preferences),
    );
  } catch (_) {
    repository = LearningMetricsRepository()..storageFailed = true;
  }
  runApp(
    ProviderScope(
      overrides: [
        learningMetricsRepositoryProvider.overrideWith((ref) {
          ref.onDispose(repository.dispose);
          return repository;
        }),
      ],
      child: const MyApp(),
    ),
  );
}
