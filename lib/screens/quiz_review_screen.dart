import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/quiz_api_service.dart';

class QuizReviewScreen extends StatefulWidget {
  final int quizId;
  final String quizTitle;

  const QuizReviewScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  State<QuizReviewScreen> createState() => _QuizReviewScreenState();
}

class _QuizReviewScreenState extends State<QuizReviewScreen> {
  QuizReviewData? _quizReviewData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuizDetails();
  }

  Future<void> _loadQuizDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final details = await QuizApiService.getQuizDetails(widget.quizId);
      
      setState(() {
        _quizReviewData = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : _quizReviewData != null
                  ? _buildQuizReview()
                  : const Center(child: Text('Brak danych')),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Błąd podczas ładowania szczegółów quizu',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadQuizDetails,
            child: const Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizReview() {
    final quiz = _quizReviewData!.quiz;
    final attemptResult = _quizReviewData!.attemptResult;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuizHeader(quiz),
          const SizedBox(height: 16),
          _buildAttemptSummary(attemptResult),
          const SizedBox(height: 24),
          _buildQuestionsReview(quiz, attemptResult),
        ],
      ),
    );
  }

  Widget _buildQuizHeader(Quiz quiz) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quiz.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.book, size: 16),
                const SizedBox(width: 4),
                Text(quiz.subject),
                const SizedBox(width: 16),
                const Icon(Icons.school, size: 16),
                const SizedBox(width: 4),
                Text(quiz.teacherName),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttemptSummary(QuizAttemptResult attemptResult) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wynik ostatniego podejścia',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${attemptResult.score.toStringAsFixed(1)} / ${attemptResult.maxScore.toStringAsFixed(1)} punktów',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(width: 16),
                Text(
                  '${attemptResult.percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: attemptResult.percentage >= 50 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Poprawnych odpowiedzi: ${attemptResult.correctAnswers} / ${attemptResult.totalQuestions}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Czas: ${_formatTimeSpent(attemptResult.timeSpentSeconds)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeSpent(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  Widget _buildQuestionsReview(Quiz quiz, QuizAttemptResult attemptResult) {
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
        ...quiz.questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          
          // Znajdź odpowiedź dla tego pytania
          final answer = attemptResult.answers.firstWhere(
            (a) => a.questionId == question.id,
            orElse: () => QuizAnswer(
              id: 0,
              questionId: question.id,
              userAnswer: null,
              isCorrect: false,
              answeredAt: DateTime.now(),
            ),
          );
          
          return _buildQuestionCard(question, answer, index + 1);
        }),
      ],
    );
  }

  Widget _buildQuestionCard(QuizQuestion question, QuizAnswer answer, int questionNumber) {
    final isCorrect = answer.isCorrect;
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
                  '${answer.pointsEarned.toStringAsFixed(1)} pkt',
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
                    answer.userAnswer ?? 'Brak odpowiedzi',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Prawidłowa odpowiedź (jeśli różna od użytkownika)
            if (!isCorrect) ...[
              Container(
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
              const SizedBox(height: 12),
            ],
            
            // AI Feedback
            if (answer.aiFeedback != null && answer.aiFeedback!.isNotEmpty) ...[
              Container(
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
                          'Wyjaśnienie AI:',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      answer.aiFeedback!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
