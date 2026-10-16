class Question {
  Question({
    required this.id,
    required this.title,
    required List<String> options,
    required this.correctIndex,
    required this.explanation,
  }) : options = List.unmodifiable(options) {
    if (options.length < 2 ||
        correctIndex < 0 ||
        correctIndex >= options.length) {
      throw const FormatException('Pergunta com alternativas inválidas.');
    }
  }
  final String id;
  final String title;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    id: json['id'] as String,
    title: json['title'] as String,
    options: (json['options'] as List).cast<String>(),
    correctIndex: json['correctIndex'] as int,
    explanation: json['explanation'] as String,
  );
}
