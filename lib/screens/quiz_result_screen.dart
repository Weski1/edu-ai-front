import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/quiz_api_service.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizAttemptResult result;

  const QuizResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wyniki Quiz'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Podsumowanie wyników
            _buildResultsSummary(),
            const SizedBox(height: 24),
            // Szczegółowe odpowiedzi
            _buildDetailedAnswers(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Powrót do listy'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Wyślij dane o wynikach przez Navigator
                  Navigator.pop(context, result);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Rozwiąż ponownie'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSummary() {
    final performanceLevel = QuizApiService.getPerformanceLevel(result.percentage);
    final performanceEmoji = QuizApiService.getPerformanceEmoji(result.percentage);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Emoji i poziom wydajności
            Text(
              performanceEmoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),
            Text(
              performanceLevel,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Wynik procentowy
            Text(
              '${result.percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: _getScoreColor(result.percentage),
              ),
            ),
            const SizedBox(height: 8),
            // Punkty
            Text(
              '${result.score.toStringAsFixed(1)} / ${result.maxScore.toStringAsFixed(1)} punktów',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            // Statystyki
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  Icons.check_circle,
                  'Poprawne',
                  '${result.correctAnswers}',
                  Colors.green,
                ),
                _buildStatItem(
                  Icons.cancel,
                  'Niepoprawne',
                  '${result.totalQuestions - result.correctAnswers}',
                  Colors.red,
                ),
                _buildStatItem(
                  Icons.access_time,
                  'Czas',
                  QuizApiService.formatDuration(result.timeSpentSeconds),
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedAnswers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Szczegółowe odpowiedzi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...result.answers.asMap().entries.map((entry) {
          final index = entry.key;
          final answer = entry.value;
          return _buildAnswerCard(index + 1, answer);
        }).toList(),
      ],
    );
  }

  Widget _buildAnswerCard(int questionNumber, QuizAnswer answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nagłówek pytania
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: answer.isCorrect ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      questionNumber.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pytanie $questionNumber',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: answer.isCorrect ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    answer.isCorrect ? 'Poprawne' : 'Niepoprawne',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Odpowiedź użytkownika
            _buildAnswerDetail('Twoja odpowiedź:', answer.userAnswer ?? 'Brak odpowiedzi'),
            const SizedBox(height: 8),
            // Punkty
            _buildAnswerDetail(
              'Punkty:',
              '${answer.pointsEarned.toStringAsFixed(1)} / ${_getMaxPointsForAnswer(answer)} pkt',
            ),
            // TODO: Dodać poprawną odpowiedź i wyjaśnienie gdy będzie dostępne w API
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerDetail(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  double _getMaxPointsForAnswer(QuizAnswer answer) {
    // TODO: Pobierz rzeczywiste punkty z pytania, obecnie zakładamy 1 punkt
    return 1.0;
  }
}
