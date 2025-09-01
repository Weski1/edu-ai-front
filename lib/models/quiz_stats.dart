import 'quiz.dart';

class DashboardStats {
  final int totalQuizzesCompleted;
  final int totalTimeSpentMinutes;
  final double overallAverageScore;
  final List<SubjectStats> subjectsStats;
  final List<QuizAttemptResult> recentAttempts;
  final List<TopicPerformance> weakTopics;
  final List<TopicPerformance> strongTopics;
  final Map<String, double> monthlyProgress;

  DashboardStats({
    required this.totalQuizzesCompleted,
    required this.totalTimeSpentMinutes,
    required this.overallAverageScore,
    required this.subjectsStats,
    required this.recentAttempts,
    required this.weakTopics,
    required this.strongTopics,
    required this.monthlyProgress,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalQuizzesCompleted: json['total_quizzes_completed'] as int,
      totalTimeSpentMinutes: json['total_time_spent_minutes'] as int,
      overallAverageScore: (json['overall_average_score'] as num).toDouble(),
      subjectsStats: (json['subjects_stats'] as List<dynamic>)
          .map((s) => SubjectStats.fromJson(s as Map<String, dynamic>))
          .toList(),
      recentAttempts: (json['recent_attempts'] as List<dynamic>)
          .map((a) => QuizAttemptResult.fromJson(a as Map<String, dynamic>))
          .toList(),
      weakTopics: (json['weak_topics'] as List<dynamic>)
          .map((t) => TopicPerformance.fromJson(t as Map<String, dynamic>))
          .toList(),
      strongTopics: (json['strong_topics'] as List<dynamic>)
          .map((t) => TopicPerformance.fromJson(t as Map<String, dynamic>))
          .toList(),
      monthlyProgress: Map<String, double>.from(json['monthly_progress'] as Map),
    );
  }
}

class SubjectStats {
  final String subject;
  final int totalQuizzes;
  final int totalAttempts;
  final double averageScore;
  final double bestScore;
  final double improvementTrend;

  SubjectStats({
    required this.subject,
    required this.totalQuizzes,
    required this.totalAttempts,
    required this.averageScore,
    required this.bestScore,
    required this.improvementTrend,
  });

  factory SubjectStats.fromJson(Map<String, dynamic> json) {
    return SubjectStats(
      subject: json['subject'] as String,
      totalQuizzes: json['total_quizzes'] as int,
      totalAttempts: json['total_attempts'] as int,
      averageScore: (json['average_score'] as num).toDouble(),
      bestScore: (json['best_score'] as num).toDouble(),
      improvementTrend: (json['improvement_trend'] as num).toDouble(),
    );
  }

  String get subjectDisplayName {
    switch (subject) {
      case 'Mathematics':
        return 'Matematyka';
      case 'Historia':
        return 'Historia';
      case 'English':
        return 'Angielski';
      case 'Biologia':
        return 'Biologia';
      default:
        return subject;
    }
  }

  String get improvementTrendText {
    if (improvementTrend > 5) return 'Rosnący trend 📈';
    if (improvementTrend < -5) return 'Spadkowy trend 📉';
    return 'Stabilny 📊';
  }
}

class TopicPerformance {
  final String topic;
  final String subject;
  final int correctAnswers;
  final int totalQuestions;
  final double accuracyPercentage;

  TopicPerformance({
    required this.topic,
    required this.subject,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.accuracyPercentage,
  });

  factory TopicPerformance.fromJson(Map<String, dynamic> json) {
    return TopicPerformance(
      topic: json['topic'] as String,
      subject: json['subject'] as String,
      correctAnswers: json['correct_answers'] as int,
      totalQuestions: json['total_questions'] as int,
      accuracyPercentage: (json['accuracy_percentage'] as num).toDouble(),
    );
  }

  String get performanceLevel {
    if (accuracyPercentage >= 80) return 'Doskonały';
    if (accuracyPercentage >= 60) return 'Dobry';
    if (accuracyPercentage >= 40) return 'Średni';
    return 'Wymaga poprawy';
  }

  String get performanceEmoji {
    if (accuracyPercentage >= 80) return '🎯';
    if (accuracyPercentage >= 60) return '👍';
    if (accuracyPercentage >= 40) return '📚';
    return '🔄';
  }
}
