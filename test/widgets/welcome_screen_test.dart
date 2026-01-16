import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska_front/screens/welcome_screen.dart';

void main() {
  testWidgets('WelcomeScreen wyświetla tytuł i przycisk', (WidgetTester tester) async {
    // Buduj widget w kontekście testowym
    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    // Poczekaj na zakończenie animacji
    await tester.pumpAndSettle();

    // Sprawdź czy wyświetla się tytuł
    expect(find.text('Witaj w EduAI'), findsOneWidget);

    // Sprawdź czy jest przycisk "Zaczynamy!"
    expect(find.text('Zaczynamy!'), findsOneWidget);
    
    // Sprawdź opis aplikacji
    expect(find.textContaining('Twój osobisty asystent'), findsOneWidget);
  });

  testWidgets('WelcomeScreen ma prawidłową strukturę', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Sprawdź czy istnieją elementy UI
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(Column), findsWidgets);
  });

  testWidgets('WelcomeScreen przycisk "Zaczynamy!" działa', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Znajdź i kliknij przycisk
    final button = find.text('Zaczynamy!');
    expect(button, findsOneWidget);
    
    await tester.tap(button);
    await tester.pumpAndSettle();

    // Po kliknięciu powinien przejść do ekranu logowania
    expect(find.text('Logowanie'), findsOneWidget);
  });

  testWidgets('WelcomeScreen wyświetla pełny tekst opisu', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Sprawdź treść opisu
    expect(find.textContaining('Wybierz przedmiot i zacznij naukę'), findsOneWidget);
  });
}
