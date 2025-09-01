enum QuestionType {
  multipleChoice('multiple_choice'),
  trueFalse('true_false'),
  fillInTheBlank('fill_in_the_blank'),
  shortAnswer('short_answer'),
  calculation('calculation'),
  matching('matching'),
  ordering('ordering');

  const QuestionType(this.value);
  final String value;

  static QuestionType fromString(String value) {
    switch (value) {
      case 'multiple_choice':
        return QuestionType.multipleChoice;
      case 'true_false':
        return QuestionType.trueFalse;
      case 'fill_in_the_blank':
        return QuestionType.fillInTheBlank;
      case 'short_answer':
        return QuestionType.shortAnswer;
      case 'calculation':
        return QuestionType.calculation;
      case 'matching':
        return QuestionType.matching;
      case 'ordering':
        return QuestionType.ordering;
      default:
        return QuestionType.multipleChoice;
    }
  }
}

enum DifficultyLevel {
  easy('easy'),
  medium('medium'),
  hard('hard');

  const DifficultyLevel(this.value);
  final String value;

  static DifficultyLevel fromString(String value) {
    switch (value) {
      case 'easy':
        return DifficultyLevel.easy;
      case 'medium':
        return DifficultyLevel.medium;
      case 'hard':
        return DifficultyLevel.hard;
      default:
        return DifficultyLevel.medium;
    }
  }

  String get displayName {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Łatwy';
      case DifficultyLevel.medium:
        return 'Średni';
      case DifficultyLevel.hard:
        return 'Trudny';
    }
  }
}

class Quiz {
  final int id;
  final int userId;
  final int teacherId;
  final String title;
  final String subject;
  final DifficultyLevel difficultyLevel;
  final int totalQuestions;
  final DateTime createdAt;
  final String teacherName;
  final List<QuizQuestion> questions;
  final List<QuizAttempt> attempts;

  Quiz({
    required this.id,
    required this.userId,
    required this.teacherId,
    required this.title,
    required this.subject,
    required this.difficultyLevel,
    required this.totalQuestions,
    required this.createdAt,
    required this.teacherName,
    this.questions = const [],
    this.attempts = const [],
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      teacherId: json['teacher_id'] as int,
      title: json['title'] as String,
      subject: json['subject'] as String,
      difficultyLevel: DifficultyLevel.fromString(json['difficulty_level'] as String),
      totalQuestions: json['total_questions'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      teacherName: json['teacher_name'] as String? ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      attempts: (json['attempts'] as List<dynamic>?)
              ?.map((a) => QuizAttempt.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'teacher_id': teacherId,
      'title': title,
      'subject': subject,
      'difficulty_level': difficultyLevel.value,
      'total_questions': totalQuestions,
      'created_at': createdAt.toIso8601String(),
      'teacher_name': teacherName,
      'questions': questions.map((q) => q.toJson()).toList(),
      'attempts': attempts.map((a) => a.toJson()).toList(),
    };
  }
}

class QuizQuestion {
  final int id;
  final int quizId;
  final int questionNumber;
  final QuestionType questionType;
  final String questionText;
  final String correctAnswer;
  final Map<String, String>? options;
  final String? explanation;
  final int points;
  final String? topic;

  QuizQuestion({
    required this.id,
    required this.quizId,
    required this.questionNumber,
    required this.questionType,
    required this.questionText,
    required this.correctAnswer,
    this.options,
    this.explanation,
    this.points = 1,
    this.topic,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as int,
      quizId: json['quiz_id'] as int,
      questionNumber: json['question_number'] as int,
      questionType: QuestionType.fromString(json['question_type'] as String),
      questionText: json['question_text'] as String,
      correctAnswer: json['correct_answer'] as String,
      options: json['options'] != null
          ? Map<String, String>.from(json['options'] as Map)
          : null,
      explanation: json['explanation'] as String?,
      points: json['points'] as int? ?? 1,
      topic: json['topic'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'question_number': questionNumber,
      'question_type': questionType.value,
      'question_text': questionText,
      'correct_answer': correctAnswer,
      'options': options,
      'explanation': explanation,
      'points': points,
      'topic': topic,
    };
  }
}

class QuizAttempt {
  final int id;
  final int quizId;
  final int userId;
  final int attemptNumber;
  final DateTime startedAt;
  final DateTime? completedAt;
  final double? score;
  final double maxScore;
  final double? percentage;
  final int? timeSpentSeconds;
  final bool isCompleted;
  final List<QuizAnswer> answers;

  QuizAttempt({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.attemptNumber,
    required this.startedAt,
    this.completedAt,
    this.score,
    required this.maxScore,
    this.percentage,
    this.timeSpentSeconds,
    this.isCompleted = false,
    this.answers = const [],
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'] as int,
      quizId: json['quiz_id'] as int,
      userId: json['user_id'] as int,
      attemptNumber: json['attempt_number'] as int,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      score: (json['score'] as num?)?.toDouble(),
      maxScore: (json['max_score'] as num).toDouble(),
      percentage: (json['percentage'] as num?)?.toDouble(),
      timeSpentSeconds: json['time_spent_seconds'] as int?,
      isCompleted: json['is_completed'] as bool? ?? false,
      answers: (json['answers'] as List<dynamic>?)
              ?.map((a) => QuizAnswer.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'user_id': userId,
      'attempt_number': attemptNumber,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'score': score,
      'max_score': maxScore,
      'percentage': percentage,
      'time_spent_seconds': timeSpentSeconds,
      'is_completed': isCompleted,
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}

class QuizAnswer {
  final int id;
  final int attemptId;
  final int questionId;
  final String? userAnswer;
  final bool isCorrect;
  final double pointsEarned;
  final DateTime answeredAt;

  QuizAnswer({
    required this.id,
    required this.attemptId,
    required this.questionId,
    this.userAnswer,
    required this.isCorrect,
    this.pointsEarned = 0.0,
    required this.answeredAt,
  });

  factory QuizAnswer.fromJson(Map<String, dynamic> json) {
    return QuizAnswer(
      id: json['id'] as int,
      attemptId: json['attempt_id'] as int,
      questionId: json['question_id'] as int,
      userAnswer: json['user_answer'] as String?,
      isCorrect: json['is_correct'] as bool,
      pointsEarned: (json['points_earned'] as num?)?.toDouble() ?? 0.0,
      answeredAt: DateTime.parse(json['answered_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attempt_id': attemptId,
      'question_id': questionId,
      'user_answer': userAnswer,
      'is_correct': isCorrect,
      'points_earned': pointsEarned,
      'answered_at': answeredAt.toIso8601String(),
    };
  }
}

class QuizListItem {
  final int id;
  final String title;
  final String subject;
  final DifficultyLevel difficultyLevel;
  final int totalQuestions;
  final DateTime createdAt;
  final String teacherName;
  final double? bestScore;
  final int attemptsCount;

  QuizListItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.difficultyLevel,
    required this.totalQuestions,
    required this.createdAt,
    required this.teacherName,
    this.bestScore,
    this.attemptsCount = 0,
  });

  factory QuizListItem.fromJson(Map<String, dynamic> json) {
    return QuizListItem(
      id: json['id'] as int,
      title: json['title'] as String,
      subject: json['subject'] as String,
      difficultyLevel: DifficultyLevel.fromString(json['difficulty_level'] as String),
      totalQuestions: json['total_questions'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      teacherName: json['teacher_name'] as String,
      bestScore: (json['best_score'] as num?)?.toDouble(),
      attemptsCount: json['attempts_count'] as int? ?? 0,
    );
  }
}

class GenerateQuizRequest {
  final int conversationId;
  final int teacherId;
  final int questionCount;
  final DifficultyLevel difficultyLevel;
  final List<String> specificTopics;

  GenerateQuizRequest({
    required this.conversationId,
    required this.teacherId,
    this.questionCount = 10,
    this.difficultyLevel = DifficultyLevel.medium,
    this.specificTopics = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'teacher_id': teacherId,
      'question_count': questionCount,
      'difficulty_level': difficultyLevel.value,
      'specific_topics': specificTopics,
    };
  }
}

class QuizAttemptStart {
  final int quizId;

  QuizAttemptStart({required this.quizId});

  Map<String, dynamic> toJson() {
    return {
      'quiz_id': quizId,
    };
  }
}

class QuizAnswerSubmit {
  final int questionId;
  final String userAnswer;

  QuizAnswerSubmit({
    required this.questionId,
    required this.userAnswer,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'user_answer': userAnswer,
    };
  }
}

class QuizAttemptSubmit {
  final int attemptId;
  final List<QuizAnswerSubmit> answers;

  QuizAttemptSubmit({
    required this.attemptId,
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'attempt_id': attemptId,
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}

class QuizAttemptResult {
  final int id;
  final int quizId;
  final double score;
  final double maxScore;
  final double percentage;
  final int timeSpentSeconds;
  final int correctAnswers;
  final int totalQuestions;
  final List<QuizAnswer> answers;

  QuizAttemptResult({
    required this.id,
    required this.quizId,
    required this.score,
    required this.maxScore,
    required this.percentage,
    required this.timeSpentSeconds,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.answers,
  });

  factory QuizAttemptResult.fromJson(Map<String, dynamic> json) {
    return QuizAttemptResult(
      id: json['id'] as int,
      quizId: json['quiz_id'] as int,
      score: (json['score'] as num).toDouble(),
      maxScore: (json['max_score'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      timeSpentSeconds: json['time_spent_seconds'] as int,
      correctAnswers: json['correct_answers'] as int,
      totalQuestions: json['total_questions'] as int,
      answers: (json['answers'] as List<dynamic>)
          .map((a) => QuizAnswer.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}
