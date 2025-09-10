import 'package:flutter/material.dart';
import 'package:praca_inzynierska_front/screens/teachers_screen.dart';
import 'package:praca_inzynierska_front/screens/quiz_screen.dart';
import 'package:praca_inzynierska_front/screens/dashboard_screen.dart';
import 'package:praca_inzynierska_front/screens/user_profile_screen.dart';
import 'package:praca_inzynierska_front/screens/admin/admin_dashboard_screen.dart';
import 'package:praca_inzynierska_front/screens/admin/admin_users_screen.dart';
import 'package:praca_inzynierska_front/screens/admin/admin_teachers_screen.dart';
import 'package:praca_inzynierska_front/utils/admin_utils.dart';

class MainScreen extends StatefulWidget {
  final String token;
  const MainScreen({super.key, required this.token});

  @override
  State<MainScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Widget> _screens = [];
  List<String> _titles = [];
  List<BottomNavigationBarItem> _navItems = [];
  bool _isAdmin = false;
  bool _isLoading = true;
  bool _isAdminMode = false; // Nowa zmienna do przełączania trybu

  @override
  void initState() {
    super.initState();
    _checkAdminStatusAndSetup();
  }

  Future<void> _checkAdminStatusAndSetup() async {
    final isAdmin = await AdminUtils.isAdmin();
    
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        _setupScreensAndNavigation();
        _isLoading = false;
      });
    }
  }

  void _setupScreensAndNavigation() {
    if (_isAdmin && _isAdminMode) {
      // Tryb administratora: zakładki panelu admina
      _screens = [
        AdminDashboardScreen(onNavigateToTab: (index) => setState(() => _selectedIndex = index)),
        const AdminUsersScreen(),
        const AdminTeachersScreen(),
      ];
      _titles = ['Panel Admin', 'Użytkownicy', 'Nauczyciele'];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Panel'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Użytkownicy'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Nauczyciele'),
      ];
      _selectedIndex = 0; // Resetuj indeks
    } else {
      // Tryb użytkownika: standardowe zakładki
      _screens = [
        TeachersScreen(token: widget.token),
        const QuizScreen(),
        const DashboardScreen(),
        const UserProfileScreen(),
      ];
      _titles = ['Nauczyciele', 'Quiz', 'Statystyki', 'Profil'];
      _navItems = [
        const BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Nauczyciele'),
        const BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
        const BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Statystyki'),
        const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
      
      // Jeśli wcześniej był w trybie admin, wróć na pierwszą zakładkę
      if (_selectedIndex >= _screens.length) {
        _selectedIndex = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pokaż loading screen podczas sprawdzania uprawnień administratora
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]), 
        centerTitle: true,
        leading: _isAdmin ? IconButton(
          icon: Icon(_isAdminMode ? Icons.arrow_back : Icons.admin_panel_settings),
          onPressed: () {
            setState(() {
              _isAdminMode = !_isAdminMode;
              _setupScreensAndNavigation();
            });
          },
          tooltip: _isAdminMode ? 'Powrót do trybu użytkownika' : 'Przejdź do panelu admin',
        ) : null,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _isAdmin && _isAdminMode ? Colors.deepPurple : Colors.blue,
        items: _navItems,
      ),
    );
  }
}
