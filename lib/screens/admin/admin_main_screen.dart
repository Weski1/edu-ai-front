import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'admin_dashboard_screen.dart';
import 'admin_teachers_screen.dart';
import 'admin_users_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;
  
  List<Widget> get _screens => [
    AdminDashboardScreen(onNavigateToTab: (index) => setState(() => _selectedIndex = index)),
    const AdminUsersScreen(),
    const AdminTeachersScreen(),
   
  ];

  final List<String> _titles = [
    'Panel administracyjny',
    'Użytkownicy',
    'Nauczyciele',
    'Przegląd konwersacji',
  ];

  final List<IconData> _icons = [
    Icons.dashboard,
    Icons.people,
    Icons.school,
    Icons.chat_bubble_outline,
  ];

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    final userData = await AuthService.getUserData();
    if (userData == null || userData['role'] != 'admin') {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotifications(),
            tooltip: 'Powiadomienia',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'settings') {
                _showSettings();
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Ustawienia'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Wyloguj', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(_icons[0]),
            label: 'Panel',
          ),
          BottomNavigationBarItem(
            icon: Icon(_icons[1]),
            label: 'Użytkownicy',
          ),
          BottomNavigationBarItem(
            icon: Icon(_icons[2]),
            label: 'Nauczyciele',
          ),
          BottomNavigationBarItem(
            icon: Icon(_icons[3]),
            label: 'Przegląd',
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Powiadomienia'),
          ],
        ),
        content: const SizedBox(
          width: 300,
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Brak nowych powiadomień',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Powiadomienia będą wyświetlane tutaj',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zamknij'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Ustawienia'),
          ],
        ),
        content: SizedBox(
          width: 300,
          height: 300,
          child: FutureBuilder(
            future: AuthService.getUserData(),
            builder: (context, snapshot) {
              final userData = snapshot.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informacje o administratorze:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (userData != null) ...[
                    _buildInfoRow('Imię i nazwisko:', '${userData['first_name']} ${userData['last_name']}'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Email:', userData['email'] ?? ''),
                    const SizedBox(height: 8),
                    _buildInfoRow('Rola:', userData['role'] ?? ''),
                  ],
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Opcje systemu:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.backup),
                    title: const Text('Backup danych'),
                    subtitle: const Text('Tworzenie kopii zapasowej'),
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funkcja backup w przygotowaniu'),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.analytics),
                    title: const Text('Raporty systemowe'),
                    subtitle: const Text('Szczegółowe analizy'),
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funkcja raportów w przygotowaniu'),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zamknij'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Wylogowanie'),
          ],
        ),
        content: const Text('Czy na pewno chcesz się wylogować z panelu administracyjnego?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Wyloguj'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
}
