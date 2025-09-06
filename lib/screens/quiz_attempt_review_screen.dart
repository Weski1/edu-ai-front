import 'package:flutter/material.dart';
import '../models/quiz_attempts.dart';

class QuizAttemptReviewScreen extends StatelessWidget {
  final String quizTitle;
  final QuizDetailAttempt attempt;

  const QuizAttemptReviewScreen({
    super.key,
    required this.quizTitle,
    required this.attempt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(quizTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAttemptSummary(context),
            const SizedBox(height: 24),
            _buildQuestionsReview(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAttemptSummary(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Podejście ${attempt.attemptNumber}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: attempt.percentage >= 50 ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: attempt.percentage >= 50 ? Colors.green.shade300 : Colors.red.shade300,
                    ),
                  ),
                  child: Text(
                    '${attempt.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: attempt.percentage >= 50 ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Wynik punktowy
            Text(
              'Wynik: ${attempt.score.toStringAsFixed(1)} punktów',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            
            const SizedBox(height: 8),
            
            // Status
            Row(
              children: [
                Icon(
                  attempt.isCompleted ? Icons.check_circle : Icons.pending,
                  size: 18,
                  color: attempt.isCompleted ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 6),
                Text(
                  attempt.isCompleted ? 'Ukończone' : 'W trakcie',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: attempt.isCompleted ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsReview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Przegląd odpowiedzi',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...attempt.questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          return _buildQuestionCard(context, question, index + 1);
        }),
      ],
    );
  }

  Widget _buildQuestionCard(BuildContext context, QuizDetailQuestion question, int questionNumber) {
    final userAnswer = question.userAnswer;
    final isCorrect = userAnswer?.isCorrect ?? false;
    final cardColor = isCorrect ? Colors.green.shade50 : Colors.red.shade50;
    final borderColor = isCorrect ? Colors.green : Colors.red;
    final iconColor = isCorrect ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nagłówek z numerem pytania i statusem
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: iconColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pytanie $questionNumber',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${userAnswer?.pointsEarned.toStringAsFixed(1) ?? '0.0'} pkt',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Tekst pytania
            Text(
              question.questionText,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            // Odpowiedź użytkownika
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isCorrect ? Colors.green.shade300 : Colors.red.shade300,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Twoja odpowiedź:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userAnswer?.userAnswer ?? 'Brak odpowiedzi',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            
            // Prawidłowa odpowiedź (jeśli różna od użytkownika)
            if (!isCorrect) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prawidłowa odpowiedź:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      question.correctAnswer,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Wyjaśnienie
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, 
                        color: Colors.blue, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Wyjaśnienie:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.explanation,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
