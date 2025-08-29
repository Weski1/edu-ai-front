import 'package:flutter/material.dart';
import 'package:praca_inzynierska_front/screens/main_screen.dart';
import 'package:praca_inzynierska_front/screens/register_screen.dart';
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
  bool _resetLoading = false;

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
    final token = await AuthService.login(email, password);
    setState(() => _loading = false);

    if (token != null && token.isNotEmpty) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(token: token)),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logowanie nieudane. Sprawdź dane.')),
      );
    }
  }

  Future<void> _onForgotPassword() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      final tempController = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Reset hasła"),
          content: TextField(
            controller: tempController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Podaj e-mail",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Anuluj")),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Wyślij")),
          ],
        ),
      );
      if (ok != true) return;
      email = tempController.text.trim();
    }

    if (email.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Podaj adres e-mail")),
      );
      return;
    }

    setState(() => _resetLoading = true);
    final error = await AuthService.requestPasswordReset(email);
    setState(() => _resetLoading = false);

    if (error == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jeśli podany e-mail istnieje, wysłaliśmy instrukcje resetu hasła.")),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final resetChild = _resetLoading
        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
        : const Text("Nie pamiętasz hasła?");

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Logowanie', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Hasło', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading ? const CircularProgressIndicator() : const Text('Zaloguj się'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text('Nie masz konta? Rejestracja'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _resetLoading ? null : _onForgotPassword,
                child: resetChild,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
