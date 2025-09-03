import 'package:flutter/material.dart';
import 'package:praca_inzynierska_front/screens/teachers_screen.dart';
import 'package:praca_inzynierska_front/screens/quiz_screen.dart';
import 'package:praca_inzynierska_front/screens/dashboard_screen.dart';
import 'package:praca_inzynierska_front/screens/user_profile_screen.dart';

class MainScreen extends StatefulWidget {
  final String token;
  const MainScreen({super.key, required this.token});

  @override
  State<MainScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      TeachersScreen(token: widget.token),
      const QuizScreen(),
      const DashboardScreen(),
      const UserProfileScreen(),
    ];
  }

  final List<String> _titles = const ['Nauczyciele', 'Quiz', 'Statystyki', 'Profil'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex]), centerTitle: true),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Nauczyciele'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Statystyki'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
