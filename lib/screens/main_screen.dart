import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'quiz_screen.dart';
import 'dashboard_screen.dart';
import 'scenario_screen.dart';
// import 'photo_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ChatScreen(),
    ScenarioScreen(),
    QuizScreen(),
    DashboardScreen(),
    // PhotoScreen(),
  ];

  final List<String> _titles = [
    'Czat z AI',
    'Scenariusze',
    'Quiz',
    'Statystyki',
    'Zdjęcie zadania',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Czat'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'Scenariusze'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Statystyki'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Zdjęcie'),
        ],
      ),
    );
  }
}
