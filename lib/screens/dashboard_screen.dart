import 'package:flutter/material.dart';
import '../models/quiz_stats.dart';
import '../models/quiz.dart';
import '../services/quiz_api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final stats = await QuizApiService.getDashboardStats();

      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        // Fallback to mock data for development
        _stats = _getMockStats();
      });
    }
  }

  DashboardStats _getMockStats() {
    return DashboardStats(
      totalQuizzesCompleted: 12,
      totalTimeSpentMinutes: 240,
      overallAverageScore: 78.5,
      subjectsStats: [
        SubjectStats(
          subject: 'Mathematics',
          totalQuizzes: 5,
          totalAttempts: 8,
          averageScore: 75.0,
          bestScore: 90.0,
          improvementTrend: 12.5,
        ),
        SubjectStats(
          subject: 'Historia',
          totalQuizzes: 4,
          totalAttempts: 6,
          averageScore: 82.0,
          bestScore: 95.0,
          improvementTrend: -2.1,
        ),
        SubjectStats(
          subject: 'English',
          totalQuizzes: 3,
          totalAttempts: 4,
          averageScore: 68.5,
          bestScore: 85.0,
          improvementTrend: 8.3,
        ),
      ],
      recentAttempts: [],
      weakTopics: [
        TopicPerformance(
          topic: 'równania kwadratowe',
          subject: 'Mathematics',
          correctAnswers: 3,
          totalQuestions: 8,
          accuracyPercentage: 37.5,
        ),
        TopicPerformance(
          topic: 'czasowniki modalne',
          subject: 'English',
          correctAnswers: 4,
          totalQuestions: 7,
          accuracyPercentage: 57.1,
        ),
      ],
      strongTopics: [
        TopicPerformance(
          topic: 'rewolucja francuska',
          subject: 'Historia',
          correctAnswers: 9,
          totalQuestions: 10,
          accuracyPercentage: 90.0,
        ),
        TopicPerformance(
          topic: 'funkcje liniowe',
          subject: 'Mathematics',
          correctAnswers: 7,
          totalQuestions: 8,
          accuracyPercentage: 87.5,
        ),
      ],
      monthlyProgress: {
        '2025-01': 65.0,
        '2025-02': 72.5,
        '2025-03': 78.5,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_stats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Błąd podczas ładowania statystyk'),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStats,
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Główne statystyki
            _buildOverallStats(_stats!),
            const SizedBox(height: 24),

            // Statystyki przedmiotów
            _buildSubjectsStats(_stats!),
            const SizedBox(height: 24),

            // Słabe tematy
            if (_stats!.weakTopics.isNotEmpty) ...[
              _buildTopicsSection('Tematy do poprawy', _stats!.weakTopics, Colors.red),
              const SizedBox(height: 24),
            ],

            // Mocne tematy
            if (_stats!.strongTopics.isNotEmpty) ...[
              _buildTopicsSection('Twoje mocne strony', _stats!.strongTopics, Colors.green),
              const SizedBox(height: 24),
            ],

            // Ostatnie próby
            if (_stats!.recentAttempts.isNotEmpty) ...[
              _buildRecentAttempts(_stats!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStats(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Twoje postępy',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Rozwiązane quizy',
                '${stats.totalQuizzesCompleted}',
                Icons.quiz,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Średni wynik',
                '${stats.overallAverageScore.toStringAsFixed(1)}%',
                Icons.trending_up,
                _getScoreColor(stats.overallAverageScore),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'Czas nauki',
          '${stats.totalTimeSpentMinutes} minut',
          Icons.access_time,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSubjectsStats(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Postępy w przedmiotach',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...stats.subjectsStats.map((subject) => _buildSubjectCard(subject)),
      ],
    );
  }

  Widget _buildSubjectCard(SubjectStats subject) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subject.subjectDisplayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getScoreColor(subject.averageScore),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${subject.averageScore.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quizy: ${subject.totalQuizzes}',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  'Próby: ${subject.totalAttempts}',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  'Najlepszy: ${subject.bestScore.toStringAsFixed(1)}%',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subject.improvementTrendText,
              style: TextStyle(
                color: subject.improvementTrend > 0 ? Colors.green : 
                       subject.improvementTrend < 0 ? Colors.red : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsSection(String title, List<TopicPerformance> topics, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...topics.map((topic) => _buildTopicCard(topic, color)),
      ],
    );
  }

  Widget _buildTopicCard(TopicPerformance topic, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              topic.performanceEmoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(topic.topic),
        subtitle: Text('${topic.subject} • ${topic.correctAnswers}/${topic.totalQuestions} poprawnych'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${topic.accuracyPercentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAttempts(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ostatnie próby',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...stats.recentAttempts.take(3).map((attempt) => _buildAttemptCard(attempt)),
      ],
    );
  }

  Widget _buildAttemptCard(QuizAttemptResult attempt) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.quiz,
          color: _getScoreColor(attempt.percentage),
        ),
        title: Text('Quiz #${attempt.quizId}'),
        subtitle: Text('${attempt.correctAnswers}/${attempt.totalQuestions} poprawnych'),
        trailing: Text(
          '${attempt.percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            color: _getScoreColor(attempt.percentage),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
