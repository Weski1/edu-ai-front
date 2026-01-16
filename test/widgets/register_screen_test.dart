import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska_front/screens/register_screen.dart';

void main() {
  testWidgets('RegisterScreen wyświetla wszystkie pola formularza', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RegisterScreen(),
      ),
    );

    // Sprawdź tytuł
    expect(find.text('Rejestracja'), findsOneWidget);

    // Sprawdź czy są wszystkie pola tekstowe (5: imię, nazwisko, email, hasło, potwierdzenie)
    expect(find.byType(TextField), findsNWidgets(5));

    // Sprawdź przyciski
    expect(find.text('Zarejestruj się'), findsOneWidget);
    expect(find.text('Masz już konto? Zaloguj się'), findsOneWidget);
  });

  testWidgets('RegisterScreen waliduje puste pola', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RegisterScreen(),
      ),
    );

    // Przewiń do przycisku (może być poza ekranem)
    final registerButton = find.widgetWithText(FilledButton, 'Zarejestruj się');
    await tester.ensureVisible(registerButton);
    await tester.pumpAndSettle();
    
    // Kliknij przycisk rejestracji bez wypełniania pól
    await tester.tap(registerButton);
    await tester.pump();

    // Oczekuj komunikatu o błędzie
    expect(find.text('Uzupełnij wszystkie pola'), findsOneWidget);
  });

  testWidgets('RegisterScreen ma ikonę użytkownika', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RegisterScreen(),
      ),
    );

    // Sprawdź czy jest ikona person_add
    expect(find.byIcon(Icons.person_add_outlined), findsOneWidget);
  });

  testWidgets('RegisterScreen pozwala wypełnić wszystkie pola', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RegisterScreen(),
      ),
    );

    // Znajdź wszystkie pola tekstowe
    final textFields = find.byType(TextField);
    
    // Wypełnij wszystkie pola
    await tester.enterText(textFields.at(0), 'Jan');
    await tester.enterText(textFields.at(1), 'Kowalski');
    await tester.enterText(textFields.at(2), 'jan@example.com');
    await tester.enterText(textFields.at(3), 'haslo123');
    await tester.enterText(textFields.at(4), 'haslo123');
    await tester.pump();

    // Sprawdź czy tekst został wprowadzony
    expect(find.text('Jan'), findsOneWidget);
    expect(find.text('Kowalski'), findsOneWidget);
    expect(find.text('jan@example.com'), findsOneWidget);
  });

  testWidgets('RegisterScreen ma odpowiednie ikony w polach', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RegisterScreen(),
      ),
    );

    // Sprawdź ikony
    expect(find.byIcon(Icons.person_outlined), findsWidgets);
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsWidgets);
  });

  testWidgets('RegisterScreen ma link do logowania', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RegisterScreen(),
      ),
    );

    // Sprawdź przycisk logowania
    expect(find.text('Masz już konto? Zaloguj się'), findsOneWidget);
    final loginButton = find.widgetWithText(TextButton, 'Masz już konto? Zaloguj się');
    expect(loginButton, findsOneWidget);
  });

  testWidgets('RegisterScreen ma strukturę Card', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RegisterScreen(),
      ),
    );

    // Sprawdź czy formularz jest w Card
    expect(find.byType(Card), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
