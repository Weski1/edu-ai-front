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
        appBar: AppBar(
          title: const Text('Quizy'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.quiz), text: 'Moje quizy'),
              Tab(icon: Icon(Icons.assignment_turned_in), text: 'Rozwiązane'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            QuizListScreen(showAppBar: false),
            QuizAttemptsListScreen(showAppBar: false),
          ],
        ),
      ),
    );
  }
}
