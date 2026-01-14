import 'package:flutter/material.dart';
import 'package:praca_inzynierska_front/screens/login_screen.dart';
import 'package:praca_inzynierska_front/screens/main_screen.dart';
import 'package:praca_inzynierska_front/services/auth_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Opóźnienie dla estetyki (opcjonalne), żeby ekran nie "mignął" za szybko,
    // jeśli sprawdzanie jest błyskawiczne.
    // await Future.delayed(const Duration(seconds: 1));

    final token = await AuthService.getSavedToken();
    if (!mounted) return;

    if (token != null) {
      final isValid = await AuthService.isTokenValid();
      if (!mounted) return;

      if (isValid) {
        // Token ważny -> idź do głównego ekranu
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(token: token)),
        );
      } else {
        // Token nieważny/wygasł -> wyczyść i idź do logowania z komunikatem
        await AuthService.logout();
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Twoja sesja wygasła. Zaloguj się ponownie.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
    // Jeśli token == null, zostajemy na WelcomeScreen
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Witaj w EduAI 👋',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Twój osobisty asystent do nauki z AI.\nWybierz przedmiot i zacznij naukę!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onBackground.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Zaczynamy!'),
            ),
          ],
        ),
      ),
    );
  }
}
