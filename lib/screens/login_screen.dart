import 'package:flutter/material.dart';
import 'package:praca_inzynierska_front/screens/main_screen.dart';
import 'package:praca_inzynierska_front/screens/register_screen.dart';
import 'package:praca_inzynierska_front/screens/password_reset_request_screen.dart';
import 'package:praca_inzynierska_front/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uzupełnij wszystkie pola')),
      );
      return;
    }
    setState(() => _loading = true);
    final success = await AuthService.loginAndSave(email, password);
    
    if (success) {
      final token = await AuthService.getSavedToken();
      
      if (!mounted) return;
      
      // Wszyscy użytkownicy (włącznie z administratorami) idą do głównej aplikacji
      // Administratorzy będą mieli dodatkową zakładkę "Admin" w menu nawigacji
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(token: token!)),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logowanie nieudane. Sprawdź dane.')),
      );
    }

    setState(() => _loading = false);
  }

  void _onForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PasswordResetRequestScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Logowanie', 
                    textAlign: TextAlign.center, 
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Hasło',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _login,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Zaloguj się', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Nie masz konta? Rejestracja', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _onForgotPassword,
                    child: const Text("Nie pamiętasz hasła?"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
