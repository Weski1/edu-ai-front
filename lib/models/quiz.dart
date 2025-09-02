enum QuestionType {
  multipleChoice('multiple_choice'),
  trueFalse('true_false'),
  fillInTheBlank('fill_in_the_blank'),
  shortAnswer('short_answer'),
  calculation('calculation'),
  matching('matching'),
  ordering('ordering'),
  // AI-graded question types
  openEnded('open_ended'),
  mathematicalProof('mathematical_proof'),
  essay('essay'),
  graphAnalysis('graph_analysis'),
  problemSolving('problem_solving');

  const QuestionType(this.value);
  final String value;

  static QuestionType fromString(String value) {
    return QuestionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => QuestionType.multipleChoice,
    );
  }

  String get displayName {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'Wybór wielokrotny';
      case QuestionType.trueFalse:
        return 'Prawda/Fałsz';
      case QuestionType.fillInTheBlank:
        return 'Uzupełnij lukę';
      case QuestionType.shortAnswer:
        return 'Krótka odpowiedź';
      case QuestionType.calculation:
        return 'Obliczenia';
      case QuestionType.matching:
        return 'Dopasowywanie';
      case QuestionType.ordering:
        return 'Uporządkowanie';
      case QuestionType.openEnded:
        return 'Pytanie otwarte';
      case QuestionType.mathematicalProof:
        return 'Dowód matematyczny';
      case QuestionType.essay:
        return 'Esej';
      case QuestionType.graphAnalysis:
        return 'Analiza wykresu';
      case QuestionType.problemSolving:
        return 'Rozwiązywanie problemów';
    }
  }

  bool get requiresAiGrading {
    return [
      QuestionType.openEnded,
      QuestionType.mathematicalProof,
      QuestionType.essay,
      QuestionType.graphAnalysis,
      QuestionType.problemSolving,
    ].contains(this);
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
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      teacherId: json['teacher_id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled Quiz',
      subject: json['subject'] as String? ?? 'Unknown',
      difficultyLevel: json['difficulty_level'] != null 
          ? DifficultyLevel.fromString(json['difficulty_level'] as String)
          : DifficultyLevel.medium,
      totalQuestions: json['total_questions'] as int? ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
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
  final Map<String, dynamic>? options;
  final String? explanation;
  final int points;
  final String? topic;
  final bool requiresAiGrading;
  final Map<String, dynamic>? aiGradingCriteria;

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
    this.requiresAiGrading = false,
    this.aiGradingCriteria,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as int? ?? 0,
      quizId: json['quiz_id'] as int? ?? 0,
      questionNumber: json['question_number'] as int? ?? 1,
      questionType: json['question_type'] != null 
          ? QuestionType.fromString(json['question_type'] as String)
          : QuestionType.multipleChoice,
      questionText: json['question_text'] as String? ?? '',
      correctAnswer: json['correct_answer'] as String? ?? '',
      options: json['options'] as Map<String, dynamic>?,
      explanation: json['explanation'] as String?,
      points: json['points'] as int? ?? 1,
      topic: json['topic'] as String?,
      requiresAiGrading: json['requires_ai_grading'] as bool? ?? false,
      aiGradingCriteria: json['ai_grading_criteria'] as Map<String, dynamic>?,
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
      'requires_ai_grading': requiresAiGrading,
      'ai_grading_criteria': aiGradingCriteria,
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
      id: json['id'] as int? ?? 0,
      quizId: json['quiz_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      attemptNumber: json['attempt_number'] as int? ?? 1,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      score: (json['score'] as num?)?.toDouble(),
      maxScore: (json['max_score'] as num?)?.toDouble() ?? 0.0,
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
  final int questionId;
  final String? userAnswer;
  final bool isCorrect;
  final double pointsEarned;
  final DateTime answeredAt;
  final String? aiFeedback;
  final String? aiStrengths;
  final String? aiImprovements;
  final String? imageUrl;

  QuizAnswer({
    required this.id,
    required this.questionId,
    this.userAnswer,
    required this.isCorrect,
    this.pointsEarned = 0.0,
    required this.answeredAt,
    this.aiFeedback,
    this.aiStrengths,
    this.aiImprovements,
    this.imageUrl,
  });

  factory QuizAnswer.fromJson(Map<String, dynamic> json) {
    return QuizAnswer(
      id: json['id'] as int? ?? 0,
      questionId: json['question_id'] as int? ?? 0,
      userAnswer: json['user_answer'] as String?,
      isCorrect: json['is_correct'] as bool? ?? false,
      pointsEarned: (json['points_earned'] as num?)?.toDouble() ?? 0.0,
      answeredAt: json['answered_at'] != null
          ? DateTime.parse(json['answered_at'] as String)
          : DateTime.now(),
      aiFeedback: json['ai_feedback'] as String?,
      aiStrengths: json['ai_strengths'] as String?,
      aiImprovements: json['ai_improvements'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'user_answer': userAnswer,
      'is_correct': isCorrect,
      'points_earned': pointsEarned,
      'answered_at': answeredAt.toIso8601String(),
      'ai_feedback': aiFeedback,
      'ai_strengths': aiStrengths,
      'ai_improvements': aiImprovements,
      'image_url': imageUrl,
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
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled Quiz',
      subject: json['subject'] as String? ?? 'Unknown',
      difficultyLevel: json['difficulty_level'] != null 
          ? DifficultyLevel.fromString(json['difficulty_level'] as String)
          : DifficultyLevel.medium,
      totalQuestions: json['total_questions'] as int? ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      teacherName: json['teacher_name'] as String? ?? 'Unknown Teacher',
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
  final String? imageUrl;

  QuizAnswerSubmit({
    required this.questionId,
    required this.userAnswer,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'user_answer': userAnswer,
      'image_url': imageUrl,
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
