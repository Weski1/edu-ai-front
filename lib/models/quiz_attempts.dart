class QuizAttemptListItem {
  final int id;
  final String title;
  final String subject;
  final String difficultyLevel;
  final int totalQuestions;
  final DateTime createdAt;
  final String teacherName;
  final double bestScore;
  final int attemptsCount;

  QuizAttemptListItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.difficultyLevel,
    required this.totalQuestions,
    required this.createdAt,
    required this.teacherName,
    required this.bestScore,
    required this.attemptsCount,
  });

  factory QuizAttemptListItem.fromJson(Map<String, dynamic> json) {
    return QuizAttemptListItem(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      difficultyLevel: json['difficulty_level'],
      totalQuestions: json['total_questions'],
      createdAt: DateTime.parse(json['created_at']),
      teacherName: json['teacher_name'],
      bestScore: (json['best_score'] as num).toDouble(),
      attemptsCount: json['attempts_count'],
    );
  }

  String get difficultyDisplayName {
    switch (difficultyLevel) {
      case 'easy':
        return 'Łatwy';
      case 'medium':
        return 'Średni';
      case 'hard':
        return 'Trudny';
      default:
        return difficultyLevel;
    }
  }
}

class QuizAttemptsResponse {
  final List<QuizAttemptListItem> attempts;
  final int totalCount;
  final int limit;
  final int offset;

  QuizAttemptsResponse({
    required this.attempts,
    required this.totalCount,
    required this.limit,
    required this.offset,
  });

  factory QuizAttemptsResponse.fromJson(Map<String, dynamic> json) {
    return QuizAttemptsResponse(
      attempts: (json['attempts'] as List)
          .map((item) => QuizAttemptListItem.fromJson(item))
          .toList(),
      totalCount: json['total_count'],
      limit: json['limit'],
      offset: json['offset'],
    );
  }
}

class QuizDetailUserAnswer {
  final String userAnswer;
  final bool isCorrect;
  final double pointsEarned;

  QuizDetailUserAnswer({
    required this.userAnswer,
    required this.isCorrect,
    required this.pointsEarned,
  });

  factory QuizDetailUserAnswer.fromJson(Map<String, dynamic> json) {
    return QuizDetailUserAnswer(
      userAnswer: json['user_answer'] ?? '',
      isCorrect: json['is_correct'] ?? false,
      pointsEarned: json['points_earned'] != null ? (json['points_earned'] as num).toDouble() : 0.0,
    );
  }
}

class QuizDetailQuestion {
  final String questionText;
  final String correctAnswer;
  final String explanation;
  final QuizDetailUserAnswer? userAnswer;  // Make nullable

  QuizDetailQuestion({
    required this.questionText,
    required this.correctAnswer,
    required this.explanation,
    this.userAnswer,  // Optional
  });

  factory QuizDetailQuestion.fromJson(Map<String, dynamic> json) {
    return QuizDetailQuestion(
      questionText: json['question_text'] ?? '',
      correctAnswer: json['correct_answer'] ?? '',
      explanation: json['explanation'] ?? '',
      userAnswer: json['user_answer'] != null 
          ? QuizDetailUserAnswer.fromJson(json['user_answer'])
          : null,
    );
  }
}

class QuizDetailAttempt {
  final int id;
  final int attemptNumber;
  final double score;
  final double percentage;
  final bool isCompleted;
  final List<QuizDetailQuestion> questions;

  QuizDetailAttempt({
    required this.id,
    required this.attemptNumber,
    required this.score,
    required this.percentage,
    required this.isCompleted,
    required this.questions,
  });

  factory QuizDetailAttempt.fromJson(Map<String, dynamic> json) {
    return QuizDetailAttempt(
      id: json['id'],
      attemptNumber: json['attempt_number'],
      score: json['score'] != null ? (json['score'] as num).toDouble() : 0.0,
      percentage: json['percentage'] != null ? (json['percentage'] as num).toDouble() : 0.0,
      isCompleted: json['is_completed'],
      questions: (json['questions'] as List)
          .map((q) => QuizDetailQuestion.fromJson(q))
          .toList(),
    );
  }
}

class QuizDetailsResponse {
  final int id;
  final String title;
  final String subject;
  final String difficultyLevel;
  final int totalQuestions;
  final String teacherName;
  final List<QuizDetailAttempt> attempts;

  QuizDetailsResponse({
    required this.id,
    required this.title,
    required this.subject,
    required this.difficultyLevel,
    required this.totalQuestions,
    required this.teacherName,
    required this.attempts,
  });

  factory QuizDetailsResponse.fromJson(Map<String, dynamic> json) {
    return QuizDetailsResponse(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      difficultyLevel: json['difficulty_level'],
      totalQuestions: json['total_questions'],
      teacherName: json['teacher_name'],
      attempts: (json['attempts'] as List)
          .map((a) => QuizDetailAttempt.fromJson(a))
          .toList(),
    );
  }

  String get difficultyDisplayName {
    switch (difficultyLevel) {
      case 'easy':
        return 'Łatwy';
      case 'medium':
        return 'Średni';
      case 'hard':
        return 'Trudny';
      default:
        return difficultyLevel;
    }
  }
}
