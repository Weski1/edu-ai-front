import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import '../models/quiz.dart';
import '../services/quiz_api_service.dart';
import '../services/api_client_service.dart';
import '../widgets/latex_text.dart';
import 'quiz_result_screen.dart';

class QuizAttemptScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizAttemptScreen({super.key, required this.quiz});

  @override
  State<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  QuizAttempt? _currentAttempt;
  int _currentQuestionIndex = 0;
  Map<int, String> _userAnswers = {};
  Map<int, List<String>> _imageUrls = {}; // Zmienione na listę obrazów
  Map<int, TextEditingController> _textControllers = {}; // Dodane dla kontrollerów
  Timer? _timer;
  int _timeSpentSeconds = 0;
  bool _isSubmitting = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Inicjalizuj kontrolery dla wszystkich pytań
    for (final question in widget.quiz.questions) {
      _textControllers[question.id] = TextEditingController();
    }
    _startQuiz();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Dispose wszystkich kontrollerów
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _startQuiz() async {
    try {
      final attempt = await QuizApiService.startQuiz(
        QuizAttemptStart(quizId: widget.quiz.id),
      );
      setState(() {
        _currentAttempt = attempt;
      });
      _startTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd rozpoczynania quizu: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeSpentSeconds++;
      });
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  TextEditingController _getController(int questionId) {
    return _textControllers[questionId] ?? TextEditingController();
  }

  void _updateAnswer(int questionId, String answer) {
    _userAnswers[questionId] = answer;
    // Nie potrzebujemy setState tutaj, bo kontroler już zarządza tekstem
  }

  Future<void> _submitQuiz() async {
    if (_isSubmitting || _currentAttempt == null) return;

    print('DEBUG: Starting quiz submission...');
    
    // Sprawdź czy są puste odpowiedzi AI
    final emptyAiQuestions = widget.quiz.questions
        .where((q) => q.requiresAiGrading && (_userAnswers[q.id] ?? '').trim().isEmpty)
        .toList();

    print('DEBUG: Checking ${widget.quiz.questions.length} questions for empty AI answers');
    for (var q in widget.quiz.questions) {
      final answer = _userAnswers[q.id] ?? '';
      print('DEBUG: Question ${q.id}: requiresAiGrading=${q.requiresAiGrading}, answer="${answer.isEmpty ? "EMPTY" : answer.substring(0, answer.length < 20 ? answer.length : 20)}"');
    }
    print('DEBUG: Found ${emptyAiQuestions.length} empty AI questions: ${emptyAiQuestions.map((q) => q.id).toList()}');
    print('DEBUG: emptyAiQuestions.isNotEmpty = ${emptyAiQuestions.isNotEmpty}');

    if (emptyAiQuestions.isNotEmpty) {
      print('DEBUG: Showing AI validation dialog...');
      
      try {
        final shouldContinue = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            print('DEBUG: Inside dialog builder');
            return AlertDialog(
              title: const Text('Puste odpowiedzi AI'),
              content: Text(
                'Masz ${emptyAiQuestions.length} pytań sprawdzanych przez AI z pustymi odpowiedziami. '
                'Te pytania otrzymają 0 punktów. Czy chcesz kontynuować?'
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    print('DEBUG: User clicked Cancel in AI dialog');
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Anuluj'),
                ),
                TextButton(
                  onPressed: () {
                    print('DEBUG: User clicked Continue in AI dialog');
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Kontynuuj'),
                ),
              ],
            );
          },
        );
        
        print('DEBUG: AI dialog result: $shouldContinue');
        if (shouldContinue != true) {
          print('DEBUG: User cancelled - returning');
          return;
        }
      } catch (e) {
        print('DEBUG: Error showing dialog: $e');
      }
    } else {
      print('DEBUG: No empty AI questions found, proceeding directly');
    }

    print('DEBUG: Proceeding with submission...');
    setState(() {
      _isSubmitting = true;
    });

    _timer?.cancel();

    try {
      final answers = widget.quiz.questions.map((question) {
        final userAnswer = _userAnswers[question.id] ?? '';
        final imageUrls = _imageUrls[question.id];
        final imageUrl = (imageUrls?.isNotEmpty == true) 
            ? imageUrls!.join(',') // Łączymy wszystkie URLs przecinkami
            : null;
        
        // Debug info dla każdej odpowiedzi
        print('DEBUG Submit - Question ${question.id}: "${userAnswer}" (empty: ${userAnswer.isEmpty})');
        if (question.requiresAiGrading && userAnswer.isEmpty) {
          print('WARNING: AI question ${question.id} has empty answer but will be graded!');
        }
        
        return QuizAnswerSubmit(
          questionId: question.id,
          userAnswer: userAnswer,
          imageUrl: imageUrl, // Dodane dla obrazów
        );
      }).toList();

      print('DEBUG Submit - Total answers: ${answers.length}');
      print('DEBUG Submit - Time spent (frontend): $_timeSpentSeconds seconds');

      final result = await QuizApiService.submitQuiz(
        QuizAttemptSubmit(
          attemptId: _currentAttempt!.id,
          answers: answers,
          timeSpentSeconds: _timeSpentSeconds,
        ),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => QuizResultScreen(result: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd przesyłania quizu: $e')),
        );
      }
    }
  }

  // Funkcja do budowania pełnego URL obrazu
  String _buildFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    
    // Jeśli już jest pełny URL, zwróć go
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    
    // W przeciwnym razie dodaj base URL
    return '${ApiClient.baseUrl}$imageUrl';
  }

  Future<void> _pickImage(int questionId) async {
    try {
      // Show option to choose single or multiple images
      final String? choice = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Dodaj zdjęcia'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Zrób zdjęcie'),
                  onTap: () => Navigator.of(context).pop('single_camera'),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Wybierz jedno zdjęcie'),
                  onTap: () => Navigator.of(context).pop('single_gallery'),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Wybierz wiele zdjęć'),
                  onTap: () => Navigator.of(context).pop('multiple_gallery'),
                ),
              ],
            ),
          );
        },
      );

      if (choice == null) return;

      if (choice == 'multiple_gallery') {
        await _pickMultipleImages(questionId);
      } else {
        await _pickSingleImage(questionId, choice);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas wyboru zdjęcia: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pickSingleImage(int questionId, String choice) async {
    try {
      final ImageSource source = choice == 'single_camera' ? ImageSource.camera : ImageSource.gallery;
      
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Przesyłanie zdjęcia...'),
                ],
              ),
              duration: Duration(seconds: 5),
            ),
          );
        }

        // Upload image
        final imageUrl = await QuizApiService.uploadQuizImage(image.path);
        
        setState(() {
          if (_imageUrls[questionId] == null) {
            _imageUrls[questionId] = [];
          }
          _imageUrls[questionId]!.add(imageUrl);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Zdjęcie zostało przesłane pomyślnie!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd przesyłania zdjęcia: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pickMultipleImages(int questionId) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        // Limit to 5 images total per question
        final currentImagesCount = _imageUrls[questionId]?.length ?? 0;
        final availableSlots = 5 - currentImagesCount;
        
        if (availableSlots <= 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Maksymalnie 5 zdjęć na pytanie'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }

        final imagesToUpload = images.take(availableSlots).toList();
        
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text('Przesyłanie ${imagesToUpload.length} zdjęć...'),
                ],
              ),
              duration: const Duration(seconds: 10),
            ),
          );
        }

        // Upload multiple images using the backend endpoint
        final imagePaths = imagesToUpload.map((img) => img.path).toList();
        final imageUrls = await QuizApiService.uploadMultipleQuizImages(imagePaths);
        
        setState(() {
          if (_imageUrls[questionId] == null) {
            _imageUrls[questionId] = [];
          }
          _imageUrls[questionId]!.addAll(imageUrls);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${imageUrls.length} zdjęć zostało przesłanych pomyślnie!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas przesyłania zdjęć: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showSubmitConfirmation() {
    final unanswered = widget.quiz.questions.where(
      (q) => !_userAnswers.containsKey(q.id) || _userAnswers[q.id]!.isEmpty,
    ).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zakończyć quiz?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Odpowiedziałeś na ${widget.quiz.questions.length - unanswered} z ${widget.quiz.questions.length} pytań.'),
            if (unanswered > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Pozostało $unanswered pytań bez odpowiedzi.',
                style: const TextStyle(color: Colors.orange),
              ),
            ],
            const SizedBox(height: 8),
            Text('Czas: ${_formatTime(_timeSpentSeconds)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
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
    if (_currentAttempt == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = widget.quiz.questions[_currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                _formatTime(_timeSpentSeconds),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pytanie ${_currentQuestionIndex + 1} z ${widget.quiz.questions.length}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${((_currentQuestionIndex + 1) / widget.quiz.questions.length * 100).round()}%',
                      style: const TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
            ),
          ),
          
          // Question content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildQuestion(currentQuestion),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousQuestion,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Poprzednie'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  child: _currentQuestionIndex < widget.quiz.questions.length - 1
                      ? ElevatedButton.icon(
                          onPressed: _nextQuestion,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Następne'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _showSubmitConfirmation,
                          icon: _isSubmitting 
                              ? const SizedBox(
                                  width: 16, 
                                  height: 16, 
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ) 
                              : const Icon(Icons.check),
                          label: Text(_isSubmitting ? 'Wysyłanie...' : 'Zakończ quiz'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.tertiary,
                            foregroundColor: Theme.of(context).colorScheme.onTertiary,
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(QuizQuestion question) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question type and points
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    question.questionType.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${question.points} pkt',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Question text
            LaTeXText(
              text: question.questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 20),

            // Answer input based on question type
            _buildAnswerInput(question),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerInput(QuizQuestion question) {
    final currentAnswer = _userAnswers[question.id] ?? '';

    switch (question.questionType) {
      case QuestionType.multipleChoice:
        return _buildMultipleChoice(question, currentAnswer);
      case QuestionType.trueFalse:
        return _buildTrueFalse(question, currentAnswer);
      case QuestionType.fillInTheBlank:
      case QuestionType.shortAnswer:
      case QuestionType.calculation:
        return _buildTextInput(question, currentAnswer);
      case QuestionType.matching:
        return _buildMatching(question, currentAnswer);
      case QuestionType.ordering:
        return _buildOrdering(question, currentAnswer);
      case QuestionType.openEnded:
      case QuestionType.essay:
        return _buildLongTextInput(question, currentAnswer);
      case QuestionType.mathematicalProof:
      case QuestionType.problemSolving:
      case QuestionType.graphAnalysis:
        return _buildStructuredInput(question, currentAnswer);
    }
  }

  Widget _buildMultipleChoice(QuizQuestion question, String currentAnswer) {
    if (question.options == null) return const Text('Brak opcji do wyboru');

    final options = question.options!;
    
    return Column(
      children: options.entries.map((entry) {
        final optionKey = entry.key;
        final optionValue = entry.value.toString();
        
        return RadioListTile<String>(
          title: Text(optionValue),
          value: optionKey,
          groupValue: currentAnswer,
          onChanged: (value) {
            if (value != null) {
              _updateAnswer(question.id, value);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalse(QuizQuestion question, String currentAnswer) {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Prawda'),
          value: 'true',
          groupValue: currentAnswer,
          onChanged: (value) {
            if (value != null) {
              _updateAnswer(question.id, value);
            }
          },
        ),
        RadioListTile<String>(
          title: const Text('Fałsz'),
          value: 'false',
          groupValue: currentAnswer,
          onChanged: (value) {
            if (value != null) {
              _updateAnswer(question.id, value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTextInput(QuizQuestion question, String currentAnswer) {
    final controller = _getController(question.id);
    if (controller.text != currentAnswer) {
      controller.text = currentAnswer;
    }
    
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        hintText: 'Wpisz swoją odpowiedź...',
        border: OutlineInputBorder(),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      maxLines: question.questionType == QuestionType.calculation ? 3 : 1,
      onChanged: (value) => _updateAnswer(question.id, value),
    );
  }

  Widget _buildLongTextInput(QuizQuestion question, String currentAnswer) {
    final controller = _getController(question.id);
    if (controller.text != currentAnswer) {
      controller.text = currentAnswer;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Napisz szczegółową odpowiedź...',
            border: OutlineInputBorder(),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          maxLines: 8,
          onChanged: (value) => _updateAnswer(question.id, value),
        ),
        const SizedBox(height: 12),
        
        // Image upload section
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(question.id),
              icon: const Icon(Icons.camera_alt),
              label: Text('Dodaj zdjęcie${(_imageUrls[question.id]?.length ?? 0) < 5 ? ' (${(_imageUrls[question.id]?.length ?? 0)}/5)' : ' (max)'}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: (_imageUrls[question.id]?.length ?? 0) >= 5 
                    ? Colors.grey.shade200 
                    : Colors.blue.shade100,
                foregroundColor: (_imageUrls[question.id]?.length ?? 0) >= 5 
                    ? Colors.grey.shade600 
                    : Colors.blue.shade800,
              ),
            ),
            const SizedBox(width: 12),
            if (_imageUrls[question.id] != null && _imageUrls[question.id]!.isNotEmpty)
              Expanded(
                child: Text(
                  '${_imageUrls[question.id]!.length} ${_imageUrls[question.id]!.length == 1 ? 'zdjęcie' : 'zdjęć'} załączone ✓',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        
        // Display uploaded images if exist
        if (_imageUrls[question.id] != null && _imageUrls[question.id]!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Załączone zdjęcia (${_imageUrls[question.id]!.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imageUrls[question.id]!.length,
                    itemBuilder: (context, index) {
                      final imageUrl = _imageUrls[question.id]![index];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _buildFullImageUrl(imageUrl),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading image: $imageUrl, Full URL: ${_buildFullImageUrl(imageUrl)}');
                                  print('Error details: $error');
                                  return Container(
                                    color: Colors.grey.shade100,
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error_outline, color: Colors.grey, size: 20),
                                          SizedBox(height: 4),
                                          Text('Błąd', 
                                               style: TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Delete button
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _imageUrls[question.id]!.removeAt(index);
                                    if (_imageUrls[question.id]!.isEmpty) {
                                      _imageUrls.remove(question.id);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade600,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStructuredInput(QuizQuestion question, String currentAnswer) {
    final controller = _getController(question.id);
    if (controller.text != currentAnswer) {
      controller.text = currentAnswer;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: _getHintForStructuredType(question.questionType),
            border: const OutlineInputBorder(),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          maxLines: 10,
          onChanged: (value) => _updateAnswer(question.id, value),
        ),
        const SizedBox(height: 8),
        Text(
          _getTipForStructuredType(question.questionType),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildMatching(QuizQuestion question, String currentAnswer) {
    // Simplified implementation - can be expanded
    return _buildTextInput(question, currentAnswer);
  }

  Widget _buildOrdering(QuizQuestion question, String currentAnswer) {
    // Simplified implementation - can be expanded  
    return _buildTextInput(question, currentAnswer);
  }

  String _getHintForStructuredType(QuestionType type) {
    switch (type) {
      case QuestionType.mathematicalProof:
        return 'Napisz pełny dowód krok po kroku...';
      case QuestionType.problemSolving:
        return 'Opisz proces rozwiązania problemu...';
      case QuestionType.graphAnalysis:
        return 'Przeanalizuj wykres i opisz swoje wnioski...';
      default:
        return 'Napisz szczegółową odpowiedź...';
    }
  }

  String _getTipForStructuredType(QuestionType type) {
    switch (type) {
      case QuestionType.mathematicalProof:
        return 'Podaj założenia, kolejne kroki logiczne i wnioski.';
      case QuestionType.problemSolving:
        return 'Opisz strategie, zastosowane metody i uzasadnij wybory.';
      case QuestionType.graphAnalysis:
        return 'Omów trendy, punkty charakterystyczne i interpretację danych.';
      default:
        return 'Bądź precyzyjny i uzasadnij swoją odpowiedź.';
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
