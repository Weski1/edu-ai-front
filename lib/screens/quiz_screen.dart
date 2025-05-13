import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? _selected;
  bool _answered = false;
  final int _correctIndex = 0; // Poprawna odpowiedź: A

  final List<String> _options = [
    'y = 2x + 3',
    'y = x²',
    'y = √x',
    'y = 1/x',
  ];

  void _checkAnswer() {
    setState(() {
      _answered = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temat: Funkcje liniowe',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Które z poniższych równań przedstawia funkcję liniową?',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ...List.generate(_options.length, (index) {
            final isCorrect = index == _correctIndex;
            final isSelected = index == _selected;
            Color? color;
            if (_answered) {
              if (isSelected && isCorrect) {
                color = Colors.green[300];
              } else if (isSelected && !isCorrect) {
                color = Colors.red[300];
              }
            }
            return Card(
              color: color,
              child: ListTile(
                title: Text(_options[index]),
                leading: Radio<int>(
                  value: index,
                  groupValue: _selected,
                  onChanged: _answered
                      ? null
                      : (value) => setState(() => _selected = value),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _selected == null || _answered ? null : _checkAnswer,
            child: const Text('Sprawdź odpowiedź'),
          ),
          if (_answered)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _selected == _correctIndex
                    ? '✅ Brawo! Poprawna odpowiedź.'
                    : '❌ Niestety, to niepoprawna odpowiedź.',
                style: const TextStyle(fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}
