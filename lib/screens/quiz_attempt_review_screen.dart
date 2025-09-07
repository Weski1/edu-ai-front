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
        // Remove the hardcoded background color to use theme
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Adaptive colors for percentage badge
    final isPassingScore = attempt.percentage >= 50;
    final badgeColor = isPassingScore 
        ? (isDark ? Colors.green.shade600 : Colors.green.shade100)
        : (isDark ? Colors.red.shade600 : Colors.red.shade100);
    final badgeTextColor = isPassingScore
        ? (isDark ? Colors.green.shade100 : Colors.green.shade700)
        : (isDark ? Colors.red.shade100 : Colors.red.shade700);
    final badgeBorderColor = isPassingScore
        ? (isDark ? Colors.green.shade400 : Colors.green.shade300)
        : (isDark ? Colors.red.shade400 : Colors.red.shade300);
    
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
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: badgeBorderColor),
                  ),
                  child: Text(
                    '${attempt.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: badgeTextColor,
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
              style: theme.textTheme.headlineSmall,
            ),
            
            const SizedBox(height: 8),
            
            // Status with theme-aware colors
            Row(
              children: [
                Icon(
                  attempt.isCompleted ? Icons.check_circle : Icons.pending,
                  size: 18,
                  color: attempt.isCompleted 
                      ? (isDark ? Colors.green.shade400 : Colors.green) 
                      : (isDark ? Colors.orange.shade400 : Colors.orange),
                ),
                const SizedBox(width: 6),
                Text(
                  attempt.isCompleted ? 'Ukończone' : 'W trakcie',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: attempt.isCompleted 
                        ? (isDark ? Colors.green.shade400 : Colors.green) 
                        : (isDark ? Colors.orange.shade400 : Colors.orange),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userAnswer = question.userAnswer;
    final isCorrect = userAnswer?.isCorrect ?? false;
    
    // Theme-aware colors for cards
    final cardColor = isCorrect 
        ? (isDark ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade50)
        : (isDark ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50);
    final borderColor = isCorrect 
        ? (isDark ? Colors.green.shade400 : Colors.green) 
        : (isDark ? Colors.red.shade400 : Colors.red);
    final iconColor = isCorrect 
        ? (isDark ? Colors.green.shade400 : Colors.green) 
        : (isDark ? Colors.red.shade400 : Colors.red);

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
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${userAnswer?.pointsEarned.toStringAsFixed(1) ?? '0.0'} pkt',
                  style: theme.textTheme.bodyMedium?.copyWith(
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
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            // Odpowiedź użytkownika with adaptive colors
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect 
                    ? (isDark ? Colors.green.shade800.withOpacity(0.4) : Colors.green.shade100)
                    : (isDark ? Colors.red.shade800.withOpacity(0.4) : Colors.red.shade100),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isCorrect 
                      ? (isDark ? Colors.green.shade400 : Colors.green.shade300)
                      : (isDark ? Colors.red.shade400 : Colors.red.shade300),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Twoja odpowiedź:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userAnswer?.userAnswer ?? 'Brak odpowiedzi',
                    style: theme.textTheme.bodyMedium,
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
                  color: isDark 
                      ? Colors.green.shade800.withOpacity(0.4)
                      : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark ? Colors.green.shade400 : Colors.green.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prawidłowa odpowiedź:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.green.shade400 : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      question.correctAnswer,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Wyjaśnienie with adaptive colors
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.blue.shade900.withOpacity(0.3)
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? Colors.blue.shade400 : Colors.blue.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline, 
                        color: isDark ? Colors.blue.shade400 : Colors.blue, 
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Wyjaśnienie:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.blue.shade400 : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.explanation,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
