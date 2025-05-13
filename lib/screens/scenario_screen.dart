import 'package:flutter/material.dart';

class ScenarioScreen extends StatefulWidget {
  const ScenarioScreen({super.key});

  @override
  State<ScenarioScreen> createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends State<ScenarioScreen> {
  final TextEditingController _promptController = TextEditingController();
  final List<String> _scenarios = [];

  void _saveScenario() {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _scenarios.add(prompt);
      _promptController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Dodaj swój prompt (scenariusz AI)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _promptController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Np. Jesteś nauczycielem matematyki...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _saveScenario,
                child: const Text('Zapisz scenariusz'),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _scenarios.length,
            itemBuilder: (context, index) {
              final prompt = _scenarios[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.chat),
                  title: Text(prompt),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
