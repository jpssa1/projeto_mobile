import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/learning_progress.dart';

abstract interface class MetricsStorage {
  String? read();
  Future<void> write(String data);
}

class PreferencesMetricsStorage implements MetricsStorage {
  PreferencesMetricsStorage(this.preferences);
  final SharedPreferences preferences;
  static const key = 'maragames.learning_progress.v1';

  @override
  String? read() => preferences.getString(key);

  @override
  Future<void> write(String data) async {
    if (!await preferences.setString(key, data)) {
      throw StateError('Não foi possível salvar o progresso.');
    }
  }
}

/// Mantém as métricas entre rotas e serializa as gravações locais.
class LearningMetricsRepository {
  LearningMetricsRepository({MetricsStorage? storage, int Function()? now})
    : _storage = storage {
    final clock = Stopwatch()..start();
    _now = now ?? (() => clock.elapsedMilliseconds);
    final saved = storage?.read();
    if (saved != null) {
      try {
        _progress = LearningProgress.fromJson(
          jsonDecode(saved) as Map<String, dynamic>,
        );
      } catch (_) {
        storageFailed = true;
      }
    }
  }

  final MetricsStorage? _storage;
  late final int Function() _now;
  final _changes = StreamController<LearningProgress>.broadcast();
  LearningProgress _progress = LearningProgress();
  Future<void> _pendingSave = Future.value();
  bool storageFailed = false;
  bool _disposed = false;

  LearningProgress get progress => _progress;
  Future<void> get saved => _pendingSave;

  Stream<LearningProgress> watch() => Stream.multi((controller) {
    final subscription = _changes.stream.listen(controller.add);
    controller.add(_progress);
    controller.onCancel = subscription.cancel;
  });

  ActivitySession start(LearningActivity activity) {
    _updateActivity(activity, progress.activity(activity).add(attempts: 1));
    return ActivitySession._(this, activity);
  }

  void _updateActivity(LearningActivity activity, ActivityMetrics metrics) {
    _commit(
      LearningProgress(
        activities: {...progress.activities, activity: metrics},
        topics: progress.topics,
      ),
    );
  }

  void _commit(LearningProgress next) {
    if (_disposed) return;
    _progress = next;
    _changes.add(next);
    if (_storage == null) return;
    final data = jsonEncode(next.toJson());
    _pendingSave = _pendingSave.then((_) async {
      try {
        await _storage.write(data);
        if (storageFailed) {
          storageFailed = false;
          _notifyStorageStatus();
        }
      } catch (_) {
        final changed = !storageFailed;
        storageFailed = true;
        if (changed) _notifyStorageStatus();
      }
    });
  }

  void _notifyStorageStatus() {
    if (_disposed) return;
    // Uma nova instância também notifica consumidores que comparam por igualdade.
    _progress = LearningProgress(
      activities: _progress.activities,
      topics: _progress.topics,
    );
    _changes.add(_progress);
  }

  void dispose() {
    _disposed = true;
    unawaited(_changes.close());
  }
}

/// Cronometra somente o tempo ativo; sair ou reiniciar fecha a tentativa.
class ActivitySession {
  ActivitySession._(this._repository, this.activity)
    : _lastTime = _repository._now() {
    _checkpoint = Timer.periodic(
      const Duration(seconds: 5),
      (_) => checkpoint(),
    );
  }

  final LearningMetricsRepository _repository;
  final LearningActivity activity;
  late final Timer _checkpoint;
  int _lastTime;
  int _score = 0;
  bool _active = true;
  bool _closed = false;

  void checkpoint() {
    if (_closed || !_active) return;
    final now = _repository._now();
    final delta = now - _lastTime;
    _lastTime = now;
    if (delta <= 0) return;
    _repository._updateActivity(
      activity,
      _repository.progress.activity(activity).add(milliseconds: delta),
    );
  }

  void pause() {
    checkpoint();
    _active = false;
  }

  void resume() {
    if (_closed || _active) return;
    _lastTime = _repository._now();
    _active = true;
  }

  void answer({required String topic, required bool correct}) {
    if (_closed) return;
    checkpoint();
    final progress = _repository.progress;
    final previous = progress.topics[topic] ?? const TopicMetrics();
    _repository._commit(
      LearningProgress(
        activities: progress.activities,
        topics: {
          ...progress.topics,
          topic: TopicMetrics(
            answers: previous.answers + 1,
            errors: previous.errors + (correct ? 0 : 1),
          ),
        },
      ),
    );
  }

  void score(int value) {
    if (_closed || value <= _score) return;
    final delta = value - _score;
    _score = value;
    _repository._updateActivity(
      activity,
      _repository.progress
          .activity(activity)
          .add(score: delta, bestScore: value),
    );
  }

  void close({bool completed = false}) {
    if (_closed) return;
    checkpoint();
    _closed = true;
    _checkpoint.cancel();
    if (completed) {
      _repository._updateActivity(
        activity,
        _repository.progress.activity(activity).add(completed: 1),
      );
    }
  }
}
