import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/quiz_api_service.dart';

class SimpleQuizReviewScreen extends StatefulWidget {
  final int quizId;
  final String quizTitle;

  const SimpleQuizReviewScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  State<SimpleQuizReviewScreen> createState() => _SimpleQuizReviewScreenState();
}

class _SimpleQuizReviewScreenState extends State<SimpleQuizReviewScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Quiz? _quiz;
  QuizAttemptResult? _lastAttempt;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Pobieramy podstawowe informacje o quizie
      final quiz = await QuizApiService.getQuiz(widget.quizId);
      // Pobieramy ostatnie podejście
      final lastAttempt = await QuizApiService.getLastAttemptResult(widget.quizId);

      setState(() {
        _quiz = quiz;
        _lastAttempt = lastAttempt;
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
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Brak podejść do tego quizu',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : _buildReviewContent(),
    );
  }

  Widget _buildReviewContent() {
    if (_quiz == null || _lastAttempt == null) {
      return const Center(
        child: Text('Brak danych do wyświetlenia'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuizInfo(),
          const SizedBox(height: 24),
          _buildAttemptInfo(),
          const SizedBox(height: 24),
          _buildQuestionsReview(),
        ],
      ),
    );
  }

  Widget _buildQuizInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _quiz!.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Przedmiot: ${_quiz!.subject}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Poziom: ${_quiz!.difficultyLevel.displayName}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Liczba pytań: ${_quiz!.questions.length}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttemptInfo() {
    return Card(
      color: _lastAttempt!.percentage >= 60 ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Punkty: ${_lastAttempt!.score.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      'Procent: ${_lastAttempt!.percentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _lastAttempt!.percentage >= 60 ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ],
                ),
                Icon(
                  _lastAttempt!.percentage >= 60 ? Icons.check_circle : Icons.cancel,
                  size: 48,
                  color: _lastAttempt!.percentage >= 60 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsReview() {
    if (_lastAttempt!.answers.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Brak szczegółowych odpowiedzi do wyświetlenia'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Szczegółowy przegląd pytań',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_quiz!.questions.length, (index) {
          final question = _quiz!.questions[index];
          final userAnswer = index < _lastAttempt!.answers.length 
              ? _lastAttempt!.answers[index] 
              : null;
          
          return _buildQuestionCard(question, userAnswer, index + 1);
        }),
      ],
    );
  }

  Widget _buildQuestionCard(QuizQuestion question, QuizAnswer? userAnswer, int questionNumber) {
    final isCorrect = userAnswer?.isCorrect ?? false;
    final cardColor = isCorrect ? Colors.green[50] : Colors.red[50];
    final borderColor = isCorrect ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nagłówek pytania
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: borderColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Pytanie $questionNumber',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: borderColor[700],
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: borderColor,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Treść pytania
            Text(
              question.questionText,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            
            // Dla quizów typu multiple choice wyświetlamy opcje
            if (question.options != null) ...[
              ...(question.options!['options'] as List<dynamic>?)?.asMap().entries.map((entry) {
                final optionIndex = entry.key;
                final optionText = entry.value as String;
                final isUserAnswer = userAnswer?.userAnswer == optionText;
                final isCorrectAnswer = question.correctAnswer == optionText;
                
                Color? optionColor;
                IconData? optionIcon;
                
                if (isCorrectAnswer) {
                  optionColor = Colors.green;
                  optionIcon = Icons.check_circle;
                } else if (isUserAnswer && !isCorrectAnswer) {
                  optionColor = Colors.red;
                  optionIcon = Icons.cancel;
                }
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: optionColor?.withOpacity(0.1),
                    border: Border.all(
                      color: optionColor ?? Colors.grey[300]!,
                      width: optionColor != null ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${String.fromCharCode(65 + optionIndex)}. $optionText',
                          style: TextStyle(
                            fontWeight: optionColor != null ? FontWeight.bold : FontWeight.normal,
                            color: optionColor ?? Colors.black87,
                          ),
                        ),
                      ),
                      if (optionIcon != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          optionIcon,
                          color: optionColor,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                );
              }).toList() ?? [],
            ] else ...[
              // Dla pytań otwartych wyświetlamy odpowiedzi tekstowo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Twoja odpowiedź:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(userAnswer?.userAnswer ?? 'Brak odpowiedzi'),
                    const SizedBox(height: 12),
                    Text(
                      'Poprawna odpowiedź:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(question.correctAnswer),
                  ],
                ),
              ),
            ],
            
            // Wyjaśnienie (jeśli dostępne)
            if (question.explanation?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Wyjaśnienie',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.explanation!,
                      style: Theme.of(context).textTheme.bodyMedium,
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
