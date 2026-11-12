enum LearningActivity {
  quiz('Missão 01 • Games'),
  snake('Jogo da cobrinha');

  const LearningActivity(this.label);
  final String label;
}

class ActivityMetrics {
  const ActivityMetrics({
    this.attempts = 0,
    this.completed = 0,
    this.activeMilliseconds = 0,
    this.bestScore = 0,
    this.totalScore = 0,
  });

  final int attempts;
  final int completed;
  final int activeMilliseconds;
  final int bestScore;
  final int totalScore;

  ActivityMetrics add({
    int attempts = 0,
    int completed = 0,
    int milliseconds = 0,
    int score = 0,
    int bestScore = 0,
  }) => ActivityMetrics(
    attempts: this.attempts + attempts,
    completed: this.completed + completed,
    activeMilliseconds: activeMilliseconds + milliseconds,
    totalScore: totalScore + score,
    bestScore: bestScore > this.bestScore ? bestScore : this.bestScore,
  );

  Map<String, dynamic> toJson() => {
    'attempts': attempts,
    'completed': completed,
    'milliseconds': activeMilliseconds,
    'bestScore': bestScore,
    'totalScore': totalScore,
  };

  factory ActivityMetrics.fromJson(Map<String, dynamic> json) =>
      ActivityMetrics(
        attempts: json['attempts'] as int,
        completed: json['completed'] as int,
        activeMilliseconds: json['milliseconds'] as int,
        bestScore: json['bestScore'] as int,
        totalScore: json['totalScore'] as int,
      );
}

class TopicMetrics {
  const TopicMetrics({this.answers = 0, this.errors = 0});

  final int answers;
  final int errors;
  int get correct => answers - errors;

  Map<String, dynamic> toJson() => {'answers': answers, 'errors': errors};

  factory TopicMetrics.fromJson(Map<String, dynamic> json) => TopicMetrics(
    answers: json['answers'] as int,
    errors: json['errors'] as int,
  );
}

class LearningProgress {
  LearningProgress({
    Map<LearningActivity, ActivityMetrics> activities = const {},
    Map<String, TopicMetrics> topics = const {},
  }) : activities = Map.unmodifiable(activities),
       topics = Map.unmodifiable(topics);

  final Map<LearningActivity, ActivityMetrics> activities;
  final Map<String, TopicMetrics> topics;

  ActivityMetrics activity(LearningActivity activity) =>
      activities[activity] ?? const ActivityMetrics();
  int get answers => topics.values.fold(0, (sum, topic) => sum + topic.answers);
  int get errors => topics.values.fold(0, (sum, topic) => sum + topic.errors);
  int get activeMilliseconds => activities.values.fold(
    0,
    (sum, activity) => sum + activity.activeMilliseconds,
  );

  List<MapEntry<String, TopicMetrics>> get topicsByErrors =>
      topics.entries.toList()..sort((a, b) {
        final byErrors = b.value.errors.compareTo(a.value.errors);
        return byErrors == 0 ? a.key.compareTo(b.key) : byErrors;
      });

  Map<String, dynamic> toJson() => {
    'version': 1,
    'activities': activities.map(
      (key, value) => MapEntry(key.name, value.toJson()),
    ),
    'topics': topics.map((key, value) => MapEntry(key, value.toJson())),
  };

  factory LearningProgress.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1) throw const FormatException('Versão inválida.');
    return LearningProgress(
      activities: (json['activities'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          LearningActivity.values.byName(key),
          ActivityMetrics.fromJson(value as Map<String, dynamic>),
        ),
      ),
      topics: (json['topics'] as Map<String, dynamic>).map(
        (key, value) =>
            MapEntry(key, TopicMetrics.fromJson(value as Map<String, dynamic>)),
      ),
    );
  }
}

String formatLearningTime(int milliseconds) {
  final duration = Duration(milliseconds: milliseconds);
  if (duration.inHours > 0) {
    return '${duration.inHours} h ${duration.inMinutes.remainder(60)} min';
  }
  if (duration.inMinutes > 0) {
    return '${duration.inMinutes} min ${duration.inSeconds.remainder(60)} s';
  }
  return '${duration.inSeconds} s';
}
