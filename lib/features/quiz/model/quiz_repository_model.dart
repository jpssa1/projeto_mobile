import 'question_model.dart';

abstract interface class QuizRepository {
  Future<List<Question>> loadQuestions();
}
