import 'package:flutter/material.dart';
import 'dart:async';
import '../models/quiz.dart';
import '../services/quiz_api_service.dart';
import 'quiz_result_screen.dart';

class QuizTakingScreen extends StatefulWidget {
  final int quizId;

  const QuizTakingScreen({super.key, required this.quizId});

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  Quiz? _quiz;
  QuizAttempt? _currentAttempt;
  int _currentQuestionIndex = 0;
  Map<int, String> _answers = {};
  bool _isLoading = true;
  String? _error;
  Timer? _timer;
  int _timeElapsed = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadQuizAndStart();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeElapsed++;
        });
      }
    });
  }

  Future<void> _loadQuizAndStart() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Pobierz quiz
      final quiz = await QuizApiService.getQuiz(widget.quizId);
      
      // Rozpocznij próbę
      final attempt = await QuizApiService.startQuiz(
        QuizAttemptStart(quizId: widget.quizId),
      );

      setState(() {
        _quiz = quiz;
        _currentAttempt = attempt;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitQuiz() async {
    if (_currentAttempt == null || _quiz == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Przygotuj odpowiedzi
      final answersToSubmit = _quiz!.questions.map((question) {
        final userAnswer = _answers[question.id] ?? '';
        return QuizAnswerSubmit(
          questionId: question.id,
          userAnswer: userAnswer,
        );
      }).toList();

      // Wyślij quiz
      final result = await QuizApiService.submitQuiz(
        QuizAttemptSubmit(
          attemptId: _currentAttempt!.id,
          answers: answersToSubmit,
        ),
      );

      if (mounted) {
        // Przejdź do ekranu wyników
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultScreen(result: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas wysyłania: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSubmitConfirmation() {
    // Sprawdź ile pytań nie zostało odpowiedzianych
    final unansweredCount = _quiz!.questions.where((q) => 
      !_answers.containsKey(q.id) || _answers[q.id]!.isEmpty
    ).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zakończ quiz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Czy na pewno chcesz zakończyć quiz?'),
            if (unansweredCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Uwaga: $unansweredCount pytań pozostało bez odpowiedzi.',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text('Czas: ${_formatTime(_timeElapsed)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kontynuuj'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitQuiz();
            },
            child: const Text('Zakończ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ładowanie quizu...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Błąd'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Błąd podczas ładowania quizu'),
              const SizedBox(height: 8),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadQuizAndStart,
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      );
    }

    if (_quiz == null || _currentAttempt == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
        ),
        body: const Center(
          child: Text('Brak danych quizu'),
        ),
      );
    }

    final currentQuestion = _quiz!.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _quiz!.questions.length;

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Opuścić quiz?'),
            content: const Text(
              'Jeśli opuścisz quiz teraz, Twoje odpowiedzi zostaną utracone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Pozostań'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Opuść'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_quiz!.title),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: Text(
                  _formatTime(_timeElapsed),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Pasek postępu
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
            // Informacje o pytaniu
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pytanie ${_currentQuestionIndex + 1} z ${_quiz!.questions.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${currentQuestion.points} pkt',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Pytanie
            Expanded(
              child: _buildQuestionWidget(currentQuestion),
            ),
            // Nawigacja
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Przycisk "Poprzednie"
                  ElevatedButton(
                    onPressed: _currentQuestionIndex > 0
                        ? () {
                            setState(() {
                              _currentQuestionIndex--;
                            });
                          }
                        : null,
                    child: const Text('Poprzednie'),
                  ),
                  // Przycisk "Następne" lub "Zakończ"
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : () {
                      if (_currentQuestionIndex < _quiz!.questions.length - 1) {
                        setState(() {
                          _currentQuestionIndex++;
                        });
                      } else {
                        _showSubmitConfirmation();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentQuestionIndex == _quiz!.questions.length - 1
                          ? Colors.green
                          : Colors.indigo,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _currentQuestionIndex < _quiz!.questions.length - 1
                                ? 'Następne'
                                : 'Zakończ',
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

  Widget _buildQuestionWidget(QuizQuestion question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Typ pytania
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              QuizApiService.getQuestionTypeDisplayName(question.questionType),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Treść pytania
          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // Odpowiedzi w zależności od typu pytania
          _buildAnswerWidget(question),
        ],
      ),
    );
  }

  Widget _buildAnswerWidget(QuizQuestion question) {
    final currentAnswer = _answers[question.id] ?? '';

    switch (question.questionType) {
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceAnswer(question, currentAnswer);
      case QuestionType.trueFalse:
        return _buildTrueFalseAnswer(question, currentAnswer);
      case QuestionType.fillInTheBlank:
      case QuestionType.shortAnswer:
      case QuestionType.calculation:
        return _buildTextAnswer(question, currentAnswer);
      default:
        return _buildTextAnswer(question, currentAnswer);
    }
  }

  Widget _buildMultipleChoiceAnswer(QuizQuestion question, String currentAnswer) {
    final options = question.options ?? {};
    
    return Column(
      children: options.entries.map((entry) {
        final key = entry.key;
        final value = entry.value;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: RadioListTile<String>(
            title: Text('$key) $value'),
            value: key,
            groupValue: currentAnswer.isEmpty ? null : currentAnswer,
            onChanged: (value) {
              setState(() {
                _answers[question.id] = value!;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalseAnswer(QuizQuestion question, String currentAnswer) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: RadioListTile<String>(
            title: const Text('Prawda'),
            value: 'true',
            groupValue: currentAnswer.isEmpty ? null : currentAnswer,
            onChanged: (value) {
              setState(() {
                _answers[question.id] = value!;
              });
            },
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: RadioListTile<String>(
            title: const Text('Fałsz'),
            value: 'false',
            groupValue: currentAnswer.isEmpty ? null : currentAnswer,
            onChanged: (value) {
              setState(() {
                _answers[question.id] = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextAnswer(QuizQuestion question, String currentAnswer) {
    return TextField(
      controller: TextEditingController(text: currentAnswer),
      decoration: const InputDecoration(
        hintText: 'Wpisz swoją odpowiedź...',
        border: OutlineInputBorder(),
      ),
      maxLines: question.questionType == QuestionType.shortAnswer ? 1 : 3,
      onChanged: (value) {
        _answers[question.id] = value;
      },
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
