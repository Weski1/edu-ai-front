import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mockowane dane
    final int quizzesTaken = 12;
    final double averageScore = 78.5;
    final String hardestTopic = 'Równania kwadratowe';
    final List<String> recommendedTopics = ['Funkcje liniowe', 'Trygonometria', 'Czasowniki modalne'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Twoje postępy',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStatCard('Rozwiązane quizy', '$quizzesTaken'),
          _buildStatCard('Średni wynik', '${averageScore.toStringAsFixed(1)}%'),
          _buildStatCard('Najtrudniejszy temat', hardestTopic),
          const SizedBox(height: 24),
          const Text(
            'Sugestie do powtórki',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...recommendedTopics.map((topic) => ListTile(
                leading: const Icon(Icons.refresh),
                title: Text(topic),
              )),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.check_circle_outline),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
