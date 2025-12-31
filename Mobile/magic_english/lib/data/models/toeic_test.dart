// TOEIC Test Models for Flutter
class ToeicTest {
  final int id;
  final String section;
  final String? part;
  final String difficulty;
  final String title;
  final int durationMinutes;
  final int totalQuestions;
  final List<ToeicQuestion> questions;

  ToeicTest({
    required this.id,
    required this.section,
    this.part,
    required this.difficulty,
    required this.title,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.questions,
  });

  factory ToeicTest.fromJson(Map<String, dynamic> json) {
    return ToeicTest(
      id: json['id'],
      section: json['section'],
      part: json['part'],
      difficulty: json['difficulty'],
      title: json['title'],
      durationMinutes: json['durationMinutes'],
      totalQuestions: json['totalQuestions'],
      questions: (json['questions'] as List)
          .map((q) => ToeicQuestion.fromJson(q))
          .toList(),
    );
  }
}

class ToeicQuestion {
  final int id;
  final int questionNumber;
  final String questionText;
  final String questionType;
  final String? passage;
  final String? audioUrl;
  final List<ToeicAnswer> answers;

  ToeicQuestion({
    required this.id,
    required this.questionNumber,
    required this.questionText,
    required this.questionType,
    this.passage,
    this.audioUrl,
    required this.answers,
  });

  factory ToeicQuestion.fromJson(Map<String, dynamic> json) {
    return ToeicQuestion(
      id: json['id'],
      questionNumber: json['questionNumber'],
      questionText: json['questionText'],
      questionType: json['questionType'] ?? 'multiple_choice',
      passage: json['passage'],
      audioUrl: json['audioUrl'],
      answers: (json['answers'] as List)
          .map((a) => ToeicAnswer.fromJson(a))
          .toList(),
    );
  }
}

class ToeicAnswer {
  final int id;
  final String answerOption;
  final String answerText;
  final bool? isCorrect;
  final String? explanation;

  ToeicAnswer({
    required this.id,
    required this.answerOption,
    required this.answerText,
    this.isCorrect,
    this.explanation,
  });

  factory ToeicAnswer.fromJson(Map<String, dynamic> json) {
    return ToeicAnswer(
      id: json['id'],
      answerOption: json['answerOption'],
      answerText: json['answerText'],
      isCorrect: json['isCorrect'],
      explanation: json['explanation'],
    );
  }
}

class ToeicTestHistory {
  final int id;
  final int testId;
  final String testTitle;
  final String section;
  final String difficulty;
  final String startedAt;
  final String? completedAt;
  final int? score;
  final int correctAnswers;
  final int totalAnswers;
  final String status;
  final int? timeSpentSeconds;

  ToeicTestHistory({
    required this.id,
    required this.testId,
    required this.testTitle,
    required this.section,
    required this.difficulty,
    required this.startedAt,
    this.completedAt,
    this.score,
    required this.correctAnswers,
    required this.totalAnswers,
    required this.status,
    this.timeSpentSeconds,
  });

  factory ToeicTestHistory.fromJson(Map<String, dynamic> json) {
    return ToeicTestHistory(
      id: json['id'],
      testId: json['testId'],
      testTitle: json['testTitle'],
      section: json['section'],
      difficulty: json['difficulty'],
      startedAt: json['startedAt'],
      completedAt: json['completedAt'],
      score: json['score'],
      correctAnswers: json['correctAnswers'],
      totalAnswers: json['totalAnswers'],
      status: json['status'],
      timeSpentSeconds: json['timeSpentSeconds'],
    );
  }
}

class ToeicTestResult {
  final int historyId;
  final int testId;
  final String testTitle;
  final String section;
  final String difficulty;
  final int score; // 0-990
  final int correctAnswers;
  final int totalAnswers;
  final double accuracyPercentage;
  final int timeSpentSeconds;
  final String completedAt;
  final List<ToeicQuestionResult> questionResults;

  ToeicTestResult({
    required this.historyId,
    required this.testId,
    required this.testTitle,
    required this.section,
    required this.difficulty,
    required this.score,
    required this.correctAnswers,
    required this.totalAnswers,
    required this.accuracyPercentage,
    required this.timeSpentSeconds,
    required this.completedAt,
    required this.questionResults,
  });

  factory ToeicTestResult.fromJson(Map<String, dynamic> json) {
    return ToeicTestResult(
      historyId: json['historyId'],
      testId: json['testId'],
      testTitle: json['testTitle'],
      section: json['section'],
      difficulty: json['difficulty'],
      score: json['score'],
      correctAnswers: json['correctAnswers'],
      totalAnswers: json['totalAnswers'],
      accuracyPercentage: (json['accuracyPercentage'] as num).toDouble(),
      timeSpentSeconds: json['timeSpentSeconds'],
      completedAt: json['completedAt'],
      questionResults: (json['questionResults'] as List)
          .map((q) => ToeicQuestionResult.fromJson(q))
          .toList(),
    );
  }
}

class ToeicQuestionResult {
  final int questionId;
  final int questionNumber;
  final String questionText;
  final String? passage;
  final String? audioUrl;
  final bool isCorrect;
  final int? selectedAnswerId;
  final String? selectedAnswerOption;
  final String? selectedAnswerText;
  final int correctAnswerId;
  final String correctAnswerOption;
  final String correctAnswerText;
  final String? explanation;

  ToeicQuestionResult({
    required this.questionId,
    required this.questionNumber,
    required this.questionText,
    this.passage,
    this.audioUrl,
    required this.isCorrect,
    this.selectedAnswerId,
    this.selectedAnswerOption,
    this.selectedAnswerText,
    required this.correctAnswerId,
    required this.correctAnswerOption,
    required this.correctAnswerText,
    this.explanation,
  });

  factory ToeicQuestionResult.fromJson(Map<String, dynamic> json) {
    return ToeicQuestionResult(
      questionId: json['questionId'],
      questionNumber: json['questionNumber'],
      questionText: json['questionText'],
      passage: json['passage'],
      audioUrl: json['audioUrl'],
      isCorrect: json['isCorrect'],
      selectedAnswerId: json['selectedAnswerId'],
      selectedAnswerOption: json['selectedAnswerOption'],
      selectedAnswerText: json['selectedAnswerText'],
      correctAnswerId: json['correctAnswerId'],
      correctAnswerOption: json['correctAnswerOption'],
      correctAnswerText: json['correctAnswerText'],
      explanation: json['explanation'],
    );
  }
}
