class QuizAnswerDetail {
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

  QuizAnswerDetail({
    required this.id,
    required this.questionId,
    this.userAnswer,
    required this.isCorrect,
    required this.pointsEarned,
    required this.answeredAt,
    this.aiFeedback,
    this.aiStrengths,
    this.aiImprovements,
    this.imageUrl,
  });

  factory QuizAnswerDetail.fromJson(Map<String, dynamic> json) {
    return QuizAnswerDetail(
      id: json['id'],
      questionId: json['question_id'],
      userAnswer: json['user_answer'],
      isCorrect: json['is_correct'],
      pointsEarned: json['points_earned'].toDouble(),
      answeredAt: DateTime.parse(json['answered_at']),
      aiFeedback: json['ai_feedback'],
      aiStrengths: json['ai_strengths'],
      aiImprovements: json['ai_improvements'],
      imageUrl: json['image_url'],
    );
  }
}

class QuizQuestionDetail {
  final int id;
  final int questionNumber;
  final String questionType;
  final String questionText;
  final String correctAnswer;
  final Map<String, dynamic>? options;
  final String? explanation;
  final int points;
  final String? topic;
  final bool requiresAiGrading;
  final Map<String, dynamic>? aiGradingCriteria;
  final QuizAnswerDetail? userAnswer;

  QuizQuestionDetail({
    required this.id,
    required this.questionNumber,
    required this.questionType,
    required this.questionText,
    required this.correctAnswer,
    this.options,
    this.explanation,
    required this.points,
    this.topic,
    required this.requiresAiGrading,
    this.aiGradingCriteria,
    this.userAnswer,
  });

  factory QuizQuestionDetail.fromJson(Map<String, dynamic> json) {
    return QuizQuestionDetail(
      id: json['id'],
      questionNumber: json['question_number'],
      questionType: json['question_type'],
      questionText: json['question_text'],
      correctAnswer: json['correct_answer'],
      options: json['options'],
      explanation: json['explanation'],
      points: json['points'],
      topic: json['topic'],
      requiresAiGrading: json['requires_ai_grading'],
      aiGradingCriteria: json['ai_grading_criteria'],
      userAnswer: json['user_answer'] != null 
          ? QuizAnswerDetail.fromJson(json['user_answer'])
          : null,
    );
  }
}

class QuizAttemptDetail {
  final int id;
  final int attemptNumber;
  final DateTime startedAt;
  final DateTime? completedAt;
  final double? score;
  final double maxScore;
  final double? percentage;
  final int? timeSpentSeconds;
  final bool isCompleted;
  final List<QuizQuestionDetail> questions;

  QuizAttemptDetail({
    required this.id,
    required this.attemptNumber,
    required this.startedAt,
    this.completedAt,
    this.score,
    required this.maxScore,
    this.percentage,
    this.timeSpentSeconds,
    required this.isCompleted,
    required this.questions,
  });

  factory QuizAttemptDetail.fromJson(Map<String, dynamic> json) {
    return QuizAttemptDetail(
      id: json['id'],
      attemptNumber: json['attempt_number'],
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'])
          : null,
      score: json['score']?.toDouble(),
      maxScore: json['max_score'].toDouble(),
      percentage: json['percentage']?.toDouble(),
      timeSpentSeconds: json['time_spent_seconds'],
      isCompleted: json['is_completed'],
      questions: (json['questions'] as List)
          .map((q) => QuizQuestionDetail.fromJson(q))
          .toList(),
    );
  }

  String get formattedTimeSpent {
    if (timeSpentSeconds == null) return 'Nieznany';
    final minutes = timeSpentSeconds! ~/ 60;
    final seconds = timeSpentSeconds! % 60;
    return '${minutes}m ${seconds}s';
  }
}

class QuizDetailResponse {
  final int id;
  final String title;
  final String subject;
  final String? topic;
  final String difficultyLevel;
  final int totalQuestions;
  final DateTime createdAt;
  final String teacherName;
  final List<QuizAttemptDetail> attempts;

  QuizDetailResponse({
    required this.id,
    required this.title,
    required this.subject,
    this.topic,
    required this.difficultyLevel,
    required this.totalQuestions,
    required this.createdAt,
    required this.teacherName,
    required this.attempts,
  });

  factory QuizDetailResponse.fromJson(Map<String, dynamic> json) {
    return QuizDetailResponse(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      topic: json['topic'],
      difficultyLevel: json['difficulty_level'],
      totalQuestions: json['total_questions'],
      createdAt: DateTime.parse(json['created_at']),
      teacherName: json['teacher_name'],
      attempts: (json['attempts'] as List)
          .map((a) => QuizAttemptDetail.fromJson(a))
          .toList(),
    );
  }

  QuizAttemptDetail? get lastAttempt => 
      attempts.isEmpty ? null : attempts.first;

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
