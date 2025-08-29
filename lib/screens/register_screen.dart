import 'package:flutter/material.dart';
import 'package:praca_inzynierska_front/services/auth_service.dart';
import 'package:praca_inzynierska_front/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _loading = false;

  Future<void> _register() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmController.text.trim();

    if ([firstName, lastName, email, password, confirmPassword].any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uzupełnij wszystkie pola')),
      );
      return;
    }

    setState(() => _loading = true);
    final error = await AuthService.register(firstName, lastName, email, password, confirmPassword);
    setState(() => _loading = false);

    if (error == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rejestracja OK. Sprawdź e-mail, a potem zaloguj się.')),
      );
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Rejestracja', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'Imię', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Nazwisko', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Hasło', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _confirmController, obscureText: true, decoration: const InputDecoration(labelText: 'Powtórz hasło', border: OutlineInputBorder())),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _loading ? null : _register, child: _loading ? const CircularProgressIndicator() : const Text('Zarejestruj się')),
              const SizedBox(height: 12),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Masz już konto? Zaloguj się')),
            ],
          ),
        ),
      ),
    );
  }
}
