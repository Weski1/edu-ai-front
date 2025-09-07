import 'package:flutter/material.dart';
import 'quiz_list_screen.dart';
import 'quiz_attempts_list_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            // Custom tab bar without the ugly AppBar
            Container(
              padding: const EdgeInsets.only(top: 8),
              child: TabBar(
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                tabs: const [
                  Tab(icon: Icon(Icons.quiz), text: 'Moje quizy'),
                  Tab(icon: Icon(Icons.assignment_turned_in), text: 'Rozwiązane'),
                ],
              ),
            ),
            // Tab view content
            const Expanded(
              child: TabBarView(
                children: [
                  QuizListScreen(showAppBar: false),
                  QuizAttemptsListScreen(showAppBar: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
