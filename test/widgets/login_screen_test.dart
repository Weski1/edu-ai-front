import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska_front/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen wyświetla formularz logowania', (WidgetTester tester) async {
    // Buduj widget
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    // Sprawdź czy są pola tekstowe
    expect(find.byType(TextField), findsAtLeastNWidgets(2));
    
    // Sprawdź czy jest przycisk logowania
    expect(find.text('Zaloguj się'), findsOneWidget);
  });

  testWidgets('LoginScreen waliduje puste pola', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    // Znajdź przycisk logowania i kliknij bez wypełniania pól
    final loginButton = find.text('Zaloguj się');
    await tester.tap(loginButton);
    await tester.pump();

    // Oczekuj komunikatu o błędzie
    expect(find.text('Uzupełnij wszystkie pola'), findsOneWidget);
  });

  testWidgets('LoginScreen ma link do rejestracji', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    // Sprawdź czy jest przycisk rejestracji
    expect(find.text('Nie masz konta? Rejestracja'), findsOneWidget);
  });

  testWidgets('LoginScreen ma link do resetowania hasła', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    // Sprawdź czy jest opcja resetowania hasła
    expect(find.text('Nie pamiętasz hasła?'), findsOneWidget);
  });

  testWidgets('LoginScreen pozwala wpisać email i hasło', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    // Znajdź pola tekstowe
    final emailField = find.byType(TextField).first;
    final passwordField = find.byType(TextField).last;

    // Wpisz dane
    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'haslo123');
    await tester.pump();

    // Sprawdź czy tekst został wprowadzony
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('haslo123'), findsOneWidget);
  });
}
