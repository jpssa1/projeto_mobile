import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/local_quiz_repository.dart';
import '../model/question_model.dart';
import '../model/quiz_repository_model.dart';

final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => LocalQuizRepository(),
);
final quizProvider =
    AsyncNotifierProvider.autoDispose<QuizViewModel, QuizState>(
      QuizViewModel.new,
    );

class QuizState {
  QuizState({
    required List<Question> questions,
    this.index = 0,
    this.selected,
    this.confirmed = false,
    this.correct = 0,
    this.finished = false,
  }) : questions = List.unmodifiable(questions);
  final List<Question> questions;
  final int index;
  final int? selected;
  final bool confirmed;
  final int correct;
  final bool finished;
  Question get question => questions[index];
  int get xp => correct * 20;
  double get progress =>
      finished ? 1 : (index + (confirmed ? 1 : 0)) / questions.length;
}

class QuizViewModel extends AsyncNotifier<QuizState> {
  @override
  Future<QuizState> build() async {
    final questions = await ref.watch(quizRepositoryProvider).loadQuestions();
    if (questions.isEmpty) throw const FormatException('Questionário vazio.');
    return QuizState(questions: questions);
  }

  void select(int option) {
    final current = state.asData?.value;
    if (current == null ||
        current.confirmed ||
        current.finished ||
        option < 0 ||
        option >= current.question.options.length) {
      return;
    }
    state = AsyncData(
      QuizState(
        questions: current.questions,
        index: current.index,
        selected: option,
        correct: current.correct,
      ),
    );
  }

  void confirm() {
    final current = state.asData?.value;
    if (current == null ||
        current.selected == null ||
        current.confirmed ||
        current.finished) {
      return;
    }
    state = AsyncData(
      QuizState(
        questions: current.questions,
        index: current.index,
        selected: current.selected,
        confirmed: true,
        correct:
            current.correct +
            (current.selected == current.question.correctIndex ? 1 : 0),
      ),
    );
  }

  void answerImage({required bool isCorrect}) {
    final current = state.asData?.value;
    if (current == null ||
        !current.question.isImageQuestion ||
        current.confirmed ||
        current.finished) {
      return;
    }
    final question = current.question;
    state = AsyncData(
      QuizState(
        questions: current.questions,
        index: current.index,
        selected: isCorrect
            ? question.correctIndex
            : (question.correctIndex + 1) % question.options.length,
        confirmed: true,
        correct: current.correct + (isCorrect ? 1 : 0),
      ),
    );
  }

  void next() {
    final current = state.asData?.value;
    if (current == null || !current.confirmed || current.finished) return;
    final finished = current.index == current.questions.length - 1;
    state = AsyncData(
      QuizState(
        questions: current.questions,
        index: finished ? current.index : current.index + 1,
        correct: current.correct,
        finished: finished,
      ),
    );
  }

  void restart() => ref.invalidateSelf();
}
